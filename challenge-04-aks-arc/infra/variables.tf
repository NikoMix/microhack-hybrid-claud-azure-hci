# variables.tf — typed, documented inputs for the challenge-04 supporting resources.

variable "subscription_id" {
  type        = string
  default     = null
  description = "Azure subscription ID to deploy into. Leave null to use the ARM_SUBSCRIPTION_ID environment variable (set via `export ARM_SUBSCRIPTION_ID=$(az account show --query id -o tsv)`)."
}

variable "location" {
  type        = string
  default     = "swedencentral"
  description = "Azure region for the challenge-04 supporting resources. Use the same region as the shared base environment."
}

variable "initials" {
  type        = string
  description = "Pupil initials used to resolve the shared base resource names (rg-mhb-<initials>, log-mhb-<initials>). Keep it short (2-5 lowercase alphanumeric characters)."

  validation {
    condition     = can(regex("^[a-z0-9]{2,5}$", var.initials))
    error_message = "initials must be 2-5 lowercase alphanumeric characters."
  }
}

variable "policy_effect" {
  type        = string
  default     = "audit"
  description = "Effect for the Kubernetes pod security baseline initiative. Use \"audit\" in the lab (non-blocking); \"deny\" actively rejects non-compliant workloads; \"disabled\" turns the policies off."

  validation {
    condition     = contains(["audit", "deny", "disabled"], var.policy_effect)
    error_message = "policy_effect must be one of: audit, deny, disabled."
  }
}

variable "policy_enforce" {
  type        = bool
  default     = true
  description = "Whether the policy assignment is enforced. Set to false to create the assignment in \"DoNotEnforce\" mode (evaluates compliance without applying the effect)."
}

variable "policy_excluded_namespaces" {
  type        = list(string)
  default     = ["kube-system", "gatekeeper-system", "azure-arc", "flux-system"]
  description = "Kubernetes namespaces excluded from the pod security baseline initiative (system and platform namespaces)."
}

variable "tags" {
  type = map(string)
  default = {
    workload    = "azure-local-microhack"
    environment = "lab"
    challenge   = "04-aks-arc"
  }
  description = "Tags applied to every resource created by this challenge-04 module."
}
