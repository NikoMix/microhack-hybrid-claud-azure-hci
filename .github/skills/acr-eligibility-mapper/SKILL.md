---
name: acr-eligibility-mapper
description: >-
  Map deployed Azure resources and delivered work to eligible Azure Consumption Revenue
  (ACR) categories for Module B control B.2.1. Use when a learner asks which services
  count toward ACR, to build an ACR mapping table, or to evidence consumption for the
  Hybrid Cloud Infrastructure with Microsoft Azure Local specialization.
---

# ACR Eligibility Mapper

Help a partner map the Azure services they deployed/operated to the **eligible Azure
Consumption Revenue** categories for **Module B control B.2.1 (ACR Performance)** and
produce a clean mapping table for the evidence package.

## When to use

- "Which of my resources count toward ACR?", "build my B.2.1 ACR mapping", "map today's
  deployments to consumption categories".

## Important guardrail

> [!IMPORTANT]
> The **eligible-service list and the ACR threshold amount** are defined only in the
> **current Microsoft-issued Advanced Specialization requirements PDF** and change over
> time. Do **not** assert a specific dollar threshold or guarantee a service is eligible.
> Produce the mapping qualitatively and tell the user to confirm both the eligible list
> and the amount against the official PDF.

## Procedure

1. Enumerate the learner's resources — prefer the `azure` MCP server (Resource Graph /
   `resource list` on `rg-mhb-<initials>`); otherwise read the Terraform in `infra/` and
   each challenge's `infra/`.
2. Group resources by Azure service family relevant to hybrid (e.g. Azure Arc–enabled
   servers/Kubernetes, Azure Monitor / Log Analytics, Azure Backup, Azure Site Recovery,
   Microsoft Defender for Cloud, Azure Update Manager, AKS).
3. For each, note: resource, service family, the **likely** ACR category, and the
   consumption signal (what drives billing). Mark eligibility as **Confirm in PDF**.
4. Emit a mapping table: Resource · Service family · Candidate ACR category · Consumption
   signal · Evidence path · Eligibility (Confirm in PDF).
5. Add a short note on how to pull real consumption figures (Cost Management / Azure
   Monitor) for the audit window.

## Output

A Markdown mapping table plus a one-paragraph "how to verify amounts and eligibility"
note. Never present a fabricated threshold or a definitive eligibility claim.
