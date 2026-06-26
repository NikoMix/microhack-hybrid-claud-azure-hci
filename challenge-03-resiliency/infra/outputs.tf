# outputs.tf — handy references for pupils, scripts, and evidence collection.

output "recovery_services_vault_id" {
  description = "Resource ID of the Recovery Services vault."
  value       = module.recovery_services_vault.resource_id
}

output "recovery_services_vault_name" {
  description = "Name of the Recovery Services vault."
  value       = local.vault_name
}

output "vm_backup_policy_name" {
  description = "Name of the VM backup policy to attach protected VMs to."
  value       = local.backup_policy_name
}

output "protected_vm_enabled" {
  description = "Whether the base VM is registered as a protected backup item (driven by var.protect_base_vm)."
  value       = var.protect_base_vm
}

output "protected_vm_name" {
  description = "Name of the base VM targeted for protection (only meaningful when protected_vm_enabled is true)."
  value       = local.base_vm_name
}

output "resource_group_name" {
  description = "Resource group the vault was deployed into (the shared base resource group)."
  value       = local.resource_group_name
}

output "defender_for_servers_plan2_enabled" {
  description = "Whether Microsoft Defender for Servers Plan 2 was enabled by this module (driven by var.enable_defender_for_servers)."
  value       = var.enable_defender_for_servers
}
