# main.tf — Challenge 03 resiliency: Azure Backup (Recovery Services vault + VM
# backup policy), optional protected VM, and Microsoft Defender for Servers Plan 2.
#
# Built "Azure Verified Modules first": the vault, backup policy and protected
# item come from the official AVM recoveryservices-vault module. Defender for
# Servers is a subscription-scoped pricing setting with no AVM module, so it uses
# a raw azurerm resource (the same justified-exception pattern as the base VM).

locals {
  suffix = "mhb-${var.initials}"

  # Reuse the shared base resource group and VM unless explicitly overridden.
  resource_group_name = coalesce(var.resource_group_name, "rg-${local.suffix}")
  base_vm_name        = coalesce(var.vm_name, "vm-${local.suffix}")

  vault_name         = "rsv-${local.suffix}-03"
  backup_policy_name = "bkpol-${local.suffix}-03"

  # Stream vault job/diagnostic logs to the shared workspace when one is supplied.
  diagnostic_settings = var.log_analytics_workspace_id == null ? {} : {
    to_law = {
      name                  = "diag-to-law"
      workspace_resource_id = var.log_analytics_workspace_id
      log_groups            = ["allLogs"]
      metric_categories     = ["AllMetrics"]
    }
  }

  # Register the base VM as a protected item only when explicitly opted in.
  backup_protected_vm = var.protect_base_vm ? {
    base_vm = {
      source_vm_id          = data.azurerm_virtual_machine.base[0].id
      vm_backup_policy_name = local.backup_policy_name
    }
  } : {}
}

# ---------------------------------------------------------------------------
# Existing base VM (looked up only when protecting it) — created by the
# shared base environment in infra/terraform/base.
# ---------------------------------------------------------------------------
data "azurerm_virtual_machine" "base" {
  count               = var.protect_base_vm ? 1 : 0
  name                = local.base_vm_name
  resource_group_name = local.resource_group_name
}

# ---------------------------------------------------------------------------
# Recovery Services vault + VM backup policy (+ optional protected VM) — AVM
# ---------------------------------------------------------------------------
module "recovery_services_vault" {
  source  = "Azure/avm-res-recoveryservices-vault/azurerm"
  version = "1.3.3"

  name                = local.vault_name
  location            = var.location
  resource_group_name = local.resource_group_name
  sku                 = "Standard"
  tags                = var.tags
  enable_telemetry    = true

  # Cost-guarded lab defaults: LRS storage, no cross-region restore.
  storage_mode_type            = var.storage_mode_type
  cross_region_restore_enabled = false

  # Soft delete protects recovery points from accidental/malicious deletion.
  soft_delete_enabled = "Enabled"

  diagnostic_settings = local.diagnostic_settings

  # A single daily V2 VM backup policy with a short, lab-friendly retention.
  vm_backup_policy = {
    daily = {
      name                           = local.backup_policy_name
      timezone                       = var.backup_timezone
      policy_type                    = "V2"
      frequency                      = "Daily"
      instant_restore_retention_days = 2
      retention_daily                = var.retention_daily_count
      backup = {
        time = var.vm_backup_time
      }
      retention_weekly = {
        count    = 4
        weekdays = ["Sunday"]
      }
    }
  }

  # Empty unless protect_base_vm = true (see locals).
  backup_protected_vm = local.backup_protected_vm
}

# ---------------------------------------------------------------------------
# Microsoft Defender for Servers Plan 2 (subscription-scoped, raw azurerm)
# ---------------------------------------------------------------------------
# No AVM module exists for the security-center pricing setting, and it applies
# at subscription scope rather than to a resource — so a raw resource is the
# correct, justified exception. Revert to "Free" at teardown (see assets runbook).
resource "azurerm_security_center_subscription_pricing" "defender_for_servers" {
  count = var.enable_defender_for_servers ? 1 : 0

  tier          = "Standard"
  resource_type = "VirtualMachines"
  subplan       = "P2"
}
