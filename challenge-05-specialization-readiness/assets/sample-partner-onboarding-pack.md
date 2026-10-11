# Sample — Partner onboarding pack (B.4.2, filled)

> [!NOTE]
> **Illustrative training sample** for a fictitious partner, *Northwind Cloud*, onboarding a
> fictitious *Customer-A*. Source template:
> [../templates/partner-onboarding-pack.md](../templates/partner-onboarding-pack.md).

## 1. Engagement summary (filled)

| Field | Value |
| --- | --- |
| Customer (pseudonymized) | Customer-A |
| Engagement type | Migration → managed operations |
| Primary Azure Local / Arc workloads | Arc-enabled servers + Backup + Monitor |
| Target region | swedencentral |
| Partner lead | `‹Northwind delivery lead›` |

## 2. Onboarding checklist (filled)

| Phase | Task | Owner | Linked runbook | Status |
| --- | --- | --- | --- | --- |
| Discover | Inventory + requirements | Engineer-2 | — | `[x]` |
| Land | Deploy landing zone (AVM) | Engineer-1 | [Base IaC](../../challenge-00-setup/) | `[x]` |
| Onboard | Arc-enable servers | Engineer-1 | [Arc runbook](./sample-arc-onboarding-runbook.md) | `[x]` |
| Operate | Monitor + Update Manager | Engineer-2 | [Observability](../../challenge-02-observability/) | `[x]` |
| Protect | Backup / ASR / Defender | Engineer-2 | [Resiliency](../../challenge-03-resiliency/) | `[ ]` |
| Modernize | AKS on Arc + GitOps | Architect-1 | [AKS on Arc](../../challenge-04-aks-arc/) | `[ ]` |
| Handover | Runbooks + evidence package | Architect-1 | [Evidence Index](./sample-evidence-index.md) | `[ ]` |

## 3. Runbook catalogue (filled)

| Runbook | Purpose | Source | Status |
| --- | --- | --- | --- |
| Arc onboarding | Connect servers to Azure Arc | [This pack](./sample-arc-onboarding-runbook.md) | Filed |
| Observability | Monitor + Update Manager baseline | [Challenge 02](../../challenge-02-observability/) | Filed |
| Backup & DR | Azure Backup + Site Recovery | [Challenge 03](../../challenge-03-resiliency/) | In progress |

## 4. Handover acceptance (filled)

- [x] Discover → Operate phases complete.
- [ ] Protect + Modernize phases scheduled.
- [x] Runbook catalogue links resolve.
- [ ] Customer sign-off recorded `‹pending Protect phase›`.

See the source template for governance/RACI sections:
[../templates/partner-onboarding-pack.md](../templates/partner-onboarding-pack.md).
