# Challenge 03 — Hybrid Resiliency: Backup, DR & Security

Contoso's auditors ask the obvious question every customer asks: *"when the
server dies, how fast do we recover — and how do we prove it?"* In this challenge
you protect the **server to migrate** with **Azure Backup**, frame **Azure Site
Recovery (ASR)** for disaster recovery, raise its security posture with
**Microsoft Defender for Servers Plan 2**, and package a reusable **DR runbook**
plus **protection evidence** for the Module B evidence pack.

## 🎯 Objectives

By the end of this challenge, you will be able to:

- Deploy a **Recovery Services vault** and a **VM backup policy** with Terraform + Azure Verified Modules, then **protect** the base VM and trigger a recovery point.
- Explain **Azure Site Recovery** replication and **enable/test failover** conceptually (and for real where Azure-to-Azure region constraints allow).
- Enable **Microsoft Defender for Servers Plan 2** and walk the **secure score** and **recommendations** for the hybrid host.
- Produce a **DR runbook** (RTO/RPO, failover/failback) and a **protection-evidence** bundle as partner onboarding / audit assets.

## 🧩 Module B coverage

| Control | Evidence created in this challenge |
| --- | --- |
| **B.1.1 — Implementation** | A backup + DR + security control set implemented over the Arc-eligible hybrid server. |
| **B.2.1 — ACR Performance** | Consumption of eligible resiliency services (Azure Backup, Site Recovery, Defender for Servers). |
| **B.4.2 — Partner Onboarding Assets** | A reusable **DR runbook** and a **protection-evidence** sample fed by the collection script. |

> [!NOTE]
> Verify exact current specialization thresholds and the eligible-services list
> in the Microsoft-issued Advanced Specialization requirements PDF. This lab does
> not assert numeric Module B thresholds.

## ⏱️ Duration & prerequisites

- **Duration:** ~60 minutes.
- **Required completed challenges:** [Challenge 00](../challenge-00-setup/) (base environment) and ideally [Challenge 01](../challenge-01-arc-foundations/).
- **Required access:** Azure subscription **Owner** (you enable a Defender plan and create a vault).
- **Expected resources:** the shared base resource group `rg-mhb-<initials>` with the `vm-mhb-<initials>` VM **deployed and running**.

> [!IMPORTANT]
> Defender for Servers Plan 2 and ASR replication can incur ongoing cost. Enable
> them only for the lab window and follow the [Cleanup](#-cleanup) section. In a
> corporate subscription, **confirm you may change the Defender plan** before you
> start (set `enable_defender_for_servers = false` if not).

## 🛠️ Tasks

### Task 1 — Deploy the resiliency module (vault + policy + Defender)

1. Make sure you are signed in and your subscription is exported:

   ```bash
   az account show -o table
   export ARM_SUBSCRIPTION_ID="$(az account show --query id -o tsv)"
   ```

1. Deploy the vault, the daily VM backup policy, and Defender for Servers Plan 2.
   The helper script wraps `init`/`validate`/`plan`/`apply` and, if your base
   module is checked out, wires vault diagnostics to the shared Log Analytics
   workspace:

   ```bash
   ./scripts/01-deploy-resiliency.sh <your-initials>
   ```

1. Confirm the outputs (vault name, policy name, Defender flag):

   ```bash
   terraform -chdir=infra output
   ```

> [!TIP]
> Prefer infrastructure-as-code over portal clicks: everything here is reviewable,
> repeatable, and itself becomes evidence. The module is **AVM-first** — see
> [`infra/README.md`](infra/README.md).

### Task 2 — Protect the base VM and create a recovery point

1. Register the running VM as a protected item and trigger an initial on-demand backup:

   ```bash
   ./scripts/02-protect-base-vm.sh <your-initials>
   ```

1. Watch the backup job reach **Completed** (initial backups take a few minutes):

   ```bash
   az backup job list \
     --resource-group "rg-mhb-<your-initials>" \
     --vault-name "rsv-mhb-<your-initials>-03" \
     -o table
   ```

1. Confirm a recovery point exists:

   ```bash
   az backup item list \
     --resource-group "rg-mhb-<your-initials>" \
     --vault-name "rsv-mhb-<your-initials>-03" \
     --backup-management-type AzureIaasVM --workload-type VM \
     --query "[].{vm:properties.friendlyName,state:properties.protectionState,last:properties.lastRecoveryPoint}" -o table
   ```

> [!NOTE]
> For **in-guest** file/folder or application-consistent recovery, you would
> install the **MARS agent** inside the server. For an Azure VM, the vault uses
> the VM extension automatically — no MARS agent required.

### Task 3 — Azure Site Recovery: replication & failover

ASR provides **disaster recovery** (replicate a workload to a second region/site
and fail it over), which is distinct from Backup (point-in-time recovery).

1. Read the replication model for your source:
   - **On-premises / Azure Local source:** source → ASR **mobility service** → target Azure region.
   - **Azure VM source:** **Azure-to-Azure** replication between a supported region pair.

1. In the portal, open the vault → **Site Recovery**. Where your subscription and
   region pair allow Azure-to-Azure replication, **enable replication** for
   `vm-mhb-<your-initials>` to a secondary region, then run a **Test failover**
   into an isolated network.

1. If replication is blocked by tenant policy or region pairing, **document the
   on-premises → Azure flow conceptually** in the DR runbook instead (see Task 6).

> [!WARNING]
> Always use **Test failover** first — it validates DR without disrupting the
> source. Do not leave replication running after the lab; it bills continuously.

### Task 4 — Defender for Cloud: secure score & recommendations

1. Confirm Defender for Servers Plan 2 is enabled (set by Task 1):

   ```bash
   az security pricing show --name VirtualMachines --query "{tier:pricingTier,subPlan:subPlan}" -o table
   ```

1. In the portal, open **Microsoft Defender for Cloud → Secure score**, then
   **Recommendations**. Filter to your resource group and walk the top items for
   `vm-mhb-<your-initials>` (e.g. patch, endpoint protection, disk encryption).

1. List a few assessments from the CLI:

   ```bash
   az security assessment list --query "[0:5].{name:displayName,status:status.code}" -o table
   ```

> [!NOTE]
> **Optional — Microsoft Sentinel:** to centralize detections, connect the
> shared Log Analytics workspace to **Microsoft Sentinel** and enable the Defender
> for Cloud connector. This is a pointer only; enabling Sentinel is out of scope
> for the 60-minute window.

### Task 5 — Collect protection evidence

1. Generate the evidence bundle (Backup status + recovery point + Defender posture + secure score):

   ```bash
   ./scripts/03-collect-evidence.sh <your-initials>
   ```

1. Open the generated `assets/protection-evidence.<your-initials>.json` and
   compare it to the committed [sample](assets/protection-evidence.sample.json).

### Task 6 — Complete the DR runbook (B.4.2 asset)

1. Copy [`assets/dr-runbook.md`](assets/dr-runbook.md) for your workload and fill
   in every `«PLACEHOLDER»` — especially the **RTO/RPO** table, owners, and the
   failover/failback steps.
1. Attach the completed runbook and the evidence bundle to your Module B evidence
   pack. These are the **B.4.2 partner onboarding assets** for resiliency.

## ✅ Success criteria

- [ ] Recovery Services vault `rsv-mhb-<initials>-03` and policy `bkpol-mhb-<initials>-03` deployed via Terraform (AVM).
- [ ] The base VM is a **Protected** item with at least one **Completed** backup job / recovery point.
- [ ] ASR replication is **enabled and test-failed-over** where allowed, or the on-prem→Azure flow is documented in the runbook.
- [ ] Defender for Servers Plan 2 shows `Standard` / `P2`; you can navigate secure score and recommendations.
- [ ] `protection-evidence.<initials>.json` generated and the **DR runbook** completed as a B.4.2 asset.

## 🧹 Cleanup

> [!WARNING]
> Soft-delete, protected items, ASR replication, and the Defender plan can all
> incur cost. Order matters: stop protection (delete backup data) **before**
> deleting the vault, disable ASR replication, and revert Defender to `Free`.

Keep the **base environment** for later challenges. Remove only this challenge's
cost drivers when your cohort is done:

```bash
# Stop protection, drop ASR, revert Defender, then destroy what Terraform owns.
terraform -chdir=infra apply -var protect_base_vm=false -var enable_defender_for_servers=false
terraform -chdir=infra destroy
```

Full, careful teardown (soft-delete handling, ASR artifacts, Defender downgrade)
is in [../docs/teardown.md](../docs/teardown.md).

## 📚 References

- [Azure Backup overview](https://learn.microsoft.com/azure/backup/backup-overview)
- [Back up an Azure VM with Azure CLI](https://learn.microsoft.com/azure/backup/quick-backup-vm-cli)
- [Azure Site Recovery overview](https://learn.microsoft.com/azure/site-recovery/site-recovery-overview)
- [Plan Microsoft Defender for Servers](https://learn.microsoft.com/azure/defender-for-cloud/plan-defender-for-servers)
- [Secure score in Defender for Cloud](https://learn.microsoft.com/azure/defender-for-cloud/secure-score-security-controls)
- [Azure/avm-res-recoveryservices-vault](https://registry.terraform.io/modules/Azure/avm-res-recoveryservices-vault/azurerm/latest)
