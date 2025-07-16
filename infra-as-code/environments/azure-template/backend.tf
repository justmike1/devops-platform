terraform {
  backend "azurerm" {
    resource_group_name  = ""
    storage_account_name = ""
    container_name       = "terraform-state"
    key                  = "terraform.tfstate.misc"
  }
}