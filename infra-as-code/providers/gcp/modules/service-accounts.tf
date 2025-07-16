# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_service_account
# cluster's service account
resource "google_service_account" "cluster-sa" {
  account_id   = local.cluster_name
  project      = var.project_id
  display_name = "${local.cluster_name}'s node pools service account"
}

resource "google_service_account" "bastion" {
  count        = var.enable_bastion ? 1 : 0
  project      = var.project_id
  account_id   = "bastion-sa"
  display_name = "Bastion Host Service Account"
}
resource "google_project_iam_member" "bastion_container_developer" {
  count   = var.enable_bastion ? 1 : 0
  project = var.project_id
  role    = "roles/container.developer"
  member  = "serviceAccount:${google_service_account.bastion[0].email}"
}

resource "google_project_iam_member" "bastion_service_account_user" {
  count   = var.enable_bastion ? 1 : 0
  project = var.project_id
  role    = "roles/iam.serviceAccountUser"
  member  = "serviceAccount:${google_service_account.bastion[0].email}"
}