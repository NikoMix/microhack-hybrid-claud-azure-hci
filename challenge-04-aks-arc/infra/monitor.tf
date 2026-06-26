# monitor.tf — Container Insights Data Collection Rule (Azure Monitor for containers).
#
# AVM-first: provisioned with the Azure Verified Module for Data Collection Rules,
# pinned to its latest published version. The Container Insights extension
# (installed on the Arc cluster via ../scripts/03-enable-monitor-policy.sh) sends
# the "Microsoft-ContainerInsights-Group-Default" stream to the shared Log
# Analytics workspace through this DCR.
module "container_insights_dcr" {
  source  = "Azure/avm-res-insights-datacollectionrule/azurerm"
  version = "0.1.0"

  name             = local.dcr_name
  location         = var.location
  parent_id        = data.azurerm_resource_group.base.id
  kind             = "Linux"
  tags             = var.tags
  enable_telemetry = true

  destinations = {
    log_analytics = [{
      name                  = "ciworkspace"
      workspace_resource_id = data.azurerm_log_analytics_workspace.base.id
    }]
  }

  data_sources = {
    extensions = [{
      name           = "ContainerInsightsExtension"
      extension_name = "ContainerInsights"
      streams        = [local.container_insights_stream]
      extension_settings = {
        dataCollectionSettings = {
          interval               = "1m"
          namespaceFilteringMode = "Off"
          enableContainerLogV2   = true
        }
      }
    }]
  }

  data_flows = [{
    streams      = [local.container_insights_stream]
    destinations = ["ciworkspace"]
  }]
}
