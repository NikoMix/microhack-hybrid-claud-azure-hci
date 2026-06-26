# variables.tf — typed, documented inputs for Challenge 02 (observability).

variable "subscription_id" {
  type        = string
  default     = null
  description = "Azure subscription ID to deploy into. Leave null to use the ARM_SUBSCRIPTION_ID environment variable (set via `export ARM_SUBSCRIPTION_ID=$(az account show --query id -o tsv)`)."
}

variable "location" {
  type        = string
  default     = "swedencentral"
  description = "Azure region for the observability resources. Should match the shared base environment region."
}

variable "initials" {
  type        = string
  description = "Pupil initials used to make resource names unique (e.g. \"abc\"). Keep it short (2-5 lowercase alphanumeric characters)."

  validation {
    condition     = can(regex("^[a-z0-9]{2,5}$", var.initials))
    error_message = "initials must be 2-5 lowercase alphanumeric characters."
  }
}

variable "resource_group_name" {
  type        = string
  default     = null
  description = "Resource group that hosts the observability resources. Leave null to default to the shared base resource group `rg-mhb-<initials>`."
}

variable "log_analytics_workspace_id" {
  type        = string
  description = "Resource ID of the Log Analytics workspace to reuse. Comes from the shared base environment output `log_analytics_workspace_id` (run `terraform -chdir=../../infra/terraform/base output -raw log_analytics_workspace_id`)."

  validation {
    condition     = can(regex("(?i)/providers/Microsoft.OperationalInsights/workspaces/", var.log_analytics_workspace_id))
    error_message = "log_analytics_workspace_id must be a Log Analytics workspace resource ID (.../providers/Microsoft.OperationalInsights/workspaces/<name>)."
  }
}

variable "monitored_resource_id" {
  type        = string
  default     = null
  description = "Resource ID of the machine to monitor — the Azure Arc-enabled server (Microsoft.HybridCompute/machines/...) onboarded in Challenge 01, or the base Azure VM (Microsoft.Compute/virtualMachines/...). Leave null to provision the rules without binding them to a target yet; set it to create the Data Collection Rule associations."
}

variable "alert_email" {
  type        = string
  default     = null
  description = "Optional email address to receive alert notifications via the action group. Leave null to create the action group without an email receiver (you can add receivers later)."

  validation {
    condition     = var.alert_email == null || can(regex("^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$", coalesce(var.alert_email, "")))
    error_message = "alert_email must be a valid email address or null."
  }
}

variable "enable_change_tracking" {
  type        = bool
  default     = true
  description = "Create a Change Tracking & Inventory Data Collection Rule (Linux, Azure Monitoring Agent) in addition to the VM Insights DCR."
}

variable "enable_dynamic_maintenance_assignment" {
  type        = bool
  default     = true
  description = "Assign the Update Manager maintenance configuration to the resource group via a dynamic scope (modern dynamic scoping) so the base VM and any Arc-enabled machine inherit the patch schedule. Targets still need AutomaticByPlatform patch orchestration (set by the Challenge 02 scripts/README)."
}

variable "maintenance_recur_every" {
  type        = string
  default     = "1Day"
  description = "Recurrence for the Update Manager maintenance window (e.g. \"1Day\", \"1Week\", \"Month Third Sunday\")."
}

variable "maintenance_start_date_time" {
  type        = string
  default     = "2026-01-05 02:00"
  description = "Effective start of the maintenance window in 'YYYY-MM-DD hh:mm' format. A past anchor is valid for recurring schedules — Azure computes the next occurrence."

  validation {
    condition     = can(regex("^\\d{4}-\\d{2}-\\d{2} \\d{2}:\\d{2}$", var.maintenance_start_date_time))
    error_message = "maintenance_start_date_time must match 'YYYY-MM-DD hh:mm'."
  }
}

variable "maintenance_time_zone" {
  type        = string
  default     = "W. Europe Standard Time"
  description = "Time zone for the maintenance window (Windows time-zone ID). List them with `[System.TimeZoneInfo]::GetSystemTimeZones()`."
}

variable "maintenance_duration" {
  type        = string
  default     = "02:00"
  description = "Maintenance window duration in HH:mm format (minimum 01:30, maximum 04:00 for InGuestPatch)."
}

variable "maintenance_reboot_setting" {
  type        = string
  default     = "IfRequired"
  description = "Reboot behaviour after patching. One of Always, IfRequired, Never."

  validation {
    condition     = contains(["Always", "IfRequired", "Never"], var.maintenance_reboot_setting)
    error_message = "maintenance_reboot_setting must be one of: Always, IfRequired, Never."
  }
}

variable "maintenance_classifications" {
  type        = list(string)
  default     = ["Critical", "Security"]
  description = "Linux patch classifications to include in the maintenance configuration (e.g. Critical, Security, Other)."
}

variable "tags" {
  type = map(string)
  default = {
    workload    = "azure-local-microhack"
    environment = "lab"
    challenge   = "02-observability"
  }
  description = "Tags applied to every resource created by this challenge."
}
