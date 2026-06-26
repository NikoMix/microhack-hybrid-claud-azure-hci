# Template — Partner onboarding pack (B.4.2)

> A reusable pack a partner hands to each new Azure Local / Azure Arc engagement. It bundles
> the onboarding checklist, the runbook catalogue, and the handover artifacts that evidence
> **Module B control B.4.2 (Partner Onboarding Assets)**.

> [!TIP]
> Keep this pack **engagement-agnostic and parameterized**. Swap in customer specifics only in
> a private working copy — never commit a customer name, tenant ID, or secret to a shared repo.

## 1. Engagement summary

| Field | Value |
| --- | --- |
| Customer (pseudonymized) | `[PLACEHOLDER — e.g. Customer-A]` |
| Engagement type | `[PLACEHOLDER — migration / greenfield / managed ops]` |
| Primary Azure Local / Arc workloads | `[PLACEHOLDER]` |
| Target region | `[PLACEHOLDER — e.g. swedencentral]` |
| Partner lead | `[PLACEHOLDER — name / role]` |

## 2. Onboarding checklist

| Phase | Task | Owner | Linked runbook | Status |
| --- | --- | --- | --- | --- |
| Discover | Capture estate inventory + requirements | `<role>` | — | `[ ]` |
| Land | Deploy the Azure landing zone (AVM Terraform) | `<role>` | [Base IaC](../../challenge-00-setup/) | `[ ]` |
| Onboard | Azure Arc-enable the servers | `<role>` | [Arc onboarding](../../challenge-01-arc-foundations/) | `[ ]` |
| Operate | Wire up Monitor + Update Manager | `<role>` | [Observability](../../challenge-02-observability/) | `[ ]` |
| Protect | Configure Backup / ASR / Defender | `<role>` | [Resiliency](../../challenge-03-resiliency/) | `[ ]` |
| Modernize | AKS enabled by Azure Arc + GitOps | `<role>` | [AKS on Arc](../../challenge-04-aks-arc/) | `[ ]` |
| Handover | Deliver runbooks + evidence package | `<role>` | [Evidence Index](./evidence-index.md) | `[ ]` |

## 3. Runbook catalogue

Every reusable runbook follows the [runbook template](./runbook-template.md) (9-section
structure). Populate this catalogue as runbooks are produced.

| Runbook | Purpose | Source | Status |
| --- | --- | --- | --- |
| Arc onboarding | Connect servers to Azure Arc | [Challenge 01](../../challenge-01-arc-foundations/) | `[PLACEHOLDER — link]` |
| Observability | Monitor + Update Manager baseline | [Challenge 02](../../challenge-02-observability/) | `[PLACEHOLDER — link]` |
| Backup & DR | Azure Backup + Site Recovery | [Challenge 03](../../challenge-03-resiliency/) | `[PLACEHOLDER — link]` |
| Patching | Azure Update Manager schedules | [Challenge 02](../../challenge-02-observability/) | `[PLACEHOLDER — link]` |
| Incident response | Triage + escalation | New (use the template) | `[PLACEHOLDER — link]` |

## 4. Governance & guardrails handover

- **Naming:** `rg-mhb-<initials>`, `*-mhb-<initials>-<challenge>`.
- **Identity & access:** least-privilege RBAC; `az login` / managed identity only.
- **Cost guardrails:** small/consumption SKUs; document resources that incur lingering cost.
- **Tags:** apply the shared `tags` map for ownership and cost allocation.

## 5. Roles & RACI

| Activity | Responsible | Accountable | Consulted | Informed |
| --- | --- | --- | --- | --- |
| Landing-zone deployment | `<role>` | `<role>` | `<role>` | `<role>` |
| Arc onboarding | `<role>` | `<role>` | `<role>` | `<role>` |
| Protection & DR | `<role>` | `<role>` | `<role>` | `<role>` |
| Evidence & audit readiness | `<role>` | `<role>` | `<role>` | `<role>` |

## 6. Handover acceptance

- [ ] All onboarding-checklist phases complete or explicitly deferred.
- [ ] Runbook catalogue populated with resolving links.
- [ ] Evidence package handed over and indexed in the [Evidence Index](./evidence-index.md).
- [ ] Customer sign-off recorded `[PLACEHOLDER — date / signatory]`.

## References

- [Cloud Adoption Framework — Azure landing zones](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/landing-zone/)
- [Azure Arc-enabled servers overview](https://learn.microsoft.com/azure/azure-arc/servers/overview)
- [Advanced Specializations (Microsoft partner)](https://learn.microsoft.com/partner-center/membership/advanced-specializations)
