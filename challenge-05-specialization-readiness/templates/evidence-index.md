# Template — Module B evidence index (B.4.1)

> The single catalogue of every artifact in your **Module B evidence package**, cross-linking
> the work produced across challenges 01–06. Pair it with the
> [pre-audit self-assessment](./pre-audit-self-assessment.md), which assigns the per-control
> verdict. Together they are the core **B.4.1 (Audit Readiness)** deliverable.

> [!IMPORTANT]
> This index catalogues and **links** evidence; it does not assert that a control is *met*.
> Numeric thresholds (ACR amount, customer count, certified headcount, qualifying window) are
> defined only in the **current Microsoft-issued Advanced Specialization requirements PDF**.
> Keep every `[PLACEHOLDER — see official Module B control PDF]` until verified there.

## Recommended evidence-package folder structure

```text
evidence-package/
├── README.md                      # this index (copy of evidence-index.md)
├── b1.1-implementation/
│   ├── architecture/              # reference architecture diagram(s) + narrative
│   ├── inventory/                 # az resource list export(s) for rg-mhb-<initials>
│   ├── arc-onboarding/            # azcmagent connect logs / screenshots / runbook
│   └── runbooks/                  # technical operational runbooks
├── b2.1-acr/
│   └── acr-eligible-services-map.(csv|md) + Cost Management export
├── b2.2-diversity/
│   └── customer-diversity-map.(csv|md)   # pseudonymized; key stored OFF-repo
├── b3.1-certifications/
│   ├── certification-coverage-matrix.csv
│   └── transcript-links.md        # Microsoft Learn transcript share links
├── b4.1-audit/
│   ├── evidence-index.md          # this file
│   └── pre-audit-self-assessment.md
└── b4.2-onboarding/
    ├── partner-onboarding-pack.md
    └── runbooks/                  # reusable, parameterized runbooks
```

## Evidence index

Each row points to a real artifact. The **verdict** (Met / Partial / Not yet / Unknown) is
assigned in the [pre-audit self-assessment](./pre-audit-self-assessment.md), not here.

| Control | Evidence artifact | Type | Produced in | Path | Index status |
| --- | --- | --- | --- | --- | --- |
| B.1.1 | Hybrid reference architecture | Diagram + narrative | Docs / Challenge 01 | [../../docs/architecture/](../../docs/architecture/) | Link target |
| B.1.1 | Deployed-resource inventory (`az resource list`) | Export | Challenge 00 | [../../challenge-00-setup/](../../challenge-00-setup/) | Link target |
| B.1.1 | Arc onboarding evidence | Logs / runbook | Challenge 01 | [../../challenge-01-arc-foundations/](../../challenge-01-arc-foundations/) | Link target |
| B.1.1 | Observability runbook | Runbook | Challenge 02 | [../../challenge-02-observability/](../../challenge-02-observability/) | Link target |
| B.1.1 | Backup / DR runbook | Runbook | Challenge 03 | [../../challenge-03-resiliency/](../../challenge-03-resiliency/) | Link target |
| B.1.1 | AKS-on-Arc + GitOps runbook | Runbook | Challenge 04 | [../../challenge-04-aks-arc/](../../challenge-04-aks-arc/) | Link target |
| B.2.1 | ACR eligible-services map | Mapping table | Challenge 05 | [./acr-eligible-services-map.md](./acr-eligible-services-map.md) | Template ready |
| B.2.1 | Cost Management consumption export | Export | Partner (off-lab) | `[PLACEHOLDER — attach export]` | Not yet |
| B.2.2 | Customer-diversity map | Mapping table | Challenge 05 | [./customer-diversity-map.md](./customer-diversity-map.md) | Template ready |
| B.3.1 | Certification coverage matrix | Matrix | Challenge 05 | [./certification-coverage-matrix.csv](./certification-coverage-matrix.csv) | Template ready |
| B.3.1 | Certification study plan | Plan | Challenge 05 | [./certification-study-plan.md](./certification-study-plan.md) | Template ready |
| B.4.1 | Evidence index (this file) | Index | Challenge 05 | [./evidence-index.md](./evidence-index.md) | Template ready |
| B.4.1 | Pre-audit self-assessment | Checklist | Challenge 05 | [./pre-audit-self-assessment.md](./pre-audit-self-assessment.md) | Template ready |
| B.4.2 | Partner onboarding pack | Asset pack | Challenge 05 | [./partner-onboarding-pack.md](./partner-onboarding-pack.md) | Template ready |
| B.4.2 | Reusable runbook template | Template | Challenge 05 | [./runbook-template.md](./runbook-template.md) | Template ready |
| B.4.2 | AI-generated onboarding runbook | Runbook | Challenge 06 | [../../challenge-06-ai-capstone/](../../challenge-06-ai-capstone/) | Link target |

## Index hygiene rules

- **No orphans:** every file in the evidence package appears in exactly one index row.
- **No dangling links:** every path resolves to a real file before you present the package.
- **Pseudonymized:** no customer name, tenant ID, or personal data is committed.
- **Traceable verdicts:** the matching row in the
  [pre-audit self-assessment](./pre-audit-self-assessment.md) cites this same path.

## How to validate this index

Run the **`evidence-validator`** skill (see
[challenge 06](../../challenge-06-ai-capstone/)) or, manually, confirm each row's path
resolves and each control has at least one cited artifact. Then record the verdicts in the
[pre-audit self-assessment](./pre-audit-self-assessment.md).

## References

- [Advanced Specializations (Microsoft partner)](https://learn.microsoft.com/partner-center/membership/advanced-specializations)
- [Module B coverage matrix (repo root)](../../README.md)
