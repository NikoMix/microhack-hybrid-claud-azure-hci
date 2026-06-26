# Sample — ACR eligible-services map (B.2.1, filled)

> [!NOTE]
> **Illustrative training sample** for a fictitious partner, *Northwind Cloud*. All figures are
> fictitious. **Required thresholds remain placeholders** pending the official Module B PDF.
> Source template: [../templates/acr-eligible-services-map.md](../templates/acr-eligible-services-map.md).

## Mapping table (filled)

| Challenge | Resource | Service family | Candidate ACR category | Consumption signal | Evidence path | Eligibility |
| --- | --- | --- | --- | --- | --- | --- |
| 00 — Setup | Server-to-migrate VM | Azure Compute (IaaS) | Azure Virtual Machines | vCPU-hours + disk GB-month | `evidence-package/b1.1-implementation/inventory/resource-list.json` | Confirm in PDF |
| 01 — Arc | Arc-enabled server | Azure Arc | Azure Arc hybrid management | Arc resource + add-ons | `evidence-package/b1.1-implementation/arc-onboarding/azcmagent-show.txt` | Confirm in PDF |
| 02 — Observability | Azure Monitor + Insights | Azure Monitor | Azure Monitor / Log Analytics | Ingestion GB + alerts | `evidence-package/b2.1-acr/cost-export-2026Qx.csv` | Confirm in PDF |
| 02 — Observability | Azure Update Manager | Azure Update Manager | Azure Update Manager | Per-machine assessment | `evidence-package/b2.1-acr/cost-export-2026Qx.csv` | Confirm in PDF |
| 03 — Resiliency | Azure Backup | Azure Backup | Azure Backup | Protected instances + GB-month | `evidence-package/b2.1-acr/cost-export-2026Qx.csv` | Confirm in PDF |
| 03 — Resiliency | Azure Site Recovery | Azure Site Recovery | Azure Site Recovery | Instances replicating | `evidence-package/b2.1-acr/cost-export-2026Qx.csv` | Confirm in PDF |
| 03 — Resiliency | Defender for Cloud (Servers P2) | Microsoft Defender for Cloud | Microsoft Defender for Cloud | Protected server-hours | `evidence-package/b2.1-acr/cost-export-2026Qx.csv` | Confirm in PDF |
| 04 — AKS on Arc | AKS enabled by Azure Arc | Arc-enabled Kubernetes | Azure Kubernetes Service / Azure Arc | vCPU-hours + extensions | `evidence-package/b2.1-acr/cost-export-2026Qx.csv` | Confirm in PDF |

## Audit-window summary (filled — figures fictitious)

| Field | Value |
| --- | --- |
| Qualifying window | `[PLACEHOLDER — see official Module B control PDF]` |
| Eligible ACR threshold | `[PLACEHOLDER — see official Module B control PDF]` |
| Measured eligible ACR in window | `‹illustrative — pull real figure from Cost Management›` |
| Currency | `‹illustrative›` |
| Threshold met? | `[PLACEHOLDER — Yes / No, after PDF check]` |

## Worked narrative

> *Northwind Cloud* ran the microhack against subscription `‹sub-id›`, resource group
> `rg-mhb-nwc`. They exported **Cost analysis** grouped by *Service name* for the window and
> stored it at `evidence-package/b2.1-acr/cost-export-2026Qx.csv`. Each row above reconciles to
> a meter category in that export. Eligibility of every candidate category was **left for PDF
> confirmation** — the team did not assert eligibility or a dollar threshold from memory.

See the source template for the full "how to verify amounts and eligibility" guidance:
[../templates/acr-eligible-services-map.md](../templates/acr-eligible-services-map.md).
