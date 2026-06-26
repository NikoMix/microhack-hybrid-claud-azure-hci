# Challenge 01 trainer notes

Private guidance for delivering **Arc Foundations**. The pupils' first hands-on
win is seeing an Azure VM appear as an **Arc-enabled server** — protect time for
that moment. Keep the Azure Local hardware talk conceptual; the lab is about the
**control plane**, not deploying clusters.

## Timing

| Minute | Activity | Trainer cue |
| ---: | --- | --- |
| 0-10 | Architecture + migration story (Task 0) | Whiteboard the diagram; tie every box to Contoso's 3-tier app. |
| 10-15 | Providers + onboarding SP (Task 1) | Start provider registration early — it runs in the background. |
| 15-25 | IMDS block + onboarding (Tasks 2-3) | The key moment; watch for the IMDS pitfall below. |
| 25-35 | Governance tags (Task 4) | Stress consistent tags as audit evidence. |
| 35-50 | Policy via Terraform (Task 5) | `init` then `apply`; explain the assignment identity. |
| 50-58 | Resource Graph inventory (Task 6) | Have pupils read their own tags back via KQL. |
| 58-60 | Checkpoint | Ask the questions below; confirm success criteria. |

Minimum viable checkpoint: **the machine shows Connected** (Task 3) and **appears
in Resource Graph** (Task 6). Tasks 4-5 can be finished asynchronously if time is
short.

## Talk track

"Contoso isn't moving a single VM today. Before migration, the platform team has
to prove governance: can we see an existing server in Azure, tag it, hold it to a
security baseline, and inventory it centrally? That is exactly what **Azure Arc**
gives us — one control plane for Azure Local nodes and any off-Azure server. Azure
Local itself runs on **validated hardware** with **Storage Spaces Direct** and
**Network ATC**, and can stretch across sites for resilience. But the management
story — Monitor and **Arc Insights**, **Update Manager**, **Defender for Servers
Plan 2**, machine configuration — is the *same* whether the server sits on Azure
Local or in this classroom. Today we light up that control plane on one server."

## Live demo script

1. Show the server is a plain Azure VM, not yet in Arc:

   ```bash
   az connectedmachine list -g rg-mhb-<initials> -o table
   ```

1. On the server, block IMDS and prove it is unreachable:

   ```bash
   sudo ./10-imds-guard.sh block
   curl -s -m 3 -H 'Metadata:true' \
     'http://169.254.169.254/metadata/instance?api-version=2021-02-01' \
     || echo 'IMDS unreachable (expected)'
   ```

1. Onboard and show the Connected state:

   ```bash
   sudo -E ./20-arc-onboard.sh
   sudo azcmagent show
   ```

1. Back in Azure, show the projected resource and (after Task 4) its tags:

   ```bash
   az connectedmachine show -g rg-mhb-<initials> -n vm-mhb-<initials> \
     --query '{name:name, status:status, tags:tags}' -o json
   ```

Recovery: if onboarding fails, run `sudo ./10-imds-guard.sh status`; if IMDS is
reachable the block did not take — re-run `block` and retry the connect.

## Common pitfalls

| Symptom | Likely cause | Fix |
| --- | --- | --- |
| `azcmagent connect` fails: resource already exists / detected Azure | IMDS not blocked, so the agent treats the VM as an Azure VM. | Run `sudo ./10-imds-guard.sh block`, confirm `status`, retry. See [../docs/troubleshooting.md](../docs/troubleshooting.md). |
| `connect` fails with authorization error | Service principal RBAC not yet propagated. | Wait 1-2 minutes after Task 1, then retry. |
| `ARC_* is required` | `sudo` dropped the environment. | Use `sudo -E ./20-arc-onboard.sh`; re-paste the `export` block first. |
| Provider not registered errors | Registration still in progress. | Re-run `./scripts/00-register-providers.sh`; it waits/asserts state. |
| `terraform apply` cannot find the resource group | Base environment not deployed, or wrong `initials`. | Deploy `infra/terraform/base` first; pass the matching `-var initials=`. |
| Machine missing from Resource Graph | Indexing lag, or wrong resource group filter. | Wait ~1 minute; verify the `resourceGroup` value in the KQL. |

## Checkpoint questions & answers

**Q1. Why must you block IMDS to onboard this VM, and why is that lab-only?**

A: The Connected Machine agent reads IMDS (`169.254.169.254`) and refuses to
onboard a machine that reports as already running in Azure. Blocking it makes the
VM look off-Azure. Production Arc onboards genuinely off-Azure machines, so the
block is never needed there — and it must be removed after the lab.

**Q2. What Azure resource type represents an Arc-enabled server, and why does that
matter for governance?**

A: `Microsoft.HybridCompute/machines`. Because it is a first-class Azure resource,
the same tags, Azure Policy, RBAC, and Resource Graph queries that govern native
Azure resources now apply to the off-Azure server.

**Q3. Why assign the policy with a managed identity, and in audit mode?**

A: The guest-configuration (machine configuration) baseline needs an identity to
run in-guest audits. Audit mode (not enforce) reports compliance without changing
or blocking the server — appropriate for a cost-guarded classroom and for initial
posture assessment.

**Q4. Name three Day-2 capabilities Arc unlocks that support the migration
business case.**

A: Any three of: Azure Monitor + Arc Insights, Azure Update Manager, Defender for
Servers Plan 2, machine configuration, Azure Backup / Site Recovery.

## Reset between cohorts

- On the server, remove the lab-only IMDS block:
  `sudo ./10-imds-guard.sh unblock`.
- Remove cloud artifacts: `./scripts/90-reset.sh <initials>` (deletes the Arc
  machine and the onboarding service principal).
- Destroy the policy assignment: `terraform -chdir=infra destroy -var "initials=<initials>"`.
- Confirm [../docs/teardown.md](../docs/teardown.md) removes all shared resources
  at end of day.
- Recreate only what the next cohort needs: the base environment and a Connected
  agent are re-onboarded fresh during the run.
