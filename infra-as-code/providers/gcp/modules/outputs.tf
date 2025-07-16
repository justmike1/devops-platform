output "cluster_domain" {
  value = var.domain
}

output "cluster_ip_address" {
  value = google_compute_global_address.cluster-cloud-armor-address.*.name
}

output "project_id" {
  value = var.project_id
}

output "vpc_network_name" {
  value = module.vpc.network_name
}

output "region" {
  value = var.region
}

output "cluster_name" {
  value = local.cluster_name
}

output "bastion_external_ip" {
  value       = var.enable_bastion ? google_compute_address.bastion_ip[0].address : null
  description = "The external IP of the bastion host (null if disabled)"
}
