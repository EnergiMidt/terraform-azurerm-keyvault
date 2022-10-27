locals {
  name     = var.override_name == null ? "${var.system_name}-${lower(var.environment)}-kv" : var.override_name
  location = var.override_location == null ? var.resource_group.location : var.override_location
}

resource "azurerm_key_vault" "key_vault" {
  name                = local.name
  location            = local.location
  resource_group_name = var.resource_group.name

  sku_name  = var.sku_name
  tenant_id = var.tenant_id

  dynamic "access_policy" {
    for_each = try(var.configuration.access_policy, null) != null ? [var.configuration.access_policy] : []
    content {
      tenant_id = try(var.configuration.access_policy.tenant_id, null)
      object_id = try(var.configuration.access_policy.object_id, null)

      certificate_permissions = try(var.configuration.access_policy.certificate_permissions, null)

      key_permissions = try(var.configuration.access_policy.key_permissions, null)

      secret_permissions = try(var.configuration.access_policy.secret_permissions, null)

      storage_permissions = try(var.configuration.access_policy.storage_permissions, null)
    }
  } # (Optional) A list of up to 16 objects describing access policies, as described above.

  enabled_for_deployment          = try(var.enabled_for_deployment, null)
  enabled_for_disk_encryption     = try(var.enabled_for_disk_encryption, null)
  enabled_for_template_deployment = try(var.enabled_for_template_deployment, null)
  enable_rbac_authorization       = try(var.enable_rbac_authorization, null)

  dynamic "network_acls" {
    for_each = try(var.configuration.network_acls, null) != null ? [var.configuration.network_acls] : []
    content {
      bypass                     = var.configuration.network_acls.bypass
      default_action             = var.configuration.network_acls.default_action
      ip_rules                   = try(var.configuration.network_acls.ip_rules, null)
      virtual_network_subnet_ids = try(var.configuration.network_acls.virtual_network_subnet_ids, null)
    }
  }

  # network_acls {
  #   bypass = var.network_acls_bypass
  #   # checkov:skip=CKV_AZURE_109: The `default_action` variable defaults to Allow.
  #   # https://docs.bridgecrew.io/docs/ensure-azure-cosmosdb-has-local-authentication-disabled
  #   # tfsec:ignore:azure-keyvault-specify-network-acl
  #   default_action             = var.network_acls_default_action
  #   ip_rules                   = var.network_acls_ip_rules
  #   virtual_network_subnet_ids = var.network_acls_virtual_network_subnet_ids
  # }

  # https://docs.bridgecrew.io/docs/ensure-the-key-vault-is-recoverable
  # checkov:skip=CKV_AZURE_42: The `purge_protection_enabled` variable defaults to false.
  # https://docs.bridgecrew.io/docs/ensure-that-key-vault-enables-purge-protection
  # checkov:skip=CKV_AZURE_110: The `purge_protection_enabled` variable defaults to false.
  # https://aquasecurity.github.io/tfsec/v1.28.0/checks/azure/keyvault/no-purge/
  # tfsec:ignore:azure-keyvault-no-purge

  purge_protection_enabled      = try(var.purge_protection_enabled, null)
  public_network_access_enabled = try(var.public_network_access_enabled, null)
  soft_delete_retention_days    = try(var.soft_delete_retention_days, null)

  tags = try(var.tags, null)
}
