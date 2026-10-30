# terraform.tf — provider and version constraints for Challenge 02 (observability).
terraform {
  required_version = ">= 1.9"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 5.11"
    }
    # Required transitively by the AVM maintenance-configuration module, which
    # provisions the Microsoft.Maintenance resource via azapi. Declared here so
    # the root pins an explicit version.
    azapi = {
      source  = "Azure/azapi"
      version = "~> 2.10"
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
  # mirroring the shared base environment.
  subscription_id = var.subscription_id
}

provider "azapi" {}
