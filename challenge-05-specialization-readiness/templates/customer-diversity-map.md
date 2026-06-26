# Template — Customer-diversity map (B.2.2)

> Reusable template for evidencing **distinct qualifying customers** for **Module B control
> B.2.2 (Customer Diversity)**. Machine-readable companion:
> [`customer-diversity-map.csv`](./customer-diversity-map.csv).

> [!IMPORTANT]
> The **required number of distinct customers**, the **qualifying window**, and the
> **per-customer ACR rules** are defined only in the **current Microsoft-issued Advanced
> Specialization requirements PDF** and change over time. Do **not** invent a customer count
> or threshold. Leave every `[PLACEHOLDER — see official Module B control PDF]` until you have
> verified it against that PDF.

> [!WARNING]
> Customer names and tenant identifiers are confidential. Use **pseudonymized references**
> (for example `Customer-A`) in this repository. Keep the name-to-reference key in a secure,
> access-controlled location — never commit it.

## How to use this template

1. Add one row per distinct customer that you intend to count toward B.2.2.
1. Pseudonymize each customer and record the real mapping outside the repo.
1. For each customer, cite the **evidence reference** that proves the engagement
   (signed SOW, Microsoft partner-of-record / claimed tenant, deal ID, or case reference).
1. Confirm the **distinct-customer count** and **qualifying window** against the official PDF
   before claiming the control is met.
1. Link the completed map from the [Evidence Index](./evidence-index.md).

## Diversity table

| Customer (pseudonymized) | Industry / segment | Region | Engagement type | Azure Local / Arc workload | Qualifying window | Distinct-customer evidence | ACR contribution | Status |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Customer-A | `[PLACEHOLDER]` | `[PLACEHOLDER]` | Production deployment | Azure Arc-enabled servers + Azure Monitor | `[PLACEHOLDER — see official Module B control PDF]` | `[PLACEHOLDER — SOW / tenant ID / case ref]` | Confirm in PDF | Won |
| Customer-B | `[PLACEHOLDER]` | `[PLACEHOLDER]` | Migration + resiliency | Azure Backup + Azure Site Recovery | `[PLACEHOLDER — see official Module B control PDF]` | `[PLACEHOLDER — SOW / tenant ID / case ref]` | Confirm in PDF | In delivery |
| Customer-C | `[PLACEHOLDER]` | `[PLACEHOLDER]` | Modern workloads | AKS enabled by Azure Arc + GitOps | `[PLACEHOLDER — see official Module B control PDF]` | `[PLACEHOLDER — SOW / tenant ID / case ref]` | Confirm in PDF | Won |

## Diversity summary (verify against the PDF — do not invent)

| Field | Value |
| --- | --- |
| Required distinct customers | `[PLACEHOLDER — see official Module B control PDF]` |
| Distinct customers evidenced here | `[PLACEHOLDER — count your filled rows]` |
| Qualifying window | `[PLACEHOLDER — see official Module B control PDF]` |
| Per-customer ACR rule | `[PLACEHOLDER — see official Module B control PDF]` |
| Diversity requirement met? | `[PLACEHOLDER — Yes / No, after PDF check]` |

## Evidence quality checklist

- [ ] Each customer is genuinely **distinct** (no double-counting affiliates/subsidiaries).
- [ ] Each row cites a verifiable artifact (SOW, claimed/associated tenant, deal ID, case).
- [ ] Engagements fall inside the **qualifying window** confirmed in the PDF.
- [ ] The name-to-reference key is stored securely **outside** this repository.
- [ ] Counts cross-check with the [ACR map](./acr-eligible-services-map.md) where required.

## References

- [Advanced Specializations (Microsoft partner)](https://learn.microsoft.com/partner-center/membership/advanced-specializations)
- [Partner of record (PAL / CPOR) overview](https://learn.microsoft.com/partner-center/claim-partner-of-record)
