# variables.tf — typed, documented inputs for the Challenge 01 policy assignment.

variable "subscription_id" {
  type        = string
  default     = null
  description = "Azure subscription ID to deploy into. Leave null to use the ARM_SUBSCRIPTION_ID environment variable (set via `export ARM_SUBSCRIPTION_ID=$(az account show --query id -o tsv)`)."
}

variable "location" {
  type        = string
  default     = "swedencentral"
  description = "Azure region for the policy assignment's managed identity. Use the same region as the base environment."
}

variable "initials" {
  type        = string
  description = "Pupil initials used to locate the shared base resource group (rg-mhb-<initials>) and name the assignment. Keep it short (2-5 lowercase alphanumeric characters)."

  validation {
    condition     = can(regex("^[a-z0-9]{2,5}$", var.initials))
    error_message = "initials must be 2-5 lowercase alphanumeric characters."
  }
}

variable "guest_config_policy_definition_id" {
  type        = string
  default     = "/providers/Microsoft.Authorization/policyDefinitions/fc9b3da7-8347-4380-8e70-0a0361d8dedd"
  description = "Built-in policy definition ID for 'Linux machines should meet requirements for the Azure compute security baseline' (guest configuration). Verify the current built-in ID in the Azure Policy built-ins before relying on it in an audit."
}

variable "include_arc_machines" {
  type        = string
  default     = "true"
  description = "Value for the policy's IncludeArcMachines parameter. 'true' brings Azure Arc-enabled servers (like the server-to-migrate) into scope; the policy expects a string, not a bool."

  validation {
    condition     = contains(["true", "false"], var.include_arc_machines)
    error_message = "include_arc_machines must be the string \"true\" or \"false\"."
  }
}

variable "enforce_policy" {
  type        = bool
  default     = false
  description = "Whether the assignment enforces (true) or only audits (false). Keep false for a cost-guarded classroom: the baseline policy is an audit (AuditIfNotExists) policy and should not gate the lab."
}
