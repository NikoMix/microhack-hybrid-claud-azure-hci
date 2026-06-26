# Challenge 02 — Hybrid Observability & Lifecycle

Contoso's *server-to-migrate* is now projected into Azure. Before anyone trusts the hybrid
estate in production, you must **operate** it: see its health, track what changes on it, and
keep it patched. In this challenge you wire the server into **Azure Monitor** (reusing the
shared base **Log Analytics workspace**), turn on **VM Insights** and **Change Tracking &
Inventory** with the **Azure Monitor Agent**, raise an **alert**, build a **workbook**, and
run **Azure Update Manager** — then capture it all as a reusable partner runbook.

## 🎯 Objectives

By the end of this challenge, you will be able to:

- Reuse the shared base **Log Analytics workspace** and attach **Data Collection Rules**
  (VM Insights + Change Tracking) to a hybrid machine using the **Azure Monitor Agent**.
- Deploy the observability layer **as code** with Terraform and **Azure Verified Modules**.
- Query telemetry with **KQL** and confirm heartbeat, performance, and change signals.
- Run an **Azure Update Manager** assessment and one on-demand **patch deployment**, and
  bind the machine to a recurring **maintenance configuration** via dynamic scoping.
- Create one **alert rule** and one **Azure Monitor workbook**, and file a reusable
  **operational runbook** as partner onboarding evidence.

## 🧩 Module B coverage

| Control | Evidence created in this challenge |
| --- | --- |
| **B.1.1** Azure Local Implementation Capability | DCRs, VM Insights, Change Tracking, alert, and workbook deployed against the hybrid server — proof you can operate the onboarded estate. |
| **B.2.1** ACR Performance | Azure Monitor / Log Analytics ingestion and Azure Update Manager are ACR-eligible consumption; this challenge drives measurable usage on the server-to-migrate. |
| **B.4.2** Partner Onboarding Assets | [`assets/observability-runbook.md`](assets/observability-runbook.md) + the workbook-as-code [`assets/hybrid-observability-workbook.json`](assets/hybrid-observability-workbook.json). |

> [!NOTE]
> Verify exact current specialization thresholds in the Microsoft-issued Advanced
> Specialization requirements PDF. This challenge does not assert any numeric target.

## ⏱️ Duration & prerequisites

- Duration: `~60 minutes`.
- Required completed challenges: Challenge 00 (base environment) and Challenge 01
  (Arc-enabled server). The base **VM** also works as the monitored target.
- Required access: Azure subscription **Owner** (or Contributor + Monitoring Contributor).
- Expected resource group: `rg-mhb-<initials>` with the base **Log Analytics workspace**.

> [!TIP]
> This challenge uses the **latest** hybrid operations stack: the **Azure Monitor Agent**
> with **Data Collection Rules** (the legacy Log Analytics agent retired in 2024),
> **Change Tracking & Inventory on AMA**, and **Azure Update Manager** (the GA successor to
> Automation Update Management) with **dynamic scoping**.

## 🛠️ Tasks

> [!NOTE]
> Set your inputs once. `<initials>` must match the base environment.
>
> ```bash
> export INITIALS="<initials>"
> export REGION="swedencentral"
> az login --use-device-code
> export ARM_SUBSCRIPTION_ID="$(az account show --query id -o tsv)"
> ```

### Task 1 — Identify the machine to monitor

1. Capture the resource ID of the **Arc-enabled server** from Challenge 01 (preferred), or
   the base **VM**:

   ```bash
   # Arc-enabled server
   az connectedmachine list -g "rg-mhb-${INITIALS}" \
     --query "[0].id" -o tsv
   # ...or the base Azure VM
   az vm list -g "rg-mhb-${INITIALS}" --query "[0].id" -o tsv
   ```

1. Save it for the next step:

   ```bash
   export MACHINE_ID="<paste-the-resource-id>"
   ```

### Task 2 — Deploy the observability layer as code

1. Deploy the DCRs, alert rule, workbook, and Update Manager maintenance configuration. The
   script resolves the base workspace ID from the base Terraform output automatically:

   ```bash
   ./scripts/01-deploy-observability.sh "$INITIALS" "$REGION" "$MACHINE_ID"
   ```

1. Confirm the key outputs were produced:

   ```bash
   terraform -chdir=infra output
   ```

   Expected: `dcr_vminsights_id`, `alert_rule_id`, `workbook_id`, and
   `maintenance_configuration_id` are all populated.

### Task 3 — Enable the agent and platform patching

1. Install the **Azure Monitor Agent** and switch the machine to platform-managed patching
   (required for scheduled maintenance). For the base **VM**:

   ```bash
   VM_NAME="$(az vm show --ids "$MACHINE_ID" --query name -o tsv)"
   az vm extension set -g "rg-mhb-${INITIALS}" --vm-name "$VM_NAME" \
     --name AzureMonitorLinuxAgent --publisher Microsoft.Azure.Monitor \
     --enable-auto-upgrade true
   az vm update -g "rg-mhb-${INITIALS}" --name "$VM_NAME" \
     --set osProfile.linuxConfiguration.patchSettings.patchMode=AutomaticByPlatform \
           osProfile.linuxConfiguration.patchSettings.assessmentMode=AutomaticByPlatform
   ```

   > [!TIP]
   > For an **Arc-enabled server**, use `az connectedmachine extension create ...` and set
   > `patchMode=AutomaticByPlatform`. See [`assets/observability-runbook.md`](assets/observability-runbook.md).

### Task 4 — Confirm telemetry with KQL

1. Wait a few minutes, then verify the heartbeat is flowing:

   ```bash
   WS_ID="$(terraform -chdir=../../infra/terraform/base output -raw log_analytics_workspace_id)"
   WS_GUID="$(az monitor log-analytics workspace show --ids "$WS_ID" --query customerId -o tsv)"
   az monitor log-analytics query --workspace "$WS_GUID" \
     --analytics-query "Heartbeat | where TimeGenerated > ago(15m) | summarize max(TimeGenerated) by Computer" \
     -o table
   ```

1. Explore the other signals in the portal **Logs** blade (or via the CLI):

   ```kusto
   InsightsMetrics
   | where Namespace == "Processor" and Name == "UtilizationPercentage"
   | summarize avg(Val) by bin(TimeGenerated, 5m), Computer
   ```

   ```kusto
   ConfigurationChange
   | order by TimeGenerated desc
   | take 50
   ```

### Task 5 — Run Azure Update Manager

1. Run a **read-only assessment** of pending updates:

   ```bash
   ./scripts/02-update-manager.sh "$MACHINE_ID"
   ```

1. Deploy one round of **Critical + Security** patches (reboots only if required):

   > [!WARNING]
   > This may **reboot** the server. In a real engagement, confirm the maintenance window
   > and customer approval first.

   ```bash
   ./scripts/02-update-manager.sh "$MACHINE_ID" --install
   ```

### Task 6 — Open the workbook, alert, and capture evidence

1. In the portal, open **Monitor → Workbooks** and launch *Hybrid Observability —
   mhb-`<initials>`-02*; pick the base workspace and confirm the tiles render.
1. Open **Monitor → Alerts → Alert rules** and confirm *Heartbeat missing —
   mhb-`<initials>`-02* is enabled.
1. File the runbook [`assets/observability-runbook.md`](assets/observability-runbook.md) and
   the Terraform outputs in your evidence package.

## ✅ Success criteria

- [ ] The shared Log Analytics workspace is reused (no new workspace created).
- [ ] `Heartbeat` for the monitored machine is visible within the last 15 minutes.
- [ ] You can run or interpret a basic **KQL** query (`InsightsMetrics` or
      `ConfigurationChange` returns rows).
- [ ] An **Azure Update Manager** assessment is shown, and one patch deployment ran.
- [ ] The **alert rule** and **workbook** exist; the reusable **runbook** is captured.

## 🧹 Cleanup

Keep these resources for later challenges:

- The base **Log Analytics workspace**, **resource group**, and the monitored machine.
- The DCRs, alert, workbook, and maintenance configuration (reused as evidence).

To remove only this challenge's resources (the shared base is untouched):

```bash
terraform -chdir=infra destroy \
  -var "initials=${INITIALS}" -var "location=${REGION}" \
  -var "log_analytics_workspace_id=$(terraform -chdir=../../infra/terraform/base output -raw log_analytics_workspace_id)" \
  -var "monitored_resource_id=${MACHINE_ID}"
```

End-of-day cleanup is covered in [../docs/teardown.md](../docs/teardown.md).

## 📚 References

- [Azure Monitor Agent overview](https://learn.microsoft.com/azure/azure-monitor/agents/azure-monitor-agent-overview)
- [Data Collection Rules in Azure Monitor](https://learn.microsoft.com/azure/azure-monitor/essentials/data-collection-rule-overview)
- [VM Insights](https://learn.microsoft.com/azure/azure-monitor/vm/vminsights-overview)
- [Change Tracking & Inventory using Azure Monitor Agent](https://learn.microsoft.com/azure/automation/change-tracking/overview-monitoring-agent)
- [Azure Update Manager overview](https://learn.microsoft.com/azure/update-manager/overview)
- [Dynamic scoping for Azure Update Manager](https://learn.microsoft.com/azure/update-manager/dynamic-scope-overview)
- [Create a log search alert rule](https://learn.microsoft.com/azure/azure-monitor/alerts/alerts-create-log-alert-rule)
- [Azure Monitor workbooks](https://learn.microsoft.com/azure/azure-monitor/visualize/workbooks-overview)
- [Azure Verified Modules](https://azure.github.io/Azure-Verified-Modules/)
