---
name: runbook-generator
description: >-
  Generate a clear, repeatable Azure operational runbook (onboarding, monitoring,
  backup/DR, patching, or incident response) from the lab's hybrid environment. Use
  when a learner asks to create, draft, or standardize a runbook, operational
  procedure, or partner onboarding asset — primary evidence for Module B control B.4.2.
---

# Runbook Generator

Produce a production-quality **operational runbook** that a partner could reuse on a real
Azure Local / Azure Arc engagement. Runbooks are the core **B.4.2 (Partner Onboarding
Assets)** deliverable and also strengthen **B.1.1**.

## When to use

- "Generate an Arc onboarding runbook", "draft a backup & DR runbook", "create a patching
  runbook with Azure Update Manager", "standardize this procedure as a runbook".

## Required runbook structure

Generate Markdown with these sections, in order:

1. `# <Runbook title>`
2. `## Purpose & scope` — what this automates and the boundaries.
3. `## Prerequisites` — access/RBAC, registered providers, tools, inputs (parameterized,
   e.g. `<initials>`, `<region>`).
4. `## Roles & RACI` — who runs/approves/is informed.
5. `## Procedure` — numbered, copy-pasteable steps. Each Azure-changing step shows the
   exact `az`/`azcmagent`/`terraform` command and an expected result.
6. `## Validation` — how to confirm success (commands + what "good" looks like).
7. `## Rollback / recovery` — how to undo or recover.
8. `## Evidence captured` — which Module B control this supports and what artifact to file
   in the evidence package.
9. `## References` — Microsoft Learn links.

## Procedure

1. Confirm the runbook topic and the target resources (resource group `rg-mhb-<initials>`).
2. Pull real specifics from the environment where possible (resource names, regions).
3. Fill the template above with correct, current product names and idempotent commands
   (`set -euo pipefail` for any bash; no hardcoded names).
4. Write the runbook to the relevant challenge's `assets/` folder and add it to the
   Evidence Index.

## Guardrails

- Commands must be safe and idempotent; mark destructive steps with `> [!WARNING]`.
- No secrets in the runbook; reference `az login` / managed identity.
- Keep it engagement-agnostic (parameterized) so it's genuinely reusable.

## Output

A single self-contained runbook Markdown file following the structure above, plus a
one-line note of where it was saved and which control it evidences.
