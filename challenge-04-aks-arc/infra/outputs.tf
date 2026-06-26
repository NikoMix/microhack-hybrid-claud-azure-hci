# outputs.tf — documented references for pupils and the helper scripts.

output "container_insights_dcr_id" {
  description = "Resource ID of the Container Insights data collection rule. Reference it when associating the DCR with the Arc-enabled cluster."
  value       = module.container_insights_dcr.resource_id
}

output "container_insights_dcr_name" {
  description = "Name of the Container Insights data collection rule."
  value       = module.container_insights_dcr.name
}

output "policy_assignment_id" {
  description = "Resource ID of the pod security baseline policy assignment scoped to the shared base resource group."
  value       = azurerm_resource_group_policy_assignment.k8s_baseline.id
}

output "policy_assignment_name" {
  description = "Name of the pod security baseline policy assignment."
  value       = azurerm_resource_group_policy_assignment.k8s_baseline.name
}

output "log_analytics_workspace_id" {
  description = "Resource ID of the shared Log Analytics workspace used as the Container Insights destination (pass to az k8s-extension)."
  value       = data.azurerm_log_analytics_workspace.base.id
}
