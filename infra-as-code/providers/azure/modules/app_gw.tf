data "azurerm_client_config" "current" {}

data "azurerm_key_vault" "organization_ssl" {
  name                = "Organization-Global"
  resource_group_name = "Global-Management"
}

resource "azurerm_public_ip" "appgw-ip" {
  count               = var.create_appgw ? 1 : 0
  name                = "appgw-pip"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"

  depends_on = [
    azurerm_resource_group.main
  ]
}

resource "azurerm_user_assigned_identity" "appgw_identity" {
  count               = var.create_appgw ? 1 : 0
  name                = "appgw-identity"
  resource_group_name = var.resource_group_name
  location            = var.location

  depends_on = [
    azurerm_resource_group.main
  ]
}

resource "azurerm_role_assignment" "appgw_kv_access" {
  count                = var.create_appgw ? 1 : 0
  principal_id         = azurerm_user_assigned_identity.appgw_identity[count.index].principal_id
  role_definition_name = "Key Vault Secrets User"
  scope                = data.azurerm_key_vault.organization_ssl.id

  depends_on = [
    azurerm_user_assigned_identity.appgw_identity
  ]
}

resource "azurerm_role_assignment" "agic_mi_operator" {
  count                = var.create_appgw ? 1 : 0
  principal_id         = azurerm_user_assigned_identity.appgw_identity[count.index].principal_id
  role_definition_name = "Managed Identity Operator"
  scope                = azurerm_resource_group.main[0].id

  depends_on = [
    azurerm_user_assigned_identity.appgw_identity
  ]
}

resource "azurerm_role_assignment" "agic_network_contributor" {
  count                = var.create_appgw ? 1 : 0
  principal_id         = azurerm_user_assigned_identity.appgw_identity[count.index].principal_id
  role_definition_name = "Network Contributor"
  scope                = azurerm_resource_group.main[0].id

  depends_on = [
    azurerm_user_assigned_identity.appgw_identity
  ]
}

resource "azurerm_application_gateway" "appgw" {
  count               = var.create_appgw ? 1 : 0
  name                = "appgw"
  resource_group_name = var.resource_group_name
  location            = var.location

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 2
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.appgw_identity[count.index].id]
  }

  gateway_ip_configuration {
    name      = "appgw-subnet"
    subnet_id = azurerm_subnet.appgw-subnet[0].id
  }

  frontend_port {
    name = "https"
    port = 443
  }

  ssl_certificate {
    name                = "ssl-cert"
    key_vault_secret_id = ""
  }

  ssl_certificate {
    name                = "ssl-cert-ai"
    key_vault_secret_id = ""
  }

  frontend_ip_configuration {
    name                 = "frontend-ip"
    public_ip_address_id = azurerm_public_ip.appgw-ip[count.index].id
  }

  backend_address_pool {
    name = "backend-pool"
  }

  backend_http_settings {
    name                  = "http-settings"
    cookie_based_affinity = "Disabled"
    path                  = "/"
    port                  = 443
    protocol              = "Https"
    request_timeout       = 60
  }

  http_listener {
    name                           = "https-listener"
    frontend_ip_configuration_name = "frontend-ip"
    frontend_port_name             = "https"
    protocol                       = "Https"
    ssl_certificate_name           = "ssl-cert"
  }

  request_routing_rule {
    name                       = "rule"
    priority                   = 9
    rule_type                  = "Basic"
    http_listener_name         = "https-listener"
    backend_address_pool_name  = "backend-pool"
    backend_http_settings_name = "http-settings"
  }

  lifecycle {
    ignore_changes = all
  }

  depends_on = [
    azurerm_public_ip.appgw-ip,
    azurerm_user_assigned_identity.appgw_identity,
    azurerm_role_assignment.agic_mi_operator,
    azurerm_role_assignment.agic_network_contributor,
    azurerm_role_assignment.appgw_kv_access
  ]
}

# !!! Use This script when you change the certificate in Key Vault, in order to update the Application Gateway with the new certificate.
# # PowerShell script to update the Application Gateway with a new certificate from Key Vault
# ###
# # Get the Application Gateway we want to modify  
# $appgw = Get-AzApplicationGateway -Name MyApplicationGateway -ResourceGroupName MyResourceGroup  

# # Specify the resource id to the user assigned managed identity - This can be found by going to the properties of the managed identity  
# Set-AzApplicationGatewayIdentity -ApplicationGateway $appgw -UserAssignedIdentityId "/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/MyResourceGroup/providers/Microsoft.ManagedIdentity/userAssignedIdentities/MyManagedIdentity"  

# # Get the secret ID from Key Vault  
# $secret = Get-AzKeyVaultSecret -VaultName "MyKeyVault" -Name "CertificateName"  

# # Remove the secret version so AppGW will use the latest version in future syncs  
# $secretId = $secret.Id.Replace($secret.Version, "")  

# # Specify the secret ID from Key Vault   
# Add-AzApplicationGatewaySslCertificate -KeyVaultSecretId $secretId -ApplicationGateway $appgw -Name $secret.Name  

# # Commit the changes to the Application Gateway  
# Set-AzApplicationGateway -ApplicationGateway $appgw

# ###