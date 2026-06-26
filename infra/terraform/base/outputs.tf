# outputs.tf — handy references for pupils and later challenges.

output "resource_group_name" {
  description = "Name of the shared base resource group."
  value       = module.resource_group.name
}

output "log_analytics_workspace_id" {
  description = "Resource ID of the Log Analytics workspace."
  value       = module.log_analytics.resource_id
}

output "log_analytics_workspace_name" {
  description = "Name of the Log Analytics workspace."
  value       = local.workspace_name
}

output "user_assigned_identity_id" {
  description = "Resource ID of the user-assigned managed identity."
  value       = module.user_assigned_identity.resource_id
}

output "user_assigned_identity_principal_id" {
  description = "Principal (object) ID of the user-assigned managed identity, for RBAC role assignments."
  value       = module.user_assigned_identity.principal_id
}

output "vm_name" {
  description = "Name of the workload VM (the \"server to migrate\")."
  value       = azurerm_linux_virtual_machine.vm.name
}

output "vm_public_ip" {
  description = "Public IP address of the workload VM."
  value       = azurerm_public_ip.vm.ip_address
}

output "ssh_command" {
  description = "Ready-to-run SSH command for the workload VM."
  value       = "ssh ${local.admin_username}@${azurerm_public_ip.vm.ip_address} -i ./id_rsa_mhb"
}

output "ssh_private_key" {
  description = "Generated SSH private key (also written to ./id_rsa_mhb)."
  value       = tls_private_key.vm.private_key_pem
  sensitive   = true
}
