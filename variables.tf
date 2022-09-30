variable "environment" {
  description = "(Required) The name of the environment."
  type        = string
  validation {
    condition = contains([
      "dev",
      "test",
      "prod",
    ], var.environment)
    error_message = "Possible values are dev, test, and prod."
  }
}

variable "name" {
  description = "(Required) The name of the Azure Key Vault."
  type        = string
}

variable "override_name" {
  description = "(Optional) Override the name of the resource. Under normal circumstances, it should not be used."
  default     = ""
  type        = string
}

variable "resource_group" {
  description = "(Required) The resource group in which the Azure Key Vault is created."
  type        = any
}

# This upstream variable is replaced by the use of `resource_group` variable.
# variable "resource_group_name" {
#   description = "(Required) The name of the resource group in which the Log Analytics workspace is created. Changing this forces a new resource to be created."
#   type        = string
# }

# This upstream variable is replaced by the use of `resource_group` variable.
# variable "location" {
#   description = "(Required) Specifies the supported Azure location where the resource exists. Changing this forces a new resource to be created."
#   type        = string
# }

variable "sku_name" {
  description = "(Optional) The Name of the SKU used for this Key Vault. Possible values are `standard` and `premium`."
  type        = string
  default     = "standard"
  validation {
    condition     = can(regex("^(standard|premium)$", var.sku_name))
    error_message = "Possible values are `standard` and `premium`."
  }
}

variable "tenant_id" {
  default  = "00000000-0000-0000-0000-000000000000"
  nullable = false
  type     = string
  validation {
    condition     = can(regex("^[0-9a-fA-F]{8}\\b-[0-9a-fA-F]{4}\\b-[0-9a-fA-F]{4}\\b-[0-9a-fA-F]{4}\\b-[0-9a-fA-F]{12}$", var.tenant_id))
    error_message = "The tenant_id value must be a valid globally unique identifier (GUID)."
  }
}

# Use separate `azurerm_key_vault_access_policy` resource to configure `access_policy` variable.
# Since access_policy can be configured both inline and via the separate `azurerm_key_vault_access_policy` resource, we have to explicitly set it to empty slice ([]) to remove it.
# variable "access_policy " {
#   description = "(Optional) A list of up to 16 objects describing access policies, as described below."
#   type = list(object(
#     {
#       application_id          = string
#       certificate_permissions = list(string)
#       key_permissions         = list(string)
#       object_id               = string
#       secret_permissions      = list(string)
#       storage_permissions     = list(string)
#       tenant_id               = string
#     }
#   ))
#   default = null
# }

variable "enabled_for_deployment" {
  description = "(Optional) Boolean flag to specify whether Azure Virtual Machines are permitted to retrieve certificates stored as secrets from the key vault. Defaults to `false`."
  type        = bool
  default     = false
}

variable "enabled_for_disk_encryption" {
  description = "(Optional) Boolean flag to specify whether Azure Disk Encryption is permitted to retrieve secrets from the vault and unwrap keys. Defaults to `false`."
  type        = bool
  default     = false
}

variable "enabled_for_template_deployment" {
  description = "(Optional) Boolean flag to specify whether Azure Resource Manager is permitted to retrieve secrets from the key vault. Defaults to `false`."
  type        = bool
  default     = false
}

variable "enable_rbac_authorization" {
  description = "(Optional) Boolean flag to specify whether Azure Key Vault uses Role Based Access Control (RBAC) for authorization of data actions. Defaults to `false`."
  type        = bool
  default     = false
}

variable "network_acls_bypass" {
  description = "(Required) Specifies which traffic can bypass the network rules. Possible values are `AzureServices` and `None`."
  type        = string
  default     = "AzureServices"
  validation {
    condition     = can(regex("^(AzureServices|None)$", var.network_acls_bypass))
    error_message = "Possible values are `AzureServices` and `None`."
  }
}

# azure-keyvault-specify-network-acl
# https://aquasecurity.github.io/tfsec/v1.28.0/checks/azure/keyvault/specify-network-acl/
variable "network_acls_default_action" {
  description = "(Required) The Default Action to use when no rules match from `ip_rules` / `virtual_network_subnet_ids`. Possible values are `Allow` and `Deny`. Upstream defaults to `Allow`. Defaults to `Deny` in this module."
  type        = string
  default     = "Deny"
  validation {
    condition     = can(regex("^(Allow|Deny)$", var.network_acls_default_action))
    error_message = "Possible values are `Allow` and `Deny`."
  }
}

variable "network_acls_ip_rules" {
  description = "(Optional) One or more IP Addresses, or CIDR Blocks which should be able to access the Key Vault."
  type        = list(string)
  default     = []
}

variable "network_acls_virtual_network_subnet_ids" {
  description = "(Optional) One or more Subnet IDs which should be able to access this Key Vault."
  type        = list(string)
  default     = []
}

# azure-keyvault-no-purge
# https://aquasecurity.github.io/tfsec/v1.28.0/checks/azure/keyvault/no-purge/
variable "purge_protection_enabled" {
  description = "(Optional) Is Purge Protection enabled for this Key Vault? Upstream defaults to `false`. Defaults to `true` in this module."
  type        = bool
  default     = true
}

variable "public_network_access_enabled" {
  description = "(Optional) Whether public network access is allowed for this Key Vault. Defaults to `true`."
  type        = bool
  default     = true
}

variable "soft_delete_retention_days" {
  description = "(Optional) The number of days that items should be retained for once soft-deleted. This value can be between `7` and `90` (the default) days."
  type        = number
  default     = 90
}

# TODO: Fix forbidden access.
# Status=403 Code="Forbidden" Message="The user, group or application 'appid=***;oid=00000000-0000-0000-0000-000000000000;numgroups=0;iss=https://sts.windows.net/***/' does not have certificates managecontacts permission on key vault 'keyvault-name;location=location'.
# variable "contacts_email" {
#   description = "(Required) E-mail address of the contact."
#   type        = string
# }

# TODO: Fix forbidden access.
# Status=403 Code="Forbidden" Message="The user, group or application 'appid=***;oid=00000000-0000-0000-0000-000000000000;numgroups=0;iss=https://sts.windows.net/***/' does not have certificates managecontacts permission on key vault 'keyvault-name;location=location'.
# variable "contacts_name" {
#   description = "(Optional) Name of the contact."
#   type        = string
#   default     = null
# }

# TODO: Fix forbidden access.
# Status=403 Code="Forbidden" Message="The user, group or application 'appid=***;oid=00000000-0000-0000-0000-000000000000;numgroups=0;iss=https://sts.windows.net/***/' does not have certificates managecontacts permission on key vault 'keyvault-name;location=location'.
# variable "contacts_phone" {
#   description = "(Optional) Phone number of the contact."
#   type        = string
#   default     = null
# }

variable "tags" {
  description = "(Optional) A mapping of tags to assign to the resource."
  type        = map(string)
  default     = null # {}
}
