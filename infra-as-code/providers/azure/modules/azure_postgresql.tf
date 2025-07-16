resource "random_id" "postgresql_suffix" {
  for_each    = var.create_postgresql ? { "key" = "value" } : {}
  byte_length = 4

}

locals {
  postgresql_suffix = var.create_postgresql ? random_id.postgresql_suffix["key"].hex : ""
  postgresql_name   = "${var.resource_group_name}-postgresql-${local.postgresql_suffix}"
  postgresql_dns    = "${local.postgresql_name}-dns.postgres.database.azure.com"
}

resource "azurerm_subnet" "postgresql-subnet" {
  count = var.create_postgresql ? 1 : 0

  name                 = "${var.resource_group_name}-postgresql-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = resource.azurerm_virtual_network.vnet[0].name
  address_prefixes     = ["11.0.6.0/24"]
  service_endpoints    = ["Microsoft.Storage"]
  delegation {
    name = "fs"
    service_delegation {
      name = "Microsoft.DBforPostgreSQL/flexibleServers"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
      ]
    }
  }

  depends_on = [
    resource.azurerm_resource_group.main,
    azurerm_virtual_network.vnet
  ]
}

resource "azurerm_private_dns_zone" "postgresql-internal-dns" {
  count = var.create_postgresql ? 1 : 0

  name                = local.postgresql_dns
  resource_group_name = var.resource_group_name

  lifecycle {
    ignore_changes = [
      name
    ]
  }

  depends_on = [
    resource.azurerm_resource_group.main,
    resource.random_id.postgresql_suffix
  ]
}

resource "azurerm_postgresql_flexible_server" "postgresql" {
  count = var.create_postgresql ? 1 : 0

  name                          = local.postgresql_name
  resource_group_name           = var.resource_group_name
  location                      = var.location
  sku_name                      = var.postgresql_sku_name
  storage_mb                    = var.postgresql_storage_mb
  public_network_access_enabled = var.sql_public_access
  administrator_login           = var.sql_username
  administrator_password        = ""
  version                       = "16"
  auto_grow_enabled             = true
  backup_retention_days         = 7
  delegated_subnet_id           = azurerm_subnet.postgresql-subnet[0].id
  private_dns_zone_id           = azurerm_private_dns_zone.private-dns[0].id

  maintenance_window {
    day_of_week  = "6" # Saturday
    start_hour   = 0
    start_minute = 0
  }

  lifecycle {
    prevent_destroy = true # Comment this line to allow destroy if you are sure what you are doing
    ignore_changes = [
      name,
      zone,
      high_availability[0].standby_availability_zone
    ]
  }

  depends_on = [
    resource.azurerm_resource_group.main,
    azurerm_subnet.postgresql-subnet,
    azurerm_private_dns_zone.private-dns
  ]
}

resource "azurerm_postgresql_flexible_server_configuration" "max_connections" {
  count = var.create_postgresql ? 1 : 0

  server_id = azurerm_postgresql_flexible_server.postgresql[0].id
  name      = "max_connections"
  value     = "5000"

  depends_on = [
    azurerm_postgresql_flexible_server.postgresql
  ]
}

resource "azurerm_postgresql_flexible_server_database" "postgresql_db" {
  for_each = toset(var.db_names)

  name      = each.value
  server_id = azurerm_postgresql_flexible_server.postgresql[0].id
  charset   = "UTF8"
  collation = "en_US.utf8"

  depends_on = [
    azurerm_postgresql_flexible_server.postgresql
  ]
}

output "postgresql_fqdn" {

  value       = var.create_postgresql ? azurerm_postgresql_flexible_server.postgresql[0].fqdn : ""
  description = "The FQDN of the PostgreSQL Flexible Server."
}