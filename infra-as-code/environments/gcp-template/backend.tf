# # https://www.terraform.io/language/settings/backends/gcs
terraform {
  backend "gcs" {
    bucket = ""
    prefix = "terraform/state"
  }
}