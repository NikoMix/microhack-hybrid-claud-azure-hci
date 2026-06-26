# Runbook — Hybrid Observability & Patch Lifecycle (Azure Monitor + Update Manager)

> [!NOTE]
> Partner onboarding asset for **Module B control B.4.2** (also strengthens **B.1.1**).
> Engagement-agnostic and parameterized — replace every `<placeholder>` with the
> customer's values. All commands are idempotent and safe to re-run.

## Purpose & scope

Standardize how a partner brings a hybrid Linux server (Azure VM **or** Azure Arc-enabled
machine) under day-2 operations:

- Attach the **Azure Monitor Agent (AMA)** and the **VM Insights** + **Change Tracking &
  Inventory** Data Collection Rules to a shared **Log Analytics workspace**.
- Stand up one **alert rule** (heartbeat-missing) and one **Azure Monitor workbook**.
- Run an **Azure Update Manager** assessment and one on-demand patch deployment, and bind
  the machine to a recurring **maintenance configuration** via dynamic scoping.

Out of scope: workspace creation (reuse the shared base workspace), networking, and the
Arc onboarding itself (covered by the Challenge 01 / Arc onboarding runbook).

## Prerequisites

| Requirement | Detail |
| --- | --- |
| Access / RBAC | `Contributor` on `rg-mhb-<initials>`; `Monitoring Contributor` for DCR/alert; `Azure Connected Machine Resource Administrator` if targeting Arc |
| Sign-in | `az login` (or a managed identity on the runner). Never store secrets in this file |
| Providers | `Microsoft.Insights`, `Microsoft.Maintenance`, `Microsoft.OperationalInsights`, `Microsoft.HybridCompute`, `Microsoft.Compute` registered |
| Tooling | Azure CLI ≥ 2.62, Terraform ≥ 1.9, `az extension add --name connectedmachine` (Arc), `--name maintenance` |
| Inputs | `<initials>`, `<region>` (default `swedencentral`), `<workspace-id>` (base output `log_analytics_workspace_id`), `<machine-id>` (the target resource ID) |

Resolve the reusable inputs once:

```bash
#!/usr/bin/env bash
set -euo pipefail

INITIALS="<initials>"
REGION="${REGION:-swedencentral}"
RG="rg-mhb-${INITIALS}"

# Reuse the shared base Log Analytics workspace (base output: log_analytics_workspace_id).
WORKSPACE_ID="$(terraform -chdir=../../infra/terraform/base output -raw log_analytics_workspace_id)"

# Target machine: Arc-enabled server or base Azure VM (resource ID).
MACHINE_ID="<machine-id>"
echo "RG=${RG} REGION=${REGION}"
echo "WORKSPACE_ID=${WORKSPACE_ID}"
```

## Roles & RACI

| Activity | Partner consultant | Customer ops lead | Customer security |
| --- | --- | --- | --- |
| Deploy DCRs / alert / workbook (IaC) | **R** | A | I |
| Approve maintenance window & reboot policy | C | **A** | C |
| Run patch assessment | **R** | C | I |
| Approve & run patch deployment | C | **A/R** | C |
| Review evidence & sign-off | I | A | **R** |

> `R` = Responsible, `A` = Accountable, `C` = Consulted, `I` = Informed.

## Procedure

### 1. Register providers (idempotent)

```bash
for ns in Microsoft.Insights Microsoft.Maintenance Microsoft.OperationalInsights \
          Microsoft.HybridCompute Microsoft.Compute; do
  az provider register --namespace "$ns" --wait
done
```

Expected: each command returns without error; `az provider show -n <ns> --query registrationState`
reports `Registered`.

### 2. Deploy the observability resources as code

```bash
terraform -chdir=infra init -input=false
terraform -chdir=infra apply -input=false \
  -var "initials=${INITIALS}" \
  -var "location=${REGION}" \
  -var "log_analytics_workspace_id=${WORKSPACE_ID}" \
  -var "monitored_resource_id=${MACHINE_ID}"
```

Expected: applies the VM Insights DCR, Change Tracking DCR, both DCR associations, the
action group, the heartbeat alert rule, the workbook, and the Update Manager maintenance
configuration. Capture the outputs (`dcr_vminsights_id`, `alert_rule_id`, `workbook_id`,
`maintenance_configuration_id`).

### 3. Ensure the agent + machine-mode prerequisites

For an **Azure VM**, install AMA and set platform-managed patching:

```bash
az vm extension set --resource-group "$RG" --vm-name "<vm-name>" \
  --name AzureMonitorLinuxAgent --publisher Microsoft.Azure.Monitor \
  --enable-auto-upgrade true

az vm update --resource-group "$RG" --name "<vm-name>" \
  --set osProfile.linuxConfiguration.patchSettings.patchMode=AutomaticByPlatform \
        osProfile.linuxConfiguration.patchSettings.assessmentMode=AutomaticByPlatform
```

For an **Arc-enabled server**, install AMA and set the patch orchestration:

```bash
az connectedmachine extension create --resource-group "$RG" \
  --machine-name "<machine-name>" --name AzureMonitorLinuxAgent \
  --publisher Microsoft.Azure.Monitor --type AzureMonitorLinuxAgent \
  --enable-auto-upgrade true

az connectedmachine update --resource-group "$RG" --machine-name "<machine-name>" \
  --set properties.osProfile.linuxConfiguration.patchSettings.patchMode=AutomaticByPlatform
```

Expected: extension `provisioningState` is `Succeeded`; patch mode reports
`AutomaticByPlatform` (required for scheduled maintenance).

### 4. Run an Update Manager assessment

```bash
# Azure VM
az vm assess-patches --resource-group "$RG" --name "<vm-name>" -o table
# Arc-enabled server
az rest --method post \
  --url "https://management.azure.com${MACHINE_ID}/assessPatches?api-version=2024-07-10"
```

Expected: returns the list of available updates with `Critical`/`Security` classifications
and a count of pending patches.

### 5. Run one on-demand patch deployment

> [!WARNING]
> This installs packages and may **reboot** the machine. Confirm the maintenance window
> and customer approval (RACI `A`) before running in production.

```bash
# Azure VM — install Critical + Security, reboot only if required
az vm install-patches --resource-group "$RG" --name "<vm-name>" \
  --maximum-duration PT2H --reboot-setting IfRequired \
  --classifications-to-include-linux Critical Security

# Arc-enabled server
az rest --method post \
  --url "https://management.azure.com${MACHINE_ID}/installPatches?api-version=2024-07-10" \
  --body '{"maximumDuration":"PT2H","rebootSetting":"IfRequired","linuxParameters":{"classificationsToInclude":["Critical","Security"]}}'
```

Expected: `installationActivityId` returned; final status `Succeeded` (or
`CompletedWithWarnings`); installed-patch list populated.

## Validation

Confirm telemetry and lifecycle health from the workspace and control plane:

```bash
# Heartbeat is flowing for the machine
az monitor log-analytics query --workspace "${WORKSPACE_ID##*/}" \
  --analytics-query "Heartbeat | where TimeGenerated > ago(15m) | summarize max(TimeGenerated) by Computer" \
  -o table

# Maintenance configuration is assigned
az maintenance configuration list -o table

# Alert rule exists and is enabled
az monitor scheduled-query list --resource-group "$RG" \
  --query "[].{name:name,enabled:enabled}" -o table
```

What "good" looks like:

- `Heartbeat` returns a row per machine with a timestamp inside the last 15 minutes.
- `InsightsMetrics` and `ConfigurationChange` tables return rows within ~30 minutes of the
  DCR association.
- The heartbeat alert rule shows `enabled = true`; the workbook opens and renders.
- Update Manager shows the assessment and a completed deployment for the machine.

## Rollback / recovery

```bash
# Detach the DCRs from the machine (telemetry stops; resources retained)
az monitor data-collection rule association delete \
  --name vminsights-dcra --resource "$MACHINE_ID" --yes
az monitor data-collection rule association delete \
  --name changetracking-dcra --resource "$MACHINE_ID" --yes

# Or remove everything this runbook created as code
terraform -chdir=infra destroy -input=false \
  -var "initials=${INITIALS}" -var "location=${REGION}" \
  -var "log_analytics_workspace_id=${WORKSPACE_ID}" \
  -var "monitored_resource_id=${MACHINE_ID}"
```

Recovery: re-running step 2 (`terraform apply`) is idempotent and re-creates any missing
association. The shared Log Analytics workspace is never deleted by this runbook.

## Evidence captured

| Control | Evidence artifact to file |
| --- | --- |
| **B.4.2** | This runbook + the Terraform outputs (DCR / alert / workbook / maintenance IDs) |
| **B.4.2** | `assets/hybrid-observability-workbook.json` (workbook-as-code) |
| **B.1.1** | Screenshot of the workbook rendering heartbeat + VM Insights for the machine |
| **B.2.1** | Update Manager assessment + deployment result for the server-to-migrate |

File these in the engagement Evidence Index under "Operational readiness / Day-2".

## References

- [Azure Monitor Agent & Data Collection Rules](https://learn.microsoft.com/azure/azure-monitor/agents/azure-monitor-agent-overview)
- [VM Insights](https://learn.microsoft.com/azure/azure-monitor/vm/vminsights-overview)
- [Change Tracking & Inventory with AMA](https://learn.microsoft.com/azure/automation/change-tracking/overview-monitoring-agent)
- [Azure Update Manager](https://learn.microsoft.com/azure/update-manager/overview)
- [Dynamic scoping in Update Manager](https://learn.microsoft.com/azure/update-manager/dynamic-scope-overview)
- [Scheduled query alert rules](https://learn.microsoft.com/azure/azure-monitor/alerts/alerts-create-log-alert-rule)
