# variables.tf — typed, documented inputs for the Challenge 03 resiliency module.

variable "subscription_id" {
  type        = string
  default     = null
  description = "Azure subscription ID to deploy into. Leave null to use the ARM_SUBSCRIPTION_ID environment variable (set via `export ARM_SUBSCRIPTION_ID=$(az account show --query id -o tsv)`)."
}

variable "location" {
  type        = string
  default     = "swedencentral"
  description = "Azure region for the Recovery Services vault. Default swedencentral; should match the shared base environment region."
}

variable "initials" {
  type        = string
  description = "Pupil initials used to make resource names unique (e.g. \"abc\"). Must match the initials used for the shared base environment. Keep it short (2-5 lowercase alphanumeric characters)."

  validation {
    condition     = can(regex("^[a-z0-9]{2,5}$", var.initials))
    error_message = "initials must be 2-5 lowercase alphanumeric characters."
  }
}

variable "resource_group_name" {
  type        = string
  default     = null
  description = "Name of the EXISTING resource group (created by the shared base environment) to deploy the vault into. Leave null to derive `rg-mhb-<initials>`."
}

variable "vm_name" {
  type        = string
  default     = null
  description = "Name of the EXISTING base \"server to migrate\" VM to protect with backup. Leave null to derive `vm-mhb-<initials>`. Only used when `protect_base_vm = true`."
}

variable "protect_base_vm" {
  type        = bool
  default     = false
  description = "When true, register the base VM as a protected item against the VM backup policy. Requires the base VM to already exist and be running. Kept false by default so the module deploys (vault + policy) before the VM is backed up."
}

variable "vm_backup_time" {
  type        = string
  default     = "23:00"
  description = "Daily backup time in 24-hour HH:MM format, interpreted in `backup_timezone`. A late-evening time keeps lab backups off the working window."
}

variable "backup_timezone" {
  type        = string
  default     = "W. Europe Standard Time"
  description = "Windows time zone name used by the VM backup policy schedule (e.g. \"W. Europe Standard Time\", \"UTC\")."
}

variable "retention_daily_count" {
  type        = number
  default     = 7
  description = "Number of daily recovery points to retain. Cost-guarded lab default is 7 (one week). Valid range for V2 policies is 1-9999."

  validation {
    condition     = var.retention_daily_count >= 1 && var.retention_daily_count <= 9999
    error_message = "retention_daily_count must be between 1 and 9999."
  }
}

variable "storage_mode_type" {
  type        = string
  default     = "LocallyRedundant"
  description = "Vault backup storage redundancy. Cost-guarded lab default is LocallyRedundant (LRS). Possible values: LocallyRedundant, ZoneRedundant, GeoRedundant."

  validation {
    condition     = contains(["LocallyRedundant", "ZoneRedundant", "GeoRedundant"], var.storage_mode_type)
    error_message = "storage_mode_type must be one of: LocallyRedundant, ZoneRedundant, GeoRedundant."
  }
}

variable "enable_defender_for_servers" {
  type        = bool
  default     = true
  description = "When true, enable Microsoft Defender for Servers Plan 2 (subscription-scoped). Keep the lab window short; revert to Free at teardown. Set false in subscriptions where you may not change the Defender plan."
}

variable "log_analytics_workspace_id" {
  type        = string
  default     = null
  description = "Optional resource ID of the shared Log Analytics workspace (base output `log_analytics_workspace_id`). When set, vault diagnostics (backup/ASR jobs) are streamed to it for centralized evidence."
}

variable "tags" {
  type = map(string)
  default = {
    workload    = "azure-local-microhack"
    environment = "lab"
    challenge   = "03-resiliency"
  }
  description = "Tags applied to the Recovery Services vault."
}
