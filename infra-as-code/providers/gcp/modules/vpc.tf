module "vpc" {
  source = "terraform-google-modules/network/google"

  project_id                             = var.project_id
  network_name                           = "${local.cluster_name}-vpc"
  routing_mode                           = "REGIONAL"
  auto_create_subnetworks                = false
  mtu                                    = 1460
  delete_default_internet_gateway_routes = false

  depends_on = [
    google_project_service.project_services
  ]

  subnets = concat([
    {
      subnet_name               = "private-subnet"
      subnet_ip                 = "10.0.0.0/18"
      subnet_region             = var.region
      subnet_private_access     = "true"
      subnet_flow_logs          = "true"
      subnet_flow_logs_interval = "INTERVAL_10_MIN"
      subnet_flow_logs_sampling = 0.7
      subnet_flow_logs_metadata = "INCLUDE_ALL_METADATA"
    }
    ],
    var.enable_bastion ? [
      {
        subnet_name               = "public-subnet"
        subnet_ip                 = "10.0.64.0/24"
        subnet_region             = var.region
        subnet_private_access     = "false"
        subnet_flow_logs          = "true"
        subnet_flow_logs_interval = "INTERVAL_10_MIN"
        subnet_flow_logs_sampling = 0.5
        subnet_flow_logs_metadata = "INCLUDE_ALL_METADATA"
      }
  ] : [])

  secondary_ranges = {
    private-subnet = [
      {
        range_name    = "k8s-pod-range"
        ip_cidr_range = "10.48.0.0/14"
      },
      {
        range_name    = "k8s-service-range"
        ip_cidr_range = "10.52.0.0/20"
      }
    ]
  }

  routes = [
    {
      name              = "egress-internet"
      description       = "route through IGW to access internet"
      destination_range = "0.0.0.0/0"
      tags              = "egress-inet"
      next_hop_internet = "true"
    }
  ]
}

resource "google_compute_global_address" "private_ip_address" {
  name          = "private-ip-address"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = module.vpc.network_self_link
  depends_on = [
    module.vpc
  ]
}

resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = module.vpc.network_self_link
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]
  depends_on = [
    module.vpc
  ]
}
