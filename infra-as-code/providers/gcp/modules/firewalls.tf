module "firewall_rules" {
  source       = "terraform-google-modules/network/google//modules/firewall-rules"
  project_id   = var.project_id
  network_name = module.vpc.network_name

  rules = [
    {
      name                    = "${local.cluster_name}-allow-ssh-ingress"
      description             = "allow ssh access"
      direction               = "INGRESS"
      priority                = null
      ranges                  = ["0.0.0.0/0"]
      source_tags             = null
      source_service_accounts = null
      target_tags             = null
      target_service_accounts = null
      allow = [{
        protocol = "tcp"
        ports    = ["22"]
      }]
      deny = []
      log_config = {
        metadata = "INCLUDE_ALL_METADATA"
      }
    },
    {
      name                    = "${local.cluster_name}-default-ingress-ports"
      description             = "Creates firewall rule targeting tagged instances"
      direction               = "INGRESS"
      priority                = null
      ranges                  = ["10.0.0.0/18"]
      source_tags             = null
      source_service_accounts = null
      target_tags             = null
      target_service_accounts = null
      allow = [{
        protocol = "tcp"
        ports    = ["80", "8080", "8443"]
      }]
      deny = []
      log_config = {
        metadata = "INCLUDE_ALL_METADATA"
      }
    }
  ]
}
resource "google_compute_firewall" "allow_bastion_to_control_plane" {
  name    = "allow-bastion-to-control-plane"
  network = module.vpc.network_name

  direction = "INGRESS"
  priority  = 1000

  source_ranges = ["10.0.64.0/24"] # Bastion subnet
  target_tags   = []               # Applies to all instances in network

  allow {
    protocol = "tcp"
    ports    = ["443", "10250"]
  }
}