resource "azurerm_storage_account" "sa" {
  count                    = var.create_storage ? 1 : 0
  name                     = "${var.resource_group_name}-sa"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  depends_on = [
    resource.azurerm_resource_group.main
  ]
}

resource "azurerm_storage_container" "sc" {
  count                 = var.create_storage ? 1 : 0
  name                  = "tfstate"
  storage_account_id    = resource.azurerm_storage_account.sa[0].name
  container_access_type = "private"
  depends_on = [
    resource.azurerm_resource_group.main,
    resource.azurerm_storage_account.sa
  ]
}