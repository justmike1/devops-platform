resource "google_storage_bucket" "backend" {
  count         = var.backend_bucket != "" ? 1 : 0
  name          = var.backend_bucket
  project       = var.project_id
  location      = "US"
  storage_class = "STANDARD"

  lifecycle {
    prevent_destroy = true
  }

  versioning {
    enabled = true
  }

  labels = {
    "project" = var.project_id
  }
}
