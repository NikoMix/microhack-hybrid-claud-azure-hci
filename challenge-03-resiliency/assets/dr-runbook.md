# Disaster Recovery runbook — hybrid server (Azure Backup + Azure Site Recovery)

> [!NOTE]
> This is a **reusable partner onboarding asset** (Module B control **B.4.2**).
> Copy it per customer/workload and replace every `«PLACEHOLDER»`. Values in
> guillemets are **examples only** — confirm real targets with the customer and
> validate them with a test failover. Do **not** treat the sample numbers as
> Microsoft-mandated thresholds.

## 1. Document control

| Field | Value |
| --- | --- |
| Workload / system | `«e.g. Contoso line-of-business app on server-to-migrate»` |
| Owner (business) | `«name / role»` |
| Owner (technical) | `«name / role»` |
| Azure subscription | `«subscription id»` |
| Resource group | `rg-mhb-«initials»` |
| Protected resource | `vm-mhb-«initials»` (Arc-enabled hybrid server) |
| Recovery Services vault | `rsv-mhb-«initials»-03` |
| Last reviewed | `«YYYY-MM-DD»` |
| Last DR test | `«YYYY-MM-DD»` (see §8) |

## 2. Recovery objectives (RTO / RPO)

> [!IMPORTANT]
> RTO/RPO are **customer-specific commitments**, not lab defaults. Agree them in
> writing, then design protection to meet them. The values below are
> **placeholders** to be confirmed.

| Tier | Workload class | RPO target | RTO target | Protection mechanism |
| --- | --- | --- | --- | --- |
| Tier 0 | `«mission-critical»` | `«CONFIRM — e.g. ≤ 15 min»` | `«CONFIRM — e.g. ≤ 1 h»` | ASR continuous replication + app HA |
| Tier 1 | `«business-critical»` | `«CONFIRM — e.g. ≤ 1 h»` | `«CONFIRM — e.g. ≤ 4 h»` | ASR replication |
| Tier 2 | `«standard»` | `«CONFIRM — e.g. ≤ 24 h»` | `«CONFIRM — e.g. ≤ 8 h»` | Azure Backup (daily) |
| Tier 3 | `«low priority»` | `«CONFIRM — e.g. ≤ 24 h»` | `«CONFIRM — best effort»` | Azure Backup (daily) |

This lab's `vm-mhb-«initials»` is treated as **Tier 2** (daily Azure Backup,
`«retention 7 days — CONFIRM»`). ASR is demonstrated conceptually / where region
constraints allow.

## 3. Protection design

- **Azure Backup** — Recovery Services vault `rsv-mhb-«initials»-03`, daily VM
  backup policy `bkpol-mhb-«initials»-03`, soft-delete **Enabled**. Storage
  redundancy `«LocallyRedundant for lab / GeoRedundant for production — CONFIRM»`.
- **Azure Site Recovery (ASR)** — replication of the workload to
  `«secondary region»`. For an on-premises / Azure Local source, the flow is
  source → ASR mobility service → target Azure region. For an Azure VM source,
  use Azure-to-Azure replication where the region pair allows it.
- **In-guest data** (optional) — MARS agent or workload-native backup for
  file/folder or database-consistent recovery points.
- **Security posture** — Microsoft Defender for Servers Plan 2 monitors the
  protected host; review recommendations before declaring "recovered".

## 4. Detection & declaration

1. Incident detected via `«Azure Monitor alert / Defender for Cloud alert / customer report»`.
2. On-call `«role»` validates scope and impact.
3. `«Incident commander»` formally **declares a DR event** and records the start time (drives RTO).
4. Open the incident bridge: `«channel / phone»` and notify stakeholders in §1.

## 5. Failover — restore from Azure Backup (Tier 2/3)

> [!WARNING]
> Restoring to the **same** resource group/network can collide with the failed
> resource. Prefer restore to an alternate name/RG, then re-point networking.

1. Confirm the latest recoverable point:

   ```bash
   az backup recoverypoint list \
     --resource-group "rg-mhb-«initials»" \
     --vault-name "rsv-mhb-«initials»-03" \
     --container-name "«container»" \
     --item-name "vm-mhb-«initials»" \
     --backup-management-type AzureIaasVM \
     --query "[0:5].{name:name,time:properties.recoveryPointTime}" -o table
   ```

2. Trigger a restore (restore disks, then create the VM, or restore-as-new):

   ```bash
   az backup restore restore-disks \
     --resource-group "rg-mhb-«initials»" \
     --vault-name "rsv-mhb-«initials»-03" \
     --container-name "«container»" \
     --item-name "vm-mhb-«initials»" \
     --rp-name "«recovery-point-name»" \
     --storage-account "«staging-storage-account»" \
     --target-resource-group "rg-mhb-«initials»"
   ```

3. Recreate / attach the VM from the restored disks, re-point DNS/load balancer,
   and validate (§7).

## 6. Failover — Azure Site Recovery (Tier 0/1)

1. In the Recovery Services vault → **Site Recovery** → **Replicated items**,
   select the workload and choose **Failover**.
2. Pick the recovery point: `«Latest (lowest RPO) / Latest app-consistent»`.
3. Run a **Test failover** into an isolated `«test vnet»` first; only run a real
   failover after declaration in §4.
4. After the target boots, **Commit** the failover and update the replication
   direction once stable.

> [!NOTE]
> Exact `az site-recovery` commands depend on the replication object type. Use
> the portal for the first failover and capture the CLI for the runbook
> afterwards. Reference: [Azure Site Recovery failover](https://learn.microsoft.com/azure/site-recovery/site-recovery-failover).

## 7. Validation checklist (before "service restored")

- [ ] Host reachable; OS healthy (`hostname`, `uptime`, `systemctl --failed`).
- [ ] Application responds on `«endpoint / port»`.
- [ ] Data integrity check passed: `«app-specific validation»`.
- [ ] Monitoring re-attached (Azure Monitor / Arc agent reporting).
- [ ] Defender for Cloud shows no new **high** severity alerts on the recovered host.
- [ ] Stakeholders notified; RTO stop time recorded.

## 8. Failback

1. Once the primary region/site is healthy, **reprotect** the workload
   (reverse replication target → source).
2. Schedule a failback window with the business owner.
3. Fail back via ASR (planned failover) or restore the validated data to the
   primary, then re-point networking.
4. **Commit**, re-enable the original protection (backup policy / forward
   replication), and confirm the original RPO is being met again.

## 9. Post-incident review

| Item | Captured value |
| --- | --- |
| Declared at | `«timestamp»` |
| Service restored at | `«timestamp»` |
| Achieved RTO | `«duration»` vs target `«target»` |
| Achieved RPO (data loss window) | `«duration»` vs target `«target»` |
| Root cause | `«summary»` |
| Action items | `«owner / due date»` |

## 10. Evidence & sign-off (Module B)

Attach to the customer's resiliency evidence package:

- The completed copy of this runbook.
- The protection-evidence bundle from
  [`../scripts/03-collect-evidence.sh`](../scripts/03-collect-evidence.sh)
  (sample: [protection-evidence.sample.json](protection-evidence.sample.json)).
- Screenshots of a successful **test failover** and a backup **recovery point**.

| Control | Evidence this runbook supports |
| --- | --- |
| **B.1.1** | Implemented backup + DR protection for the hybrid server. |
| **B.2.1** | Consumption of eligible resiliency services (Backup, ASR, Defender). |
| **B.4.2** | This reusable DR runbook as a partner onboarding asset. |

**Approved by:** `«name / role»` — `«date»`

## References

- [Azure Backup overview](https://learn.microsoft.com/azure/backup/backup-overview)
- [Azure Site Recovery overview](https://learn.microsoft.com/azure/site-recovery/site-recovery-overview)
- [Microsoft Defender for Servers](https://learn.microsoft.com/azure/defender-for-cloud/plan-defender-for-servers)
- [Back up Azure VMs with CLI](https://learn.microsoft.com/azure/backup/quick-backup-vm-cli)
