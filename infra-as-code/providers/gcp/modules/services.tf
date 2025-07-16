# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_project_service

locals {
  services = ["compute.googleapis.com", "container.googleapis.com", "compute.googleapis.com", "servicenetworking.googleapis.com", "storage-api.googleapis.com", "storage-component.googleapis.com", "networkservices.googleapis.com"]
}
resource "google_project_service" "project_services" {
  for_each                   = toset(local.services)
  service                    = each.key
  project                    = var.project_id
  disable_dependent_services = true

  # DON'T DESTROY THIS RESOURCE, IF YOU WANT TO THEN ONLY REMOVE IT FROM STATE
  # RUN "terraform state rm module.kubernetes-cluster.google_project_service.project_services"
  # lifecycle {
  #   prevent_destroy = true # DO NOT CHANGE
  # }
}