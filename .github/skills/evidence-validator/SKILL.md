---
name: evidence-validator
description: >-
  Validate a Module B Advanced Specialization evidence package for completeness and
  audit-readiness. Use when a learner asks to check, score, or validate their evidence
  package, evidence index, or pre-audit readiness for controls B.1.1–B.4.2 of the
  Hybrid Cloud Infrastructure with Microsoft Azure Local specialization.
---

# Evidence Validator

Validate that a Module B **evidence package** is complete, indexed, and audit-ready
across controls **B.1.1–B.4.2**. This skill checks structure and traceability — it does
**not** invent the numeric thresholds (those live in the official requirements PDF).

## When to use

- "Validate my evidence package", "is my Module B evidence audit-ready?", "score my
  pre-audit readiness", "what's missing for control B.4.1?"

## What a complete package contains

For each control, expect at least one cited artifact with a clear filename and a line in
the **Evidence Index**:

- **B.1.1** — reference architecture(s), deployed-resource inventory, Arc onboarding
  evidence, technical runbook(s).
- **B.2.1** — a mapping table from delivered work to eligible Azure Consumption Revenue
  categories (qualitative; confirm amounts in the PDF).
- **B.2.2** — a distinct-customer evidence table for the qualifying window.
- **B.3.1** — named individuals + their certifications (e.g. AZ-800/AZ-801), with proof
  references.
- **B.4.1** — the Evidence Index itself + a completed pre-audit self-assessment.
- **B.4.2** — repeatable onboarding assets / runbooks.

## Procedure

1. Locate the evidence package (default: `challenge-05-specialization-readiness/` and any
   `assets/` evidence folders). List what's present.
2. For each control, decide **Met / Partial / Not yet / Unknown** based only on artifacts
   you can actually see, and cite the path.
3. Check the **Evidence Index** exists and every listed artifact resolves to a real file
   (no broken links). Flag orphans (files not in the index) and dangling links.
4. Output a **validation report** table: Control · Verdict · Artifact(s) · Issue · Fix.
5. Summarize the top remediation actions. Offer to draft missing index entries.

## Guardrails

- Never assert a specific ACR amount, customer count, certification count, or time
  window — refer to the **current Microsoft-issued requirements PDF**.
- "Unknown" is correct when evidence isn't visible to you; say so plainly.
- Keep judgements traceable: every verdict cites a path.

## Output

A Markdown validation report (table first), then a prioritized fix list. No fabricated
numbers; no claims without a cited artifact.
