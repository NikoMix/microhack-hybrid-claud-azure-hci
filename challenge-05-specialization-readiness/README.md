# Challenge 05 — Specialization Readiness

Turn the hybrid estate you built across challenges 01–04 into **Module B audit evidence**. In
this workshop you map your deployed resources to eligible **Azure Consumption Revenue (ACR)**,
build a **customer-diversity** table, produce a **certification** gap analysis and study plan,
assemble the **evidence package** with a pre-audit self-assessment, and collate **partner
onboarding assets** — all as real, reusable templates the partner keeps after the lab.

> [!IMPORTANT]
> This challenge **never** states Module B numeric thresholds (ACR amount, customer count,
> certified-individual count, qualifying window). Those live only in the **current
> Microsoft-issued Advanced Specialization requirements PDF**. Every template leaves a clearly
> marked `[PLACEHOLDER — see official Module B control PDF]` for you to confirm there.

## 🎯 Objectives

By the end of this challenge you will be able to:

- Map resources deployed in challenges 01–04 to **candidate eligible ACR** categories (B.2.1).
- Build a pseudonymized **customer-diversity** evidence table (B.2.2).
- Produce a **certification** coverage matrix and study plan for AZ-800/AZ-801/AZ-104/AZ-305,
  mapped to the lab challenges (B.3.1).
- Assemble a **Module B evidence package** with an Evidence Index and a completed **pre-audit
  self-assessment** (B.4.1).
- Collate reusable **partner onboarding assets** and runbooks (B.4.2).

## 🧩 Module B coverage

| Control | Evidence created in this challenge |
| --- | --- |
| **B.2.1 — ACR performance** | [ACR eligible-services map](templates/acr-eligible-services-map.md) linking each deployed resource to a candidate ACR category. |
| **B.2.2 — Customer diversity** | [Customer-diversity map](templates/customer-diversity-map.md) of distinct, pseudonymized customers. |
| **B.3.1 — Certifications** | [Certification coverage matrix](templates/certification-coverage-matrix.csv) + [study plan](templates/certification-study-plan.md) mapped to lab challenges. |
| **B.4.1 — Audit readiness** | [Evidence Index](templates/evidence-index.md) + [pre-audit self-assessment](templates/pre-audit-self-assessment.md). |
| **B.4.2 — Partner onboarding assets** | [Partner onboarding pack](templates/partner-onboarding-pack.md) + [runbook template](templates/runbook-template.md). |

> [!NOTE]
> Verify exact current specialization thresholds, eligible services, and certification lists in
> the Microsoft-issued Advanced Specialization requirements PDF before relying on them in a live
> audit.

## ⏱️ Duration & prerequisites

- **Duration:** ~60 minutes.
- **Required completed challenges:** [00](../challenge-00-setup/), [01](../challenge-01-arc-foundations/),
  [02](../challenge-02-observability/), [03](../challenge-03-resiliency/), [04](../challenge-04-aks-arc/).
- **Required access:** Azure subscription **Reader** is enough for the inventory step; **Owner**
  if you also pull Cost Management.
- **Expected resource group:** `rg-mhb-<initials>`.

> [!TIP]
> This is mostly a **documentation** challenge. Copy each file from [`templates/`](templates/)
> into your private evidence package and fill it. Worked exemplars live in [`assets/`](assets/).

### Template catalogue

| Template | Control | Sample |
| --- | --- | --- |
| [acr-eligible-services-map.csv](templates/acr-eligible-services-map.csv) / [.md](templates/acr-eligible-services-map.md) | B.2.1 | [sample](assets/sample-acr-eligible-services-map.md) |
| [customer-diversity-map.csv](templates/customer-diversity-map.csv) / [.md](templates/customer-diversity-map.md) | B.2.2 | [sample](assets/sample-customer-diversity-map.md) |
| [certification-coverage-matrix.csv](templates/certification-coverage-matrix.csv) + [study-plan.md](templates/certification-study-plan.md) | B.3.1 | [sample](assets/sample-certification-study-plan.md) |
| [evidence-index.md](templates/evidence-index.md) + [pre-audit-self-assessment.md](templates/pre-audit-self-assessment.md) | B.4.1 | [sample](assets/sample-evidence-index.md) |
| [partner-onboarding-pack.md](templates/partner-onboarding-pack.md) + [runbook-template.md](templates/runbook-template.md) | B.4.2 | [sample](assets/sample-arc-onboarding-runbook.md) |

## 🛠️ Tasks

### Task 1 — Map deployed resources to eligible ACR (B.2.1)

1. List what you actually deployed:

   ```bash
   az resource list --resource-group "rg-mhb-<initials>" -o table
   ```

1. Copy [`templates/acr-eligible-services-map.csv`](templates/acr-eligible-services-map.csv)
   and its [`.md`](templates/acr-eligible-services-map.md) into your evidence package and edit
   the rows so each maps **your** resource to a *candidate* ACR category.
1. Leave every eligibility cell as **Confirm in PDF** and every threshold/amount as a
   `[PLACEHOLDER — see official Module B control PDF]`.
1. Note how to pull real figures from **Azure Cost Management** for the qualifying window.

### Task 2 — Build the customer-diversity table (B.2.2)

1. Copy [`templates/customer-diversity-map.csv`](templates/customer-diversity-map.csv) /
   [`.md`](templates/customer-diversity-map.md).
1. Add one row per **distinct** customer, **pseudonymized** (e.g. `Customer-A`). Store the real
   name key securely **outside** the repo.
1. Cite a verifiable evidence reference per customer (SOW, claimed tenant, deal ID, case).
1. Keep the required count and window as placeholders pending the PDF.

### Task 3 — Certification coverage & study plan (B.3.1)

1. Fill [`templates/certification-coverage-matrix.csv`](templates/certification-coverage-matrix.csv):
   mark each person **Held / In progress / Gap** for AZ-104, AZ-800, AZ-801, AZ-305.
1. Use the lab→exam-domain mapping in
   [`templates/certification-study-plan.md`](templates/certification-study-plan.md) to argue the
   microhack is genuine exam preparation.
1. Draft a per-person study plan for every **Gap**, linking the official exam pages and the
   matching lab challenge.

### Task 4 — Assemble the evidence package & self-assessment (B.4.1)

1. Create the evidence-package folder structure shown in
   [`templates/evidence-index.md`](templates/evidence-index.md).
1. Fill the **Evidence Index**, cross-linking the runbooks/diagrams/protection evidence you
   produced in [02](../challenge-02-observability/), [03](../challenge-03-resiliency/), and
   [04](../challenge-04-aks-arc/). Confirm every path resolves (no dangling links).
1. Complete [`templates/pre-audit-self-assessment.md`](templates/pre-audit-self-assessment.md),
   assigning **Met / Partial / Not yet / Unknown** per control and citing the path. Mark any
   PDF-gated control **Partial** until verified.

### Task 5 — Collate partner onboarding assets (B.4.2)

1. Fill [`templates/partner-onboarding-pack.md`](templates/partner-onboarding-pack.md): the
   onboarding checklist, runbook catalogue, and handover acceptance.
1. Ensure each reusable runbook follows the
   [`templates/runbook-template.md`](templates/runbook-template.md) structure (see the worked
   [Arc onboarding runbook](assets/sample-arc-onboarding-runbook.md)).
1. Link the pack from the Evidence Index.

> [!TIP]
> In [Challenge 06](../challenge-06-ai-capstone/) you let the **Module B Audit Agent** and the
> `evidence-validator`, `acr-eligibility-mapper`, and `cert-gap-checker` skills run against the
> exact artifacts you produce here — and open GitHub Issues for any gaps.

## ✅ Success criteria

- [ ] One concrete artifact exists per control: B.2.1, B.2.2, B.3.1, B.4.1, B.4.2.
- [ ] The ACR map links each deployed resource to a candidate category with eligibility marked
      **Confirm in PDF**.
- [ ] The customer-diversity table is pseudonymized and cites evidence per customer.
- [ ] The certification matrix covers AZ-800/AZ-801/AZ-104/AZ-305 with a study plan for gaps.
- [ ] The Evidence Index cross-links artifacts from challenges 01–04 and every path resolves.
- [ ] The pre-audit self-assessment has a verdict per control; PDF-gated items are not claimed
      **Met** without a PDF check.
- [ ] **No** invented Module B numbers — every threshold is a clearly marked placeholder.

## 🧹 Cleanup

This challenge creates **no Azure resources** — it produces documents. Keep your evidence
package; you reuse it in [Challenge 06](../challenge-06-ai-capstone/).

End-of-day infrastructure teardown is covered in [../docs/teardown.md](../docs/teardown.md).

## 📚 References

- [Advanced Specializations (Microsoft partner)](https://learn.microsoft.com/partner-center/membership/advanced-specializations)
- [Azure Cost Management — cost analysis](https://learn.microsoft.com/azure/cost-management-billing/costs/quick-acm-cost-analysis)
- [Exam AZ-800](https://learn.microsoft.com/credentials/certifications/exams/az-800/) ·
  [AZ-801](https://learn.microsoft.com/credentials/certifications/exams/az-801/) ·
  [AZ-104](https://learn.microsoft.com/credentials/certifications/exams/az-104/) ·
  [AZ-305](https://learn.microsoft.com/credentials/certifications/exams/az-305/)
- [Claim partner of record (PAL / CPOR)](https://learn.microsoft.com/partner-center/claim-partner-of-record)
- [Module B coverage matrix (repo root)](../README.md)
