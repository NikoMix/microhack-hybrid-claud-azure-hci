# policy.tf — Azure Policy for Kubernetes (pod security baseline) assignment.
#
# Raw azurerm is used here because there is no Azure Verified Module for a
# resource-group-scoped policy assignment; this mirrors how the shared base
# environment uses raw azurerm where no AVM module fits. The assignment targets
# the built-in initiative (policy set definition), resolved by display name so we
# never hardcode a definition GUID.
#
# The matching cluster-side Azure Policy extension (Gatekeeper) is installed by
# ../scripts/03-enable-monitor-policy.sh; together they evaluate Arc-enabled
# Kubernetes workloads against the baseline standard.

data "azurerm_policy_set_definition" "k8s_baseline" {
  display_name = "Kubernetes cluster pod security baseline standards for Linux-based workloads"
}

resource "azurerm_resource_group_policy_assignment" "k8s_baseline" {
  name                 = local.policy_assignment_name
  resource_group_id    = data.azurerm_resource_group.base.id
  policy_definition_id = data.azurerm_policy_set_definition.k8s_baseline.id
  display_name         = "K8s pod security baseline (Arc) — ${local.suffix}"
  description          = "Evaluates Arc-enabled Kubernetes workloads against the pod security baseline standard. Module B (B.1.1) governance evidence for the hybrid estate."
  enforce              = var.policy_enforce

  parameters = jsonencode({
    effect = {
      value = var.policy_effect
    }
    excludedNamespaces = {
      value = var.policy_excluded_namespaces
    }
  })
}
