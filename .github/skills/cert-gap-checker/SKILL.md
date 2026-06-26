---
name: cert-gap-checker
description: >-
  Check a team's Microsoft certifications against Module B control B.3.1 requirements and
  produce a gap analysis plus a study plan. Use when a learner asks about required certs
  (e.g. AZ-800, AZ-801, AZ-104, AZ-305), certification readiness, or a training plan for
  the Hybrid Cloud Infrastructure with Microsoft Azure Local specialization.
---

# Certification Gap Checker

Compare the people on a partner team against the **certification requirements for Module B
control B.3.1** and output a gap analysis and a concrete study plan.

## When to use

- "Do we have the certs for Module B?", "what's our certification gap?", "build a study
  plan for AZ-800/AZ-801", "who needs which exam?".

## Guardrail

> [!IMPORTANT]
> The **exact required certifications and the number of certified individuals** are set in
> the **current Microsoft-issued requirements PDF** and can change. Treat the exam list
> below as the *typical* hybrid-infrastructure set and tell the user to confirm the
> authoritative list and counts in the PDF. Do not assert a specific required headcount.

## Typical hybrid-infrastructure certifications

- **AZ-800** — Administering Windows Server Hybrid Core Infrastructure.
- **AZ-801** — Configuring Windows Server Hybrid Advanced Services.
- **AZ-104** — Azure Administrator (common foundation).
- **AZ-305** — Designing Microsoft Azure Infrastructure Solutions (architecture depth).

(Confirm the precise required set/counts in the official PDF.)

## Procedure

1. Ask the learner for the team roster and each person's current certifications (or read a
   provided roster file).
2. Build a **coverage matrix**: Person × {AZ-800, AZ-801, AZ-104, AZ-305, …} marking
   Held / In progress / Gap.
3. Identify gaps against the typical set and flag where the official PDF count must be
   confirmed.
4. Produce a **study plan** per person with the target exam, key skill domains, official
   Microsoft Learn learning paths, and a suggested timeline.
5. Offer to open GitHub Issues tracking each person's certification path.

## Output

Two Markdown tables — the coverage matrix and the prioritized study plan — plus a note to
confirm the authoritative requirement in the PDF. Link Microsoft Learn paths for each exam.
