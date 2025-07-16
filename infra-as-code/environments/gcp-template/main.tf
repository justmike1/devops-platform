module "kubernetes-cluster" {
  source              = "../../providers/gcp/modules"
  project_id          = ""
  environment         = "misc"
  region              = "europe-north2"
  domain              = ""
  master_machine_type = "e2-small"
  master_min_count    = 1
  master_max_count    = 1
  spot_machine_type   = "e2-standard-8"
  spot_min_count      = 1
  spot_max_count      = 3
  spot_gke            = true
  enable_spot_pool    = true

  enable_bastion        = false
  bastion_whitelist_ips = []
  enable_traefik        = false
  enable_armored_gce_lb = false
  regional_gke          = false
}