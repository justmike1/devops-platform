locals {
  aks_name = "${var.resource_group_name}-aks"
}

resource "azurerm_resource_group" "main" {
  count = var.create_resource_group ? 1 : 0

  location = var.location
  name     = var.resource_group_name
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                              = local.aks_name
  location                          = var.location
  resource_group_name               = var.resource_group_name
  dns_prefix                        = local.aks_name
  azure_policy_enabled              = false
  private_cluster_enabled           = false
  role_based_access_control_enabled = false
  sku_tier                          = "Standard"

  default_node_pool {
    name                        = "nodepool"
    temporary_name_for_rotation = "tempnp"
    auto_scaling_enabled        = true
    vm_size                     = var.default_np_agent_size
    min_count                   = var.default_np_min_count
    max_count                   = var.default_np_max_count
    type                        = "VirtualMachineScaleSets"
    os_disk_size_gb             = var.os_disk_size_gb
    vnet_subnet_id              = azurerm_subnet.subnet[0].id
    max_pods                    = 120
    node_labels = {
      transparent_huge_page_enabled = "always"
    }
  }

  lifecycle {
    ignore_changes = [
      default_node_pool[0].upgrade_settings
    ]
  }

  auto_scaler_profile {
    balance_similar_node_groups                = true
    daemonset_eviction_for_empty_nodes_enabled = true
    empty_bulk_delete_max                      = 1000
    max_graceful_termination_sec               = 30
    max_unready_nodes                          = 1000
    max_unready_percentage                     = 100
    scale_down_delay_after_add                 = "1m"
    scale_down_delay_after_failure             = "1m"
    scale_down_unneeded                        = "3m"
    scale_down_unready                         = "3m"
    scan_interval                              = "30s"
    skip_nodes_with_system_pods                = false
  }
  key_vault_secrets_provider {
    secret_rotation_enabled = false
  }

  dynamic "ingress_application_gateway" {
    for_each = var.create_appgw ? [1] : []
    content {
      gateway_id = azurerm_application_gateway.appgw[0].id
    }
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin    = "azure"
    load_balancer_sku = "standard"
    network_policy    = "azure"
  }

  depends_on = [
    azurerm_resource_group.main,
    azurerm_subnet.subnet[0],
    azurerm_application_gateway.appgw
  ]
}

resource "azurerm_kubernetes_cluster_node_pool" "spot_pool" {
  count = var.enable_spot_node_pool ? 1 : 0

  name                        = "spotpool"
  kubernetes_cluster_id       = azurerm_kubernetes_cluster.aks.id
  vm_size                     = var.spot_vm_size
  auto_scaling_enabled        = true
  min_count                   = var.min_count
  max_count                   = var.max_count
  os_disk_size_gb             = var.os_disk_size_gb
  vnet_subnet_id              = azurerm_subnet.subnet[0].id
  priority                    = "Spot"
  eviction_policy             = "Delete"
  max_pods                    = 120
  temporary_name_for_rotation = "tempspotnp"

  lifecycle {
    ignore_changes = [
      node_taints,
    ]
  }

  depends_on = [azurerm_kubernetes_cluster.aks]
}

# generated managed identity for app gateway
data "azurerm_user_assigned_identity" "identity-appgw" {
  count               = var.create_appgw ? 1 : 0
  name                = "ingressapplicationgateway-${local.aks_name}" # convention name for AGIC Identity
  resource_group_name = azurerm_kubernetes_cluster.aks.node_resource_group

  depends_on = [
    azurerm_kubernetes_cluster.aks
  ]
}

# AppGW (generated with addon) Identity needs also Contributor role over AKS/VNET RG
resource "azurerm_role_assignment" "role-contributor" {
  count                = var.create_appgw ? 1 : 0
  scope                = azurerm_resource_group.main[0].id
  role_definition_name = "Contributor"
  principal_id         = data.azurerm_user_assigned_identity.identity-appgw[count.index].principal_id

  lifecycle {
    ignore_changes = [
      principal_id,
    ]
  }

  depends_on = [
    azurerm_kubernetes_cluster.aks, azurerm_application_gateway.appgw
  ]
}

output "cluster_name" {
  value       = azurerm_kubernetes_cluster.aks.name
  description = "The name of the AKS cluster"
}