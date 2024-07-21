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
  enable_rbac_authorization       = false
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


resource "azurerm_key_vault_access_policy" "secrets-kv_global-subscription-owner" {
  object_id    = azuread_group.global-owner-group.object_id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  key_vault_id = azurerm_key_vault.secrets-kv.id

  key_permissions = ["Backup", "Create", "Decrypt", "Delete", "Encrypt", "Get", "Import", "List", "Purge", "Recover", "Restore", "Sign", "UnwrapKey", "Update", "Verify", "WrapKey", "Release", "Rotate", "GetRotationPolicy", "SetRotationPolicy"]

  secret_permissions      = ["Set", "Get", "Delete", "Purge", "Recover", "List", "Backup", "Restore"]
  certificate_permissions = ["Backup", "Create", "Delete", "DeleteIssuers", "Get", "GetIssuers", "Import", "List", "ListIssuers", "ManageContacts", "ManageIssuers", "Purge", "Recover", "Restore", "SetIssuers", "Update"]

}
