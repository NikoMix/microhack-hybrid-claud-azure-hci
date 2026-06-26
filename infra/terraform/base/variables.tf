# variables.tf — typed, documented inputs for the shared base environment.

variable "subscription_id" {
  type        = string
  default     = null
  description = "Azure subscription ID to deploy into. Leave null to use the ARM_SUBSCRIPTION_ID environment variable (set via `export ARM_SUBSCRIPTION_ID=$(az account show --query id -o tsv)`)."
}

variable "location" {
  type        = string
  default     = "swedencentral"
  description = "Azure region for all resources in the shared base environment."
}

variable "initials" {
  type        = string
  description = "Pupil initials used to make resource names unique (e.g. \"abc\"). Keep it short (2-5 lowercase alphanumeric characters)."

  validation {
    condition     = can(regex("^[a-z0-9]{2,5}$", var.initials))
    error_message = "initials must be 2-5 lowercase alphanumeric characters."
  }
}

variable "allowed_ssh_source" {
  type        = string
  default     = "0.0.0.0/0"
  description = "Source IP/CIDR allowed to reach the VM over SSH (port 22). WARNING: the default 0.0.0.0/0 opens SSH to the whole internet — set this to your own public IP/CIDR (e.g. \"203.0.113.10/32\") before applying."
}

variable "tags" {
  type = map(string)
  default = {
    workload    = "azure-local-microhack"
    environment = "lab"
  }
  description = "Tags applied to every resource in the shared base environment."
}
