# main.tf — challenge-04 supporting cloud resources for "AKS enabled by Azure Arc".
#
# The Arc connection, GitOps (Flux) configuration, and cluster extensions are
# CLI-driven (see ../scripts). This root module provisions the *Azure-side*
# governance and observability artifacts that those CLI steps reference:
#   - a Container Insights Data Collection Rule (Azure Monitor for containers)
#   - an Azure Policy for Kubernetes assignment (pod security baseline)
#
# It builds on the shared base environment (challenge-00) and reads its resource
# group and Log Analytics workspace via data sources, so nothing here is
# duplicated.

locals {
  suffix = "mhb-${var.initials}"

  resource_group_name = "rg-${local.suffix}"
  workspace_name      = "log-${local.suffix}"

  dcr_name               = "dcr-ci-${local.suffix}-04"
  policy_assignment_name = "psb-${local.suffix}-04"

  # Container Insights default stream for the AMA logs agent.
  container_insights_stream = "Microsoft-ContainerInsights-Group-Default"
}

# Shared base resource group (created in challenge-00 / infra/terraform/base).
data "azurerm_resource_group" "base" {
  name = local.resource_group_name
}

# Shared Log Analytics workspace — the Container Insights destination.
data "azurerm_log_analytics_workspace" "base" {
  name                = local.workspace_name
  resource_group_name = data.azurerm_resource_group.base.name
}
