# Cost estimate

This lab is cost-guarded but not cost-free. All figures are indicative, based on
a one-day classroom run, small SKUs, and same-day teardown. Verify current prices
with the Azure Pricing Calculator before delivery:
<https://azure.microsoft.com/pricing/calculator/>.

> [!IMPORTANT]
> Costs vary by region, currency, subscription offer, free credits, reservations,
> trials, and tenant policy. Do not quote this page as a commercial estimate.

## Indicative per-pupil estimate

For a same-day run of about 8-10 hours, a typical pupil should expect roughly:

| Scenario | Indicative range |
| --- | ---: |
| Base VM, network, disk, Log Analytics with low ingestion | EUR 2-6 / USD 2-7 |
| With short-lived Backup, ASR configuration, Defender trial/short window, and AKS-on-Arc/k3s overhead | EUR 5-15 / USD 6-17 |
| If resources are left running overnight or protected items are not cleaned up | Can exceed the lab estimate |

Assumptions:

- Region: `swedencentral` or similar European region.
- VM: one Standard_B2s Linux VM for the simulated server to migrate.
- Runtime: same business day only.
- Log ingestion: small lab volume.
- Defender for Servers Plan 2: trial or short enablement window, then downgrade/off.
- Azure Site Recovery: configured only long enough to demonstrate readiness, then removed.
- No production data, no high-churn disks, no large retention windows.

## Base resources

| Resource | Purpose | Cost behavior |
| --- | --- | --- |
| Resource group `rg-mhb-<initials>` | Lab boundary | No direct cost. |
| Log Analytics workspace | Azure Monitor logs and Arc signals | Charged mainly by ingestion and retention beyond included settings. |
| Virtual network and network security group | VM network | Usually no direct hourly cost. |
| Standard_B2s Linux VM | Server-to-migrate stand-in | Charged while allocated. Stop/deallocate or destroy. |
| Public IP | Remote access and lab simplicity | SKU and allocation can incur cost. Delete during teardown. |
| Managed OS disk | VM storage | Charged while disk exists, even if VM is stopped. |
| Network interface | VM attachment | Usually no direct cost. |
| User-assigned managed identity | RBAC and managed access pattern | No direct cost. |

## Per-challenge additions

| Challenge | Additions | Cost notes |
| --- | --- | --- |
| 00 Setup | Terraform state local to Codespaces, base Azure resources | Main cost starts when the VM and disk exist. |
| 01 Arc foundations | Azure Arc-enabled server, Connected Machine agent | Arc control-plane resource is generally no direct charge, but extensions and attached services may be. |
| 02 Observability | Azure Monitor, Log Analytics ingestion, Azure Update Manager assessment | Log volume and retention drive cost. Keep queries and collection minimal. |
| 03 Resiliency | Backup vault or Recovery Services vault, protected item metadata, Azure Site Recovery components, Defender for Cloud / Defender for Servers Plan 2 | Backup storage, ASR replication, and Defender plans can incur cost. Use trial/short window and remove protected items. |
| 04 AKS on Arc | k3s/kind on the lab VM or lightweight cluster, Arc-enabled Kubernetes, Flux GitOps | Arc connection is lightweight; underlying compute still costs. Avoid creating managed AKS clusters unless the challenge explicitly requires it. |
| 05 Readiness | Evidence artifacts and mapping | No additional Azure cost expected. |
| 06 AI capstone | GitHub Copilot custom agents, skills, MCP calls | GitHub Copilot licensing is prerequisite; avoid creating extra Azure resources during the capstone unless required. |

## Cost-control checklist

Before the day:

- Confirm pupils have permission to use a training or sandbox subscription.
- Confirm no policy forces premium SKUs.
- Confirm regional quota for Standard_B2s or select a fallback region.
- Explain that stopping a VM is not enough if disks, public IPs, vaults, and replicated items remain.

During the day:

- Use default small SKUs only.
- Keep retention windows minimal.
- Enable Defender for Servers Plan 2 only in a trial or short lab window.
- Do not leave ASR replication running beyond the demonstration.
- Avoid generating unnecessary log volume.
- Keep resource names grouped under `rg-mhb-<initials>`.

End of day:

- Run `task destroy:base`.
- Remove Arc-connected resources, connected Kubernetes resources, backup protected items, ASR replication, and vaults that Terraform does not own.
- Downgrade or disable Defender plans used only for the lab.
- Delete the resource group as a backstop.
- Verify with:

  ```bash
  az resource list --resource-group "rg-mhb-<initials>" -o table
  az group exists --name "rg-mhb-<initials>"
  ```

## Why same-day teardown matters

The most common cost issue is not the hourly VM. It is a leftover disk, public
IP, protected backup item, Recovery Services vault with soft-delete, ASR
replicated item, or Defender plan left enabled after class. Treat teardown as
part of the lab, not an optional cleanup.
