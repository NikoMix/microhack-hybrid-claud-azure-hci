# Template — ACR eligible-services map (B.2.1)

> Reusable template for mapping the Azure services you deployed and operated to the
> **eligible Azure Consumption Revenue (ACR)** categories that evidence **Module B control
> B.2.1 (ACR Performance)**. Machine-readable companion: [`acr-eligible-services-map.csv`](./acr-eligible-services-map.csv).

> [!IMPORTANT]
> The **eligible-service list** and the **ACR threshold amount** are defined only in the
> **current Microsoft-issued Advanced Specialization requirements PDF** and change over time.
> Do **not** assert a dollar threshold or claim a service is definitively eligible. Every row
> below is a *candidate* mapping with eligibility marked **Confirm in PDF**. Replace every
> `[PLACEHOLDER — see official Module B control PDF]` with a value verified against that PDF.

## How to use this template

1. Enumerate your real resources. Prefer the **Azure MCP server** or:

   ```bash
   az resource list --resource-group "rg-mhb-<initials>" -o table
   ```

1. Keep or edit the rows below so each maps **your** deployed resource to a service family and
   a *candidate* ACR category.
1. Pull the actual consumption figures for your audit window (see the verification note) and
   record them alongside this map — never inline an invented number.
1. File the completed map in your evidence package and link it from the
   [Evidence Index](./evidence-index.md).

## Mapping table

| Challenge | Resource | Service family | Candidate ACR category | Consumption signal | Evidence path | Eligibility |
| --- | --- | --- | --- | --- | --- | --- |
| 00 — Setup | Server-to-migrate VM (base landing zone) | Azure Compute (IaaS) | Azure Virtual Machines | vCPU-hours + managed disk GB-month | [../../challenge-00-setup/](../../challenge-00-setup/) | Confirm in PDF |
| 00 — Setup | Log Analytics workspace | Azure Monitor | Azure Monitor / Log Analytics | Ingestion GB + retention GB-month | [../../challenge-00-setup/](../../challenge-00-setup/) | Confirm in PDF |
| 01 — Arc foundations | Arc-enabled server (Connected Machine agent) | Azure Arc | Azure Arc hybrid management | Arc-enabled resource + management add-ons | [../../challenge-01-arc-foundations/](../../challenge-01-arc-foundations/) | Confirm in PDF |
| 02 — Observability | Azure Monitor + Arc Insights | Azure Monitor | Azure Monitor / Log Analytics | Ingestion GB + alert rules + data collection rules | [../../challenge-02-observability/](../../challenge-02-observability/) | Confirm in PDF |
| 02 — Observability | Azure Update Manager | Azure Update Manager | Azure Update Manager | Periodic assessment per Arc machine | [../../challenge-02-observability/](../../challenge-02-observability/) | Confirm in PDF |
| 03 — Resiliency | Azure Backup (Recovery Services vault) | Azure Backup | Azure Backup | Protected instances + backup storage GB-month | [../../challenge-03-resiliency/](../../challenge-03-resiliency/) | Confirm in PDF |
| 03 — Resiliency | Azure Site Recovery | Azure Site Recovery | Azure Site Recovery | Instances replicating | [../../challenge-03-resiliency/](../../challenge-03-resiliency/) | Confirm in PDF |
| 03 — Resiliency | Microsoft Defender for Cloud (Servers Plan 2) | Microsoft Defender for Cloud | Microsoft Defender for Cloud | Protected server-hours | [../../challenge-03-resiliency/](../../challenge-03-resiliency/) | Confirm in PDF |
| 04 — AKS on Arc | Arc-enabled Kubernetes / AKS enabled by Azure Arc | Azure Arc-enabled Kubernetes | Azure Kubernetes Service / Azure Arc | vCPU-hours of Arc-enabled cluster + extensions | [../../challenge-04-aks-arc/](../../challenge-04-aks-arc/) | Confirm in PDF |
| 04 — AKS on Arc | Azure Monitor container insights | Azure Monitor | Azure Monitor / Log Analytics | Container log ingestion GB | [../../challenge-04-aks-arc/](../../challenge-04-aks-arc/) | Confirm in PDF |
| 04 — AKS on Arc | Flux GitOps (Arc configuration extension) | Azure Arc | Azure Arc hybrid management | Per-cluster configuration | [../../challenge-04-aks-arc/](../../challenge-04-aks-arc/) | Confirm in PDF |

## Audit-window summary (fill from Cost Management — do not invent)

| Field | Value |
| --- | --- |
| Qualifying window | `[PLACEHOLDER — see official Module B control PDF]` |
| Eligible ACR threshold | `[PLACEHOLDER — see official Module B control PDF]` |
| Measured eligible ACR in window | `[PLACEHOLDER — pull from Azure Cost Management]` |
| Currency | `[PLACEHOLDER]` |
| Threshold met? | `[PLACEHOLDER — Yes / No, after PDF check]` |

## How to verify amounts and eligibility

- **Eligibility:** confirm each candidate category against the eligible-service list in the
  current **Advanced Specialization requirements PDF**. Categories shift between revisions.
- **Amounts:** pull real figures from **Azure Cost Management** (Cost analysis, grouped by
  *Service name* / *Meter category*) for the qualifying window, or query meter-level usage via
  **Azure Monitor**. Export the report and store it next to this map as primary evidence.
- **Traceability:** keep the resource IDs and the Cost Management export so an auditor can
  reconcile each row to billed consumption.

## References

- [Advanced Specializations (Microsoft partner)](https://learn.microsoft.com/partner-center/membership/advanced-specializations)
- [Azure Cost Management — cost analysis](https://learn.microsoft.com/azure/cost-management-billing/costs/quick-acm-cost-analysis)
- [Azure Arc overview](https://learn.microsoft.com/azure/azure-arc/overview)
