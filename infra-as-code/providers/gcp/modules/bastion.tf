resource "google_compute_address" "bastion_ip" {
  count  = var.enable_bastion ? 1 : 0
  name   = "bastion-ip"
  region = var.region
}

resource "google_compute_instance" "bastion" {
  count                     = var.enable_bastion ? 1 : 0
  name                      = "bastion-host"
  machine_type              = "e2-small"
  zone                      = "${var.region}-c"
  allow_stopping_for_update = true

  service_account {
    email  = google_service_account.bastion[0].email
    scopes = ["cloud-platform"]
  }

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
    }
  }

  network_interface {
    subnetwork = local.public_subnet
    access_config {
      nat_ip = google_compute_address.bastion_ip[0].address
    }
  }

  metadata_startup_script = <<-EOT
    #!/bin/bash
    sudo apt-get update
    sudo apt-get install -y apt-transport-https ca-certificates curl
    sudo apt-get install -y google-cloud-sdk kubectl
    sudo apt-get install google-cloud-sdk-gke-gcloud-auth-plugin

  EOT


  tags = ["bastion", "egress-inet"]
  depends_on = [
    module.vpc
  ]
}

resource "google_compute_firewall" "allow_ssh_bastion" {
  count   = var.enable_bastion ? 1 : 0
  name    = "allow-ssh-to-bastion"
  network = module.vpc.network_name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = var.bastion_whitelist_ips
  target_tags   = ["bastion"]
}

resource "google_compute_firewall" "allow_bastion_to_master" {
  count   = var.enable_bastion ? 1 : 0
  name    = "allow-bastion-to-master"
  network = module.vpc.network_name

  direction = "INGRESS"
  priority  = 1000

  # Update this to your bastion (public) subnet CIDR
  source_ranges = ["10.0.64.0/24"]

  # This is your cluster master IPv4 CIDR block from GKE private cluster config
  destination_ranges = ["10.64.0.0/28"]

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }
}

resource "google_compute_firewall" "allow_bastion_to_nodes" {
  count   = var.enable_bastion ? 1 : 0
  name    = "allow-bastion-to-nodes"
  network = module.vpc.network_name

  direction = "INGRESS"
  priority  = 1000

  # Update this to your bastion (public) subnet CIDR
  source_ranges = ["10.0.64.0/24"]

  # This is your private subnet CIDR where GKE nodes reside
  destination_ranges = ["10.0.0.0/18"]

  allow {
    protocol = "tcp"
    ports    = ["443", "10250"]
  }
}
