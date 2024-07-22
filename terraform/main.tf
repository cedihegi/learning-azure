resource "azurerm_resource_group" "rg" {
  location = var.resource_group_location
  name     = "${var.resource_group_name}-${var.environment_short}"
}

data "azurerm_client_config" "current" {
}


resource "azurerm_key_vault" "secrets-kv" {
  name                            = "keyvault-cedihegi-${var.environment_short}"
  location                        = var.resource_group_location
  resource_group_name             = azurerm_resource_group.rg.name
  tenant_id                       = data.azurerm_client_config.current.tenant_id
  sku_name                        = "standard"
  enable_rbac_authorization       = true
  enabled_for_deployment          = false
  enabled_for_template_deployment = true
  enabled_for_disk_encryption     = false
  public_network_access_enabled   = true
}

# resource "azurerm_private_endpoint" "pe_keyvault" {
#   name = "${azurerm_key_vault.secrets-kv.name}-pe"
#   location = var.resource_group_location
#   resource_group_name = azurerm_resource_group.rg.name
#   subnet_id = ... obvisouly not since we didnt define a subnet
# }

resource "azurerm_role_assignment" "kv_secrets_global_owner" {
  principal_id = azuread_group.global-owner-group.object_id
  scope = azurerm_key_vault.secrets-kv.id
  role_definition_name = "Key Vault Administrator"
}

