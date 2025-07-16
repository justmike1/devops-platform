module "gke" {
  source                   = "terraform-google-modules/kubernetes-engine/google//modules/private-cluster"
  project_id               = var.project_id
  name                     = local.cluster_name
  remove_default_node_pool = true
  region                   = var.region
  regional                 = var.regional_gke
  zones                    = var.regional_gke ? [] : ["${var.region}-c"]
  network                  = module.vpc.network_name
  subnetwork               = "private-subnet"
  ip_range_pods            = "k8s-pod-range"
  ip_range_services        = "k8s-service-range"
  identity_namespace       = "${var.project_id}.svc.id.goog"
  # TODO: Need to create global VPC and use here shared VPC parameters and change to private cluster
  http_load_balancing        = false
  network_policy             = false
  horizontal_pod_autoscaling = true
  enable_private_endpoint    = var.enable_private_gke
  enable_private_nodes       = true
  release_channel            = "STABLE"
  filestore_csi_driver       = false
  datapath_provider          = "ADVANCED_DATAPATH"
  deletion_protection        = false
  master_ipv4_cidr_block     = "10.64.0.0/28"
  master_authorized_networks = var.enable_private_gke ? [
    {
      cidr_block   = "10.0.64.0/24" # Your bastion subnet
      display_name = "Bastion Host Access"
    }
    ] : [
    {
      cidr_block   = "0.0.0.0/0"
      display_name = "Whitelisted all by default"
    }
  ]

  node_pools = concat([
    {
      name               = "master"
      autoscaling        = false
      machine_type       = var.master_machine_type
      min_count          = var.master_min_count
      max_count          = var.master_max_count
      local_ssd_count    = 0
      spot               = false
      disk_size_gb       = var.master_disk_size_gb
      disk_type          = "pd-standard"
      image_type         = "COS_CONTAINERD"
      enable_gcfs        = false
      enable_gvnic       = false
      auto_repair        = true
      auto_upgrade       = true
      service_account    = google_service_account.cluster-sa.email
      initial_node_count = 1
    }
    ],
    var.enable_spot_pool ? [
      {
        name               = "spotpool"
        autoscaling        = true
        machine_type       = var.spot_machine_type
        min_count          = var.spot_min_count
        max_count          = var.spot_max_count
        local_ssd_count    = 0
        spot               = var.spot_gke
        disk_size_gb       = var.spot_disk_size_gb
        disk_type          = "pd-standard"
        image_type         = "COS_CONTAINERD"
        enable_gcfs        = false
        enable_gvnic       = false
        auto_repair        = true
        auto_upgrade       = true
        service_account    = google_service_account.cluster-sa.email
        initial_node_count = 1
      }
  ] : [])

  node_pools_oauth_scopes = {
    all = [
      "https://www.googleapis.com/auth/cloud-platform",
      "https://www.googleapis.com/auth/ndev.clouddns.readwrite",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/service.management.readonly"
    ]
    master = []
  }

  node_pools_labels = merge({
    all = {
      gke-no-default-nvidia-gpu-device-plugin = true
    }
    master = {
      role = "master"
      team = "devops"
    }
    }, var.enable_spot_pool ? {
    spotpool = {
      role = "spot"
      spot = "true"
    }
  } : {})


  node_pools_metadata = merge({
    all    = {}
    master = {}
    }, var.enable_spot_pool ? {
    spotpool = {}
  } : {})

  node_pools_taints = merge({
    master = []
    all    = []
    }, var.enable_spot_pool ? {
    spotpool = []
  } : {})

  node_pools_tags = merge({
    all    = []
    master = ["all-services"]
    }, var.enable_spot_pool ? {
    spotpool = []
  } : {})

  depends_on = [
    google_service_account.cluster-sa,
    module.vpc,
    google_project_service.project_services
  ]
}

resource "null_resource" "connect_to_gke" {
  provisioner "local-exec" {
    command = "gcloud container clusters get-credentials ${local.cluster_name} --region ${var.regional_gke ? var.region : "${var.region}-c"} --project ${var.project_id}"
  }
  depends_on = [
    module.gke
  ]
}
