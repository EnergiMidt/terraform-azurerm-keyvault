locals {
  name = var.override_name == null ? "${var.system_name}-${lower(var.environment)}-kv" : var.override_name
}

resource "azurerm_key_vault" "key_vault" {
  name                = local.name
  location            = var.resource_group.location
  resource_group_name = var.resource_group.name

  sku_name  = var.sku_name
  tenant_id = var.tenant_id
  // access_policy
  enabled_for_deployment          = var.enabled_for_deployment
  enabled_for_disk_encryption     = var.enabled_for_disk_encryption
  enabled_for_template_deployment = var.enabled_for_template_deployment
  enable_rbac_authorization       = var.enable_rbac_authorization

  network_acls {
    bypass = var.network_acls_bypass
    # checkov:skip=CKV_AZURE_109: The `default_action` variable defaults to Allow.
    # https://docs.bridgecrew.io/docs/ensure-azure-cosmosdb-has-local-authentication-disabled
    # tfsec:ignore:azure-keyvault-specify-network-acl
    default_action             = var.network_acls_default_action
    ip_rules                   = var.network_acls_ip_rules
    virtual_network_subnet_ids = var.network_acls_virtual_network_subnet_ids
  }

  # https://docs.bridgecrew.io/docs/ensure-the-key-vault-is-recoverable
  # checkov:skip=CKV_AZURE_42: The `purge_protection_enabled` variable defaults to false.
  # https://docs.bridgecrew.io/docs/ensure-that-key-vault-enables-purge-protection
  # checkov:skip=CKV_AZURE_110: The `purge_protection_enabled` variable defaults to false.
  # https://aquasecurity.github.io/tfsec/v1.28.0/checks/azure/keyvault/no-purge/
  # tfsec:ignore:azure-keyvault-no-purge
  purge_protection_enabled      = var.purge_protection_enabled
  public_network_access_enabled = var.public_network_access_enabled
  soft_delete_retention_days    = var.soft_delete_retention_days

  tags = var.tags
}

resource "azurerm_key_vault_access_policy" "access_policy" {
  key_vault_id = azurerm_key_vault.key_vault.id
  tenant_id    = var.tenant_id
  object_id    = var.object_id

  key_permissions = [
    # "Backup",
    # "Create",
    # "Decrypt",
    # "Delete",
    # "Encrypt",
    # "Get",
    # "Import",
    # "List",
    # "Purge",
    # "Recover",
    # "Restore",
    # "Sign",
    # "UnwrapKey",
    # "Update",
    # "Verify",
    # "WrapKey",
    # "Release",
    # "Rotate",
    # "GetRotationPolicy",
    # "SetRotationPolicy",
  ]

  secret_permissions = [
    "Backup",
    "Delete",
    "Get",
    "List",
    "Purge",
    "Recover",
    "Restore",
    "Set",
  ]
}
