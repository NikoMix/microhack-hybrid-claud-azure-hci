# main.tf — Challenge 02: Hybrid observability & lifecycle.
#
# Built "Azure Verified Modules first":
#   - Data Collection Rules        -> Azure/avm-res-insights-datacollectionrule
#   - Update Manager maintenance   -> Azure/avm-res-maintenance-maintenanceconfiguration
# Raw azurerm_* resources are used only where no AVM module exists today
# (DCR associations, action group, scheduled-query alert, workbook, dynamic
# maintenance assignment) — each is justified inline.
#
# Everything reuses the shared base Log Analytics workspace (var.log_analytics_workspace_id,
# from base output `log_analytics_workspace_id`) and lands in the base resource group.

data "azurerm_client_config" "current" {}

locals {
  suffix    = "mhb-${var.initials}"
  challenge = "02"

  # Default to the shared base resource group unless overridden.
  resource_group_name = coalesce(var.resource_group_name, "rg-${local.suffix}")
  resource_group_id   = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${local.resource_group_name}"

  dcr_vminsights_name     = "dcr-vminsights-${local.suffix}-${local.challenge}"
  dcr_changetracking_name = "dcr-changetracking-${local.suffix}-${local.challenge}"
  action_group_name       = "ag-${local.suffix}-${local.challenge}"
  action_group_short      = "mhb${var.initials}02"
  alert_rule_name         = "alert-heartbeat-${local.suffix}-${local.challenge}"
  workbook_display_name   = "Hybrid Observability — ${local.suffix}-${local.challenge}"
  maintenance_config_name = "mc-${local.suffix}-${local.challenge}"
  dynamic_scope_name      = "mds-${local.suffix}-${local.challenge}"

  # Built-in streams emitted by the Change Tracking & Inventory AMA extension.
  ct_streams = ["Microsoft-ConfigurationChange", "Microsoft-ConfigurationChangeV2", "Microsoft-ConfigurationData"]
}

# ---------------------------------------------------------------------------
# VM Insights Data Collection Rule (AVM)
# Performance counters (InsightsMetrics) + Service Map (DependencyAgent), routed
# to the shared base Log Analytics workspace. This is the canonical VM Insights
# DCR for Linux/Arc machines.
# ---------------------------------------------------------------------------
module "dcr_vminsights" {
  # checkov:skip=CKV_TF_1:Registry-pinned Azure Verified Module (AVM-first repo convention); commit-hash pinning does not apply to Terraform Registry sources.
  source  = "Azure/avm-res-insights-datacollectionrule/azurerm"
  version = "0.1.0"

  name             = local.dcr_vminsights_name
  location         = var.location
  parent_id        = local.resource_group_id
  kind             = "Linux"
  tags             = var.tags
  enable_telemetry = true
  description      = "VM Insights performance + Service Map for the hybrid server-to-migrate."

  data_sources = {
    performance_counters = [{
      name                          = "VMInsightsPerfCounters"
      streams                       = ["Microsoft-InsightsMetrics"]
      sampling_frequency_in_seconds = 60
      counter_specifiers            = ["\\VmInsights\\DetailedMetrics"]
    }]
    extensions = [{
      name           = "DependencyAgentDataSource"
      streams        = ["Microsoft-ServiceMap"]
      extension_name = "DependencyAgent"
    }]
  }

  destinations = {
    log_analytics = [{
      name                  = "VMInsightsPerf-Logs-Dest"
      workspace_resource_id = var.log_analytics_workspace_id
    }]
  }

  data_flows = [
    {
      streams      = ["Microsoft-InsightsMetrics"]
      destinations = ["VMInsightsPerf-Logs-Dest"]
    },
    {
      streams      = ["Microsoft-ServiceMap"]
      destinations = ["VMInsightsPerf-Logs-Dest"]
    },
  ]
}

# ---------------------------------------------------------------------------
# Change Tracking & Inventory Data Collection Rule (AVM)
# Linux ChangeTracking AMA extension -> base Log Analytics workspace.
# Settings follow the Microsoft-documented Linux baseline (files/software/
# services/inventory). One Change Tracking DCR may be associated per machine.
# ---------------------------------------------------------------------------
module "dcr_changetracking" {
  # checkov:skip=CKV_TF_1:Registry-pinned Azure Verified Module (AVM-first repo convention); commit-hash pinning does not apply to Terraform Registry sources.
  source  = "Azure/avm-res-insights-datacollectionrule/azurerm"
  version = "0.1.0"

  count = var.enable_change_tracking ? 1 : 0

  name             = local.dcr_changetracking_name
  location         = var.location
  parent_id        = local.resource_group_id
  kind             = "Linux"
  tags             = var.tags
  enable_telemetry = true
  description      = "Change Tracking & Inventory (Linux) for the hybrid server-to-migrate."

  data_sources = {
    extensions = [{
      name           = "CTDataSource-Linux"
      streams        = local.ct_streams
      extension_name = "ChangeTracking-Linux"
      extension_settings = {
        enableFiles     = true
        enableSoftware  = true
        enableRegistry  = false
        enableServices  = true
        enableInventory = true
        fileSettings = {
          fileCollectionFrequency = 900
          fileInfo = [{
            name                  = "ChangeTrackingLinuxPath_default"
            enabled               = true
            destinationPath       = "/etc/.*.conf"
            useSudo               = true
            recurse               = true
            maxContentsReturnable = 5000000
            pathType              = "File"
            type                  = "File"
            links                 = "Follow"
            maxOutputSize         = 500000
            groupTag              = "Recommended"
          }]
        }
        softwareSettings  = { softwareCollectionFrequency = 300 }
        inventorySettings = { inventoryCollectionFrequency = 36000 }
        servicesSettings  = { serviceCollectionFrequency = 300 }
      }
    }]
  }

  destinations = {
    log_analytics = [{
      name                  = "Microsoft-CT-Dest"
      workspace_resource_id = var.log_analytics_workspace_id
    }]
  }

  data_flows = [{
    streams      = local.ct_streams
    destinations = ["Microsoft-CT-Dest"]
  }]
}

# ---------------------------------------------------------------------------
# Data Collection Rule associations (raw azurerm — no AVM module for the
# association resource). Conditional on a monitored target being supplied, so
# the rules can be planned/validated before the Arc server exists.
# ---------------------------------------------------------------------------
resource "azurerm_monitor_data_collection_rule_association" "vminsights" {
  count = var.monitored_resource_id == null ? 0 : 1

  name                    = "vminsights-dcra"
  target_resource_id      = var.monitored_resource_id
  data_collection_rule_id = module.dcr_vminsights.resource_id
  description             = "Associates the VM Insights DCR with the monitored hybrid machine."
}

resource "azurerm_monitor_data_collection_rule_association" "changetracking" {
  count = (var.monitored_resource_id == null || !var.enable_change_tracking) ? 0 : 1

  name                    = "changetracking-dcra"
  target_resource_id      = var.monitored_resource_id
  data_collection_rule_id = module.dcr_changetracking[0].resource_id
  description             = "Associates the Change Tracking & Inventory DCR with the monitored hybrid machine."
}

# ---------------------------------------------------------------------------
# Action group (raw azurerm — no AVM module). Optional email receiver.
# ---------------------------------------------------------------------------
resource "azurerm_monitor_action_group" "ops" {
  name                = local.action_group_name
  resource_group_name = local.resource_group_name
  short_name          = local.action_group_short
  tags                = var.tags

  dynamic "email_receiver" {
    for_each = var.alert_email == null ? [] : [var.alert_email]
    content {
      name                    = "ops-email"
      email_address           = email_receiver.value
      use_common_alert_schema = true
    }
  }
}

# ---------------------------------------------------------------------------
# Heartbeat-missing alert (raw azurerm — no AVM module for scheduled query
# rules). Fires when a recently-reporting hybrid machine stops sending Log
# Analytics heartbeats. Works for both Azure VMs and Arc-enabled servers.
# ---------------------------------------------------------------------------
resource "azurerm_monitor_scheduled_query_rules_alert_v2" "heartbeat" {
  name                = local.alert_rule_name
  resource_group_name = local.resource_group_name
  location            = var.location

  evaluation_frequency = "PT5M"
  window_duration      = "PT10M"
  scopes               = [var.log_analytics_workspace_id]
  severity             = 1
  enabled              = true

  criteria {
    query                   = <<-KQL
      Heartbeat
      | summarize LastHeartbeat = max(TimeGenerated) by Computer, _ResourceId
      | where LastHeartbeat < ago(5m)
    KQL
    time_aggregation_method = "Count"
    threshold               = 0
    operator                = "GreaterThan"
    resource_id_column      = "_ResourceId"

    failing_periods {
      minimum_failing_periods_to_trigger_alert = 1
      number_of_evaluation_periods             = 1
    }
  }

  # Look back 6h so a machine that stops reporting is still detected after the
  # 10-minute evaluation window has emptied of fresh heartbeats.
  query_time_range_override = "PT6H"
  auto_mitigation_enabled   = true
  description               = "A monitored hybrid machine has not sent a Log Analytics heartbeat in over 5 minutes. Investigate the Azure Monitor Agent and connectivity."
  display_name              = "Heartbeat missing — ${local.suffix}-${local.challenge}"
  tags                      = var.tags

  action {
    action_groups = [azurerm_monitor_action_group.ops.id]
  }
}

# ---------------------------------------------------------------------------
# Azure Monitor workbook (raw azurerm — no AVM module). Name must be a
# lowercase GUID; the workbook content ships in assets/ as the auditable
# evidence artifact and is loaded verbatim.
# ---------------------------------------------------------------------------
resource "random_uuid" "workbook" {}

resource "azurerm_application_insights_workbook" "observability" {
  name                = random_uuid.workbook.result
  resource_group_name = local.resource_group_name
  location            = var.location
  display_name        = local.workbook_display_name
  description         = "Hybrid observability workbook: heartbeat, VM Insights performance, change tracking and update status for the Module B microhack."
  data_json           = file("${path.module}/../assets/hybrid-observability-workbook.json")
  tags                = var.tags
}

# ---------------------------------------------------------------------------
# Azure Update Manager maintenance configuration (AVM) — the reusable patch
# schedule that doubles as a B.4.2 onboarding asset (config-as-code).
# ---------------------------------------------------------------------------
module "maintenance_config" {
  # checkov:skip=CKV_TF_1:Registry-pinned Azure Verified Module (AVM-first repo convention); commit-hash pinning does not apply to Terraform Registry sources.
  source  = "Azure/avm-res-maintenance-maintenanceconfiguration/azurerm"
  version = "0.1.0"

  name                = local.maintenance_config_name
  location            = var.location
  resource_group_name = local.resource_group_name
  scope               = "InGuestPatch"
  subscription_id     = data.azurerm_client_config.current.subscription_id
  enable_telemetry    = true
  tags                = var.tags

  install_patches = {
    reboot_setting = var.maintenance_reboot_setting
    linux = {
      classifications_to_include = var.maintenance_classifications
    }
  }

  window = {
    start_date_time = var.maintenance_start_date_time
    time_zone       = var.maintenance_time_zone
    recur_every     = var.maintenance_recur_every
    duration        = var.maintenance_duration
  }
}

# ---------------------------------------------------------------------------
# Dynamic maintenance assignment (raw azurerm — no AVM module). Modern Update
# Manager "dynamic scoping": the schedule auto-applies to every Linux Azure VM
# and Arc-enabled machine in the resource group, so newly onboarded servers
# inherit patching without per-machine wiring. Targets must run
# AutomaticByPlatform patch orchestration (set by the Challenge 02 scripts).
# ---------------------------------------------------------------------------
resource "azurerm_maintenance_assignment_dynamic_scope" "patch" {
  count = var.enable_dynamic_maintenance_assignment ? 1 : 0

  name                         = local.dynamic_scope_name
  maintenance_configuration_id = module.maintenance_config.resource_id

  filter {
    locations       = [var.location]
    os_types        = ["Linux"]
    resource_groups = [local.resource_group_name]
    resource_types  = ["Microsoft.Compute/virtualMachines", "Microsoft.HybridCompute/machines"]
  }
}
