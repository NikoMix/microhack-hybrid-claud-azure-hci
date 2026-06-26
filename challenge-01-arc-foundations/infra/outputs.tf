# outputs.tf — references for pupils and the trainer demo.

output "policy_assignment_id" {
  description = "Resource ID of the guest-configuration policy assignment."
  value       = azurerm_resource_group_policy_assignment.guest_config_baseline.id
}

output "policy_assignment_name" {
  description = "Name of the guest-configuration policy assignment."
  value       = azurerm_resource_group_policy_assignment.guest_config_baseline.name
}

output "policy_assignment_principal_id" {
  description = "Principal (object) ID of the assignment's system-assigned identity, used for guest-configuration remediation role assignments."
  value       = azurerm_resource_group_policy_assignment.guest_config_baseline.identity[0].principal_id
}

output "resource_group_name" {
  description = "Shared base resource group the policy is assigned to."
  value       = data.azurerm_resource_group.base.name
}
