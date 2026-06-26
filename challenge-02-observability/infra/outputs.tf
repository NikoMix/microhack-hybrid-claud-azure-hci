# outputs.tf — documented outputs for Challenge 02 (observability).

output "resource_group_name" {
  description = "Resource group hosting the Challenge 02 observability resources."
  value       = local.resource_group_name
}

output "dcr_vminsights_id" {
  description = "Resource ID of the VM Insights Data Collection Rule."
  value       = module.dcr_vminsights.resource_id
}

output "dcr_changetracking_id" {
  description = "Resource ID of the Change Tracking & Inventory Data Collection Rule (null when enable_change_tracking = false)."
  value       = try(module.dcr_changetracking[0].resource_id, null)
}

output "action_group_id" {
  description = "Resource ID of the operations action group used by the alert rule."
  value       = azurerm_monitor_action_group.ops.id
}

output "alert_rule_id" {
  description = "Resource ID of the heartbeat-missing scheduled query alert rule."
  value       = azurerm_monitor_scheduled_query_rules_alert_v2.heartbeat.id
}

output "workbook_id" {
  description = "Resource ID of the hybrid observability Azure Monitor workbook."
  value       = azurerm_application_insights_workbook.observability.id
}

output "maintenance_configuration_id" {
  description = "Resource ID of the Azure Update Manager maintenance configuration."
  value       = module.maintenance_config.resource_id
}

output "monitored_resource_id" {
  description = "Resource ID of the machine the DCRs were associated with (null when not yet supplied)."
  value       = var.monitored_resource_id
}
