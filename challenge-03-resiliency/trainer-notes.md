# Trainer notes — Challenge 03 · Hybrid Resiliency (Backup, DR & Security)

Private facilitation guidance for the ~60-minute resiliency block. The pupils
already have an Arc-eligible server; here they make it **recoverable, defensible,
and auditable**, and walk away with a reusable DR runbook.

## Timing

| Segment | Minutes | Trainer cue |
| --- | ---: | --- |
| Frame Backup vs DR vs security as **customer trust** controls | 6 | Tie to the auditor's "how fast do we recover, and can you prove it?" |
| Task 1 — deploy vault + policy + Defender (Terraform) | 12 | Show the AVM module + the plan; narrate while apply runs. |
| Task 2 — protect the VM + initial backup | 10 | The first backup is the long pole; kick it off early, return later. |
| Task 3 — ASR replication & test failover | 12 | Lead with the concept; enable A2A only where the region pair allows. |
| Task 4 — Defender secure score & recommendations | 10 | Onboarding lag is real — pre-enable in a demo sub. |
| Task 5/6 — evidence bundle + DR runbook | 8 | Land the B.4.2 message: the runbook **is** the deliverable. |
| Checkpoint Q&A | 2 | Use the questions below. |

**Minimum viable checkpoint:** every pupil has a **Protected** VM with one
completed recovery point and can open the Defender secure score. ASR and the full
runbook can be finished as homework if time is tight.

## Talk track

> "Backup and disaster recovery answer two different customer questions. Backup
> says *'we can get yesterday's data back'* — point-in-time recovery against
> corruption, ransomware, or fat-fingered deletes. Site Recovery says *'we can
> keep running when a whole site or region goes down'* — it replicates the
> workload and fails it over. Defender for Cloud is the third leg: it
> continuously scores the host's security posture so 'recovered' also means
> 'not walking straight back into the same compromise.' For Module B, the magic
> isn't clicking these on — it's the **runbook and the evidence**. A partner who
> hands a customer a tested DR runbook and a protection-evidence pack is
> demonstrating exactly the operational maturity B.4.2 is looking for."

Tie-back: **B.1.1** (you implemented the controls), **B.2.1** (eligible
resiliency services consumed), **B.4.2** (the DR runbook as an onboarding asset).

## Live demo script

1. Show the base VM is healthy: `az vm show -g rg-mhb-<initials> -n vm-mhb-<initials> -d --query powerState -o tsv`.
2. Run `./scripts/01-deploy-resiliency.sh <initials>` and **show the plan** — point at the `Azure/avm-res-recoveryservices-vault` module pinned to `1.1.11`, and the raw `azurerm_security_center_subscription_pricing` exception for Defender.
3. While it applies, open `infra/main.tf` and narrate the VM backup policy (V2, daily, soft-delete Enabled).
4. Run `./scripts/02-protect-base-vm.sh <initials>`; show the on-demand backup job starting with `az backup job list ... -o table`.
5. In the portal, open the vault → **Site Recovery** and walk the replication blade (enable A2A only if the region pair allows; otherwise narrate the on-prem→Azure flow).
6. Open **Defender for Cloud → Secure score → Recommendations**, filter to the resource group, and read the top recommendation for the host.
7. Run `./scripts/03-collect-evidence.sh <initials>` and open the JSON next to `assets/protection-evidence.sample.json` — this is the audit artifact.

## Common pitfalls

| Symptom | Likely cause | Fix |
| --- | --- | --- |
| `MissingSubscriptionRegistration` on apply | `Microsoft.RecoveryServices` / `Microsoft.Security` not registered | Re-run the base [register-providers script](../challenge-00-setup/scripts/01-register-providers.sh); registration lags a minute. |
| Protected item not visible right after Task 2 | Backup registration is asynchronous | Wait a few minutes and re-run `02-protect-base-vm.sh` (idempotent) to trigger the on-demand backup. |
| Defender recommendations empty | Onboarding lag (15–30 min) | Pre-enable Plan 2 in a demo subscription; show screenshots while pupils wait. See [troubleshooting](../docs/troubleshooting.md). |
| ASR "replication not available" | Region pair / tenant policy blocks Azure-to-Azure | Document the on-prem→Azure flow conceptually in the runbook instead of forcing a live failover. |
| `az security pricing create` denied | Subscription policy forbids plan changes | Set `enable_defender_for_servers = false` and demo from the trainer subscription. |
| Vault won't delete at teardown | Soft-delete + protected items | Stop protection with `--delete-backup-data true` first; see [teardown](../docs/teardown.md). |

## Checkpoint questions & answers

**Q1. Why are Backup and ASR discussed separately?**

A: Backup protects recoverable **data points** (point-in-time recovery against
corruption/ransomware/deletion). ASR supports **disaster recovery** — replicating
a workload and **failing it over** to keep running when a site or region is lost.
Different RPO/RTO profiles, different mechanisms.

**Q2. Why must Defender and ASR be cost-guarded during class?**

A: Defender plans, backup protected items, and ASR replication **bill
continuously** while enabled. Use a trial/short window, then stop protection,
disable replication, and revert the plan at teardown.

**Q3. What makes this challenge count toward B.4.2 rather than just B.1.1?**

A: B.1.1 is the *implementation*. B.4.2 is the **reusable onboarding asset** — the
completed DR runbook plus the protection-evidence bundle a partner can hand a
customer and reuse across engagements.

**Q4. The base VM is an Azure VM — why mention the MARS agent at all?**

A: For an Azure VM the vault uses the VM extension automatically. **MARS** is the
in-guest path used for on-premises / file-folder / application-consistent backup —
the scenario a real Azure Local or on-prem server would use, so pupils should
recognize it.

## Reset between cohorts

- Stop protection and delete backup data for lab items, then delete the vault
  (soft-delete makes order matter):

  ```bash
  terraform -chdir=challenge-03-resiliency/infra apply \
    -var protect_base_vm=false -var enable_defender_for_servers=false
  terraform -chdir=challenge-03-resiliency/infra destroy
  ```

- Disable any ASR replication enabled during the demo (portal or `az site-recovery`).
- Confirm Defender for Servers is back to the intended post-lab tier:
  `az security pricing show --name VirtualMachines -o table`.
- Delete generated evidence files (`assets/protection-evidence.<initials>.json`); they are gitignored but should not linger between cohorts.
- Cross-check the day-end flow in [../docs/teardown.md](../docs/teardown.md).
