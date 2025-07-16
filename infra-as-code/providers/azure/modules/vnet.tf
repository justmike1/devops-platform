resource "azurerm_virtual_network" "vnet" {
  count               = var.create_vnet ? 1 : 0
  address_space       = ["11.0.0.0/16"]
  location            = var.location
  name                = "${var.resource_group_name}-vnet"
  resource_group_name = var.resource_group_name
  depends_on = [
    resource.azurerm_resource_group.main
  ]
}
resource "azurerm_subnet" "subnet" {
  count = var.create_vnet ? 1 : 0

  name                 = "${var.resource_group_name}-subnet"
  address_prefixes     = ["11.0.64.0/18"]
  resource_group_name  = var.resource_group_name
  virtual_network_name = resource.azurerm_virtual_network.vnet[0].name
  depends_on = [
    resource.azurerm_resource_group.main,
    resource.azurerm_virtual_network.vnet
  ]
}

resource "azurerm_subnet" "appgw-subnet" {
  count = var.create_vnet ? 1 : 0

  name                 = "${var.resource_group_name}-appgw-subnet"
  address_prefixes     = ["11.0.5.0/24"]
  resource_group_name  = var.resource_group_name
  virtual_network_name = resource.azurerm_virtual_network.vnet[0].name

  depends_on = [
    resource.azurerm_resource_group.main,
    azurerm_virtual_network.vnet
  ]
}