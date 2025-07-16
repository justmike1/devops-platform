resource "azurerm_private_dns_zone" "private-dns" {
  count = var.create_postgresql ? 1 : 0 # mandatory for managed postgresql

  name                = "${var.resource_group_name}.postgres.database.azure.com"
  resource_group_name = var.resource_group_name

  lifecycle {
    ignore_changes = [
      name
    ]
  }

  depends_on = [
    resource.azurerm_resource_group.main
  ]
}

resource "azurerm_private_dns_zone_virtual_network_link" "postgresql_dns_link" {
  count                 = var.create_postgresql ? 1 : 0
  name                  = "${var.resource_group_name}-postgresql-dns-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.private-dns[0].name
  virtual_network_id    = azurerm_virtual_network.vnet[0].id
  registration_enabled  = false

  depends_on = [
    azurerm_private_dns_zone.private-dns,
    azurerm_virtual_network.vnet
  ]
}