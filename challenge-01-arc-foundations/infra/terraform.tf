# terraform.tf — provider and version constraints for the Challenge 01 supporting
# resources (the guest-configuration Azure Policy assignment).
terraform {
  required_version = ">= 1.9"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 5.10"
    }
  }
}

provider "azurerm" {
  features {}

  # Falls back to the ARM_SUBSCRIPTION_ID environment variable when null, which
  # the README instructs pupils to export from `az account show`.
  subscription_id = var.subscription_id
}
