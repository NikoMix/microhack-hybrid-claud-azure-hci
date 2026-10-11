# main.tf — Challenge 01 supporting resources.
#
# This standalone root module assigns a built-in **guest-configuration** Azure
# Policy to the shared base resource group so the Arc-enabled "server to migrate"
# is continuously audited against the Azure compute security baseline. This is the
# governance evidence for Module B **B.1.1**.
#
# > AVM exception: there is no Azure Verified Module (`Azure/avm-res-*` /
# > `Azure/avm-ptn-*`) for a single resource-group-scoped policy assignment, so we
# > use the raw `azurerm_resource_group_policy_assignment` resource — the same
# > "raw only when no AVM fits" rule the base module applies to the workload VM.

locals {
  suffix              = "mhb-${var.initials}"
  resource_group_name = "rg-${local.suffix}"
  assignment_name     = "gc-baseline-${local.suffix}-01"
}

# Build on the base environment: look up the resource group created in Challenge 00.
data "azurerm_resource_group" "base" {
  name = local.resource_group_name
}

# Assign the Linux compute security baseline (guest configuration) policy.
# A system-assigned identity is attached so the assignment can deploy the guest
# configuration prerequisites and support remediation — the remediation-ready
# managed-identity pattern partners should demonstrate.
resource "azurerm_resource_group_policy_assignment" "guest_config_baseline" {
  name                 = local.assignment_name
  display_name         = "Linux compute security baseline (Arc) — ${local.suffix}"
  description          = "Audits the Arc-enabled server-to-migrate against the Azure compute security baseline via guest configuration. Module B B.1.1 governance evidence."
  resource_group_id    = data.azurerm_resource_group.base.id
  policy_definition_id = var.guest_config_policy_definition_id
  location             = var.location
  enforce              = var.enforce_policy

  identity {
    type = "SystemAssigned"
  }

  parameters = jsonencode({
    IncludeArcMachines = {
      value = var.include_arc_machines
    }
  })

  non_compliance_message {
    content = "The Arc-enabled server does not yet meet the Azure compute security baseline. Review the guest-configuration results in Azure Policy and remediate before relying on this as audit evidence."
  }

  metadata = jsonencode({
    category        = "Guest Configuration"
    moduleBControl  = "B.1.1"
    assignedBy      = "azure-local-microhack/challenge-01"
    evidencePurpose = "Continuous configuration audit of the Arc-enabled server-to-migrate."
  })
}
