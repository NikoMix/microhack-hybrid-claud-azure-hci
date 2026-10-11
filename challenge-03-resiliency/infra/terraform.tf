# terraform.tf — provider and version constraints for the Challenge 03
# resiliency module (Recovery Services vault + VM backup policy + Defender for
# Servers Plan 2). Mirrors the shared base environment for consistency.
terraform {
  required_version = ">= 1.9"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 5.9"
    }
  }
}

provider "azurerm" {
  features {}

  # Falls back to the ARM_SUBSCRIPTION_ID environment variable when null,
  # which the README instructs pupils to export from `az account show`.
  subscription_id = var.subscription_id
}
