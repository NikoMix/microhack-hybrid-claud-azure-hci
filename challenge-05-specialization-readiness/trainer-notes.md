# Trainer notes — Challenge 05 · Specialization Readiness

Private facilitation guidance. This is a **workshop + artifact-generation** challenge: pupils
turn the estate from 01–04 into a Module B evidence package. The single most important teaching
point is **honesty about thresholds** — the lab proves *capability*, the PDF defines the *bar*.

## Timing

| Segment | Minutes | Trainer cue |
| --- | --- | --- |
| Frame: capability vs. audit bar | 5 | "We never quote Module B numbers from memory." Show a `[PLACEHOLDER]`. |
| Task 1 — ACR map (B.2.1) | 12 | Run `az resource list` live; map families, not SKUs. Eligibility = Confirm in PDF. |
| Task 2 — Customer diversity (B.2.2) | 8 | Pseudonymize; key stays off-repo. Watch for committed customer names. |
| Task 3 — Certifications (B.3.1) | 12 | Fill the matrix; map labs to exam domains; one study plan per gap. |
| Task 4 — Evidence package (B.4.1) | 15 | Build the folder tree; fill the index; verdicts, citing paths. |
| Task 5 — Onboarding assets (B.4.2) | 6 | Reuse the runbook template; link 02/03/04 runbooks. |
| Checkpoint + bridge to 06 | 2 | These artifacts are the input to the capstone agents. |

**Total:** ~60 min. If short on time, do Tasks 1 and 4 hands-on and walk through 2/3/5 from the
samples in [`assets/`](assets/).

## Talk track

> "You've spent the day building a hybrid estate. An audit doesn't ask *can you build it* — it
> asks *can you prove it, repeatedly, for real customers, with certified people*. That's what
> Module B's business controls are: ACR performance, customer diversity, certifications, audit
> readiness, and reusable onboarding assets. Today we don't *guess* the numbers — Microsoft sets
> those in a PDF that changes. We assemble the **structure** so that the moment you have the
> current PDF, you drop the verified figures in and you're audit-ready. The discipline you're
> learning is: *evidence with a path, thresholds with a placeholder*."

Tie it back: **B.2.1/B.2.2/B.3.1/B.4.1/B.4.2** are the business half of the specialization; the
technical half (B.1.1) is everything pupils built in 01–04.

## Live demo script

1. On the projector, open [`templates/acr-eligible-services-map.md`](templates/acr-eligible-services-map.md)
   and show the **Eligibility = Confirm in PDF** column. Make the point: we never assert eligibility.
1. Run `az resource list --resource-group "rg-mhb-<initials>" -o table` and map two rows live.
1. Open [`templates/evidence-index.md`](templates/evidence-index.md); show the folder tree and how
   each control links to a real artifact from 01–04.
1. Open [`templates/pre-audit-self-assessment.md`](templates/pre-audit-self-assessment.md) and the
   filled [sample](assets/sample-pre-audit-self-assessment.md); show why B.2.x is **Partial**, not
   **Met**, until the PDF is checked.
1. Bridge: "In Challenge 06 the **Module B Audit Agent** scores *these* files automatically."

## Common pitfalls

| Symptom | Likely cause | Fix |
| --- | --- | --- |
| Pupil writes a dollar/customer number | Recalling an old threshold | Replace with `[PLACEHOLDER — see official Module B control PDF]`. |
| Customer name committed to git | Skipped pseudonymization | Use `Customer-A`; keep the key off-repo; scrub history if needed. |
| Evidence Index has dangling links | Linked a file that isn't there yet | Link the challenge **folder**, or produce the artifact first. |
| "All controls Met" with no PDF | Over-confidence | PDF-gated controls are **Partial** until verified. |
| ACR mapped by SKU, endlessly | Too granular | Map by **service family**, not every meter. |

## Checkpoint questions & answers

1. **Q:** Where should exact Module B thresholds be verified?
   **A:** In the **current Microsoft-issued Advanced Specialization requirements PDF** — never
   from memory or from this lab's content.
1. **Q:** What is the difference between doing the lab and being audit-ready?
   **A:** The lab creates sample capability evidence; audit readiness also requires current
   requirements, customer proof, eligible services, certifications, and documented, repeatable
   processes.
1. **Q:** Why mark ACR eligibility "Confirm in PDF" instead of asserting it?
   **A:** The eligible-service list changes between PDF revisions; asserting eligibility risks a
   failed audit. The mapping is qualitative until confirmed.
1. **Q:** Why pseudonymize customers in the diversity table?
   **A:** Customer names and tenant IDs are confidential; the evidence needs to prove *distinct
   qualifying customers* without leaking identities into a shared repo.

## Reset between cohorts

- No Azure resources are created here, so there is nothing to deprovision.
- If pupils filled templates in a fork/branch, discard their working copies:
  `git restore challenge-05-specialization-readiness/` (review first).
- Confirm no real customer names or transcript links were committed; if so, scrub and rotate.
- The [`templates/`](templates/) and [`assets/`](assets/) files are the reset baseline — leave
  them unchanged for the next cohort.
