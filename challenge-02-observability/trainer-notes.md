# Challenge 02 trainer notes

Private guidance for delivering **Hybrid Observability & Lifecycle**. Keep the room moving:
the deploy is code-driven, so most time should go to reading telemetry and discussing the
*operations* story, not waiting on the portal.

## Timing

| Minute | Activity | Trainer cue |
| ---: | --- | --- |
| 0-8 | Why day-2 ops matter; show the architecture | Tie to Contoso: "moved ≠ operated." |
| 8-18 | Task 1-2: identify the machine, deploy observability as code | Watch for missing `MACHINE_ID` / base workspace. |
| 18-30 | Task 3-4: enable AMA, query KQL | Telemetry lags — start the deploy early, fill with talk track. |
| 30-45 | Task 5: Update Manager assessment + patch | Stress the reboot warning and approval gate. |
| 45-55 | Task 6: workbook + alert + evidence | Connect the workbook/runbook to B.4.2. |
| 55-60 | Checkpoint questions | Use the Q&A below. |

Minimum viable checkpoint: the workspace is reused and `Heartbeat` shows the machine. If
the patch deployment is slow, demo the **assessment** only and move on.

## Talk track

"In Challenge 01 we projected the server into Azure. That makes it *visible* — but the
Advanced Specialization is about proving we can *run* the customer's hybrid estate. So today
we instrument the exact same server with the modern Azure Monitor Agent and Data Collection
Rules — no legacy MMA, which Microsoft retired in 2024 — turn on VM Insights and Change
Tracking, and we patch it with Azure Update Manager, the GA service that replaced Automation
Update Management. Everything is Terraform with Azure Verified Modules, and we finish by
writing the runbook a partner would actually reuse on the next engagement. That runbook plus
the workbook-as-code is our B.4.2 evidence; the Monitor and Update Manager consumption is
ACR-eligible for B.2.1; and the whole thing demonstrates B.1.1 implementation capability."

## Live demo script

1. Show the shared workspace is reused (not recreated):

   ```bash
   terraform -chdir=../../infra/terraform/base output -raw log_analytics_workspace_id
   ```

1. Deploy the layer and show the plan summary (DCRs, alert, workbook, maintenance config):

   ```bash
   ./scripts/01-deploy-observability.sh "$INITIALS" "$REGION" "$MACHINE_ID"
   ```

1. Show live telemetry in **Logs**:

   ```kusto
   Heartbeat | where TimeGenerated > ago(15m) | summarize arg_max(TimeGenerated, *) by Computer
   ```

1. Run the assessment (read-only) so the room sees the pending-update count:

   ```bash
   ./scripts/02-update-manager.sh "$MACHINE_ID"
   ```

1. Open the workbook (*Hybrid Observability — mhb-`<initials>`-02*) and the heartbeat alert.

## Common pitfalls

| Symptom | Likely cause | Fix |
| --- | --- | --- |
| `could not resolve log_analytics_workspace_id` | Base not deployed, or wrong working dir | Run Challenge 00 first, or `export TF_VAR_log_analytics_workspace_id=<id>`. |
| No `Heartbeat`/`InsightsMetrics` rows | AMA not installed, or DCR not associated yet | Confirm Task 3 ran; wait 10-15 min; check `monitored_resource_id` was passed. |
| Scheduled patch never runs | Patch mode not `AutomaticByPlatform` | Re-run the `patchMode`/`assessmentMode` update in Task 3. |
| `assess-patches` errors on Arc | Used the VM CLI path for an Arc machine | The script auto-detects type; ensure the resource ID is the `Microsoft.HybridCompute/machines` one. |
| `ConfigurationChange` empty | Change Tracking DCR disabled or just associated | Set `enable_change_tracking=true`; changes appear after the first inventory cycle. |
| Terraform wants to recreate the maintenance window | `start_date_time` edited to `timestamp()` | Keep a static past anchor; Azure computes the next occurrence. |

See [../docs/troubleshooting.md](../docs/troubleshooting.md) for shared issues.

## Checkpoint questions & answers

**Q1. Why is observability part of a migration story?**

A: It proves the migrated estate can be operated consistently after onboarding, not merely
moved — health, change, and patch posture are visible and actionable from Azure.

**Q2. How does Update Manager support customer operations?**

A: It centralizes update assessment and maintenance planning across hybrid machines (Azure
VMs and Arc-enabled servers) from one control plane, with scheduled maintenance windows and
dynamic scoping so new machines inherit policy automatically.

**Q3. Why the Azure Monitor Agent + Data Collection Rules instead of the old agent?**

A: The legacy Log Analytics agent (MMA) retired in 2024. AMA + DCRs give granular,
reusable, least-privilege data collection that targets both Azure VMs and Arc servers — and
it's the only supported path for VM Insights and Change Tracking going forward.

**Q4. Which artifacts here are the partner onboarding (B.4.2) evidence?**

A: The reusable operational runbook (`assets/observability-runbook.md`) and the
workbook-as-code (`assets/hybrid-observability-workbook.json`), plus the Terraform outputs.

## Reset between cohorts

- Destroy the challenge-02 resources (the shared base is untouched):

  ```bash
  terraform -chdir=infra destroy \
    -var "initials=${INITIALS}" -var "location=${REGION}" \
    -var "log_analytics_workspace_id=$(terraform -chdir=../../infra/terraform/base output -raw log_analytics_workspace_id)" \
    -var "monitored_resource_id=${MACHINE_ID}"
  ```

- In the portal, confirm the workbook and alert rule are removed (they are managed by the
  destroy above).
- Leave patch mode on the base VM as-is, or reset it to `ImageDefault` if the next cohort
  starts from a clean lifecycle demo.
- Confirm [../docs/teardown.md](../docs/teardown.md) removes all shared resources at end of day.
- Recreate only the resources intentionally needed for the next cohort.
