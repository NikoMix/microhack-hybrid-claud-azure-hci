# Template — Pre-audit self-assessment (B.4.1)

> A control-by-control self-assessment you complete **before** an Advanced Specialization
> audit. It assigns a verdict to each Module B control and cites the evidence in the
> [Evidence Index](./evidence-index.md). Together they are the core **B.4.1 (Audit Readiness)**
> deliverable.

> [!IMPORTANT]
> This checklist scores **structure and traceability**, not the numeric bar. The required ACR
> amount, customer count, certified-individual count, and qualifying window live only in the
> **current Microsoft-issued Advanced Specialization requirements PDF**. Confirm each
> `[PLACEHOLDER — see official Module B control PDF]` there before claiming a control is met.

## Verdict legend

| Verdict | Meaning |
| --- | --- |
| **Met** | Evidence exists, resolves, and (where numeric) is confirmed against the PDF. |
| **Partial** | Some evidence exists but is incomplete or unverified. |
| **Not yet** | No evidence assembled yet. |
| **Unknown** | Cannot determine from the artifacts currently visible. |

## Readiness scorecard

| Control | Title | Verdict | Cited evidence (path) | PDF check needed? |
| --- | --- | --- | --- | --- |
| B.1.1 | Implementation capability | `[Met/Partial/Not yet/Unknown]` | [../../docs/architecture/](../../docs/architecture/) | No |
| B.2.1 | ACR performance | `[Met/Partial/Not yet/Unknown]` | [./acr-eligible-services-map.md](./acr-eligible-services-map.md) | Yes — amount + eligible list |
| B.2.2 | Customer diversity | `[Met/Partial/Not yet/Unknown]` | [./customer-diversity-map.md](./customer-diversity-map.md) | Yes — count + window |
| B.3.1 | Certifications | `[Met/Partial/Not yet/Unknown]` | [./certification-coverage-matrix.csv](./certification-coverage-matrix.csv) | Yes — required certs + count |
| B.4.1 | Audit readiness | `[Met/Partial/Not yet/Unknown]` | [./evidence-index.md](./evidence-index.md) | No |
| B.4.2 | Partner onboarding assets | `[Met/Partial/Not yet/Unknown]` | [./partner-onboarding-pack.md](./partner-onboarding-pack.md) | No |

## Detailed checklist

### B.1.1 — Implementation capability

- [ ] A hybrid **reference architecture** (diagram + narrative) is filed and current.
- [ ] A **deployed-resource inventory** (`az resource list` export) exists for `rg-mhb-<initials>`.
- [ ] **Arc onboarding** is evidenced (agent status, `azcmagent show`, or runbook).
- [ ] At least one **technical runbook** is filed (observability, backup/DR, or AKS-on-Arc).

### B.2.1 — ACR performance

- [ ] The [ACR eligible-services map](./acr-eligible-services-map.md) lists deployed resources.
- [ ] A **Cost Management export** for the qualifying window is attached.
- [ ] Eligible-service categories are **confirmed against the PDF**.
- [ ] Required amount `[PLACEHOLDER — see official Module B control PDF]` confirmed and compared.

### B.2.2 — Customer diversity

- [ ] The [customer-diversity map](./customer-diversity-map.md) has one row per distinct customer.
- [ ] Each customer cites a **verifiable artifact** (SOW, claimed tenant, deal ID, case).
- [ ] Customers are pseudonymized; the name key is stored **off-repo**.
- [ ] Required count + window `[PLACEHOLDER — see official Module B control PDF]` confirmed.

### B.3.1 — Certifications

- [ ] The [coverage matrix](./certification-coverage-matrix.csv) lists named individuals.
- [ ] Each **Held** cert cites a Microsoft Learn **transcript share link**.
- [ ] A [study plan](./certification-study-plan.md) closes every **Gap** / **In progress**.
- [ ] Required certs + headcount `[PLACEHOLDER — see official Module B control PDF]` confirmed.

### B.4.1 — Audit readiness

- [ ] The [Evidence Index](./evidence-index.md) exists and every path resolves.
- [ ] No **orphan** files and no **dangling** links.
- [ ] This self-assessment is completed and dated.

### B.4.2 — Partner onboarding assets

- [ ] A [partner onboarding pack](./partner-onboarding-pack.md) is filed.
- [ ] Reusable, **parameterized** runbooks exist (no hardcoded customer specifics).
- [ ] Onboarding assets follow the [runbook template](./runbook-template.md) structure.

## Sign-off

| Field | Value |
| --- | --- |
| Assessed by | `[PLACEHOLDER — name / role]` |
| Date | `[PLACEHOLDER — yyyy-mm-dd]` |
| Requirements PDF revision checked | `[PLACEHOLDER — PDF version / date]` |
| Overall readiness | `[PLACEHOLDER — Ready / Gaps remain]` |
| Open remediation items | `[PLACEHOLDER — link GitHub Issues]` |

## References

- [Advanced Specializations (Microsoft partner)](https://learn.microsoft.com/partner-center/membership/advanced-specializations)
- [Grading checkpoints (repo)](../../docs/grading-checkpoints.md)
