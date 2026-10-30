# terraform.tf — provider and version constraints for the challenge-04 supporting
# cloud resources (Container Insights DCR + Azure Policy for Kubernetes).
terraform {
  required_version = ">= 1.9"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 5.11"
    }
    # Required transitively by the AVM Data Collection Rule module (it provisions
    # the DCR through azapi and emits module telemetry via modtm).
    azapi = {
      source  = "Azure/azapi"
      version = "~> 2.4"
    }
    modtm = {
      source  = "azure/modtm"
      version = "~> 0.3"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}

provider "azurerm" {
  features {}

  # Falls back to the ARM_SUBSCRIPTION_ID environment variable when null,
  # which the lab instructs pupils to export from `az account show`.
  subscription_id = var.subscription_id
}

# Empty configuration — azapi authenticates the same way as azurerm (Azure CLI
# or ARM_* environment variables). Declared so the AVM DCR module resolves.
provider "azapi" {}
