# Challenge template

Copy this template when authoring or refreshing Challenges 01-05. Keep the
headings exactly as shown so the repository stays consistent with the authoring
conventions.

> [!NOTE]
> Replace `0X`, `Title`, durations, commands, and links. Keep resource names
> aligned with `rg-mhb-<initials>`, `*-mhb-<initials>-<challenge>`, and default
> region `swedencentral`.

## Student README skeleton

````markdown
# Challenge 0X — Title

<!-- One short paragraph: what the pupil will build and why it matters to the Contoso migration story. -->

## 🎯 Objectives

<!-- 3-5 measurable objectives. Use active verbs: deploy, connect, validate, query, document. -->

By the end of this challenge, you will be able to:

- Objective 1.
- Objective 2.
- Objective 3.

## 🧩 Module B coverage

<!-- Map the challenge to Module B controls. Do not invent numeric thresholds. Link the technical artifact to business evidence. -->

| Control | Evidence created in this challenge |
| --- | --- |
| B.x.x | Evidence statement. |

> [!NOTE]
> Verify exact current specialization thresholds in the Microsoft-issued Advanced Specialization requirements PDF.

## ⏱️ Duration & prerequisites

<!-- State the timebox, completed prior challenges, required Azure permissions, and expected deployed resources. -->

- Duration: `<minutes>`.
- Required completed challenges: Challenge 00 and `<others>`.
- Required access: Azure subscription Owner.
- Expected resource group: `rg-mhb-<initials>`.

## 🛠️ Tasks

<!-- Use numbered, runnable steps. Prefer Azure CLI or Terraform commands that pupils can copy. Explain portal steps only when needed. -->

### Task 1 — Verb phrase

1. Do the first action:

   ```bash
   command goes here
   ```

1. Validate the result:

   ```bash
   validation command goes here
   ```

### Task 2 — Verb phrase

1. Continue with the next action.
1. Capture the evidence requested by the trainer.

## ✅ Success criteria

<!-- Checklist the exact observable results. These should align with docs/grading-checkpoints.md. -->

- [ ] Criterion 1.
- [ ] Criterion 2.
- [ ] Criterion 3.

## 🧹 Cleanup

<!-- State whether resources stay for later challenges or must be removed now. Link to docs/teardown.md for final cleanup. -->

Keep these resources for later challenges:

- Resource or service name.

End-of-day cleanup is covered in [../docs/teardown.md](../docs/teardown.md).

## 📚 References

<!-- Use Microsoft Learn and stable product documentation. Keep links relevant and relative where linking inside the repo. -->

- [Azure Arc-enabled servers overview](https://learn.microsoft.com/azure/azure-arc/servers/overview)
````

## Trainer notes skeleton

````markdown
# Challenge 0X trainer notes

<!-- Optional one-paragraph private trainer context. Keep one H1 only. -->

## Timing

<!-- Break the challenge into 5-15 minute segments. Name the minimum viable checkpoint. -->

| Minute | Activity | Trainer cue |
| ---: | --- | --- |
| 0-5 | Context and demo | Explain why this matters. |
| 5-25 | Hands-on task | Watch for common blocker. |
| 25-30 | Checkpoint | Ask questions below. |

## Talk track

<!-- Short narrative the trainer can say aloud. Tie to Contoso and Module B. -->

"Talk track text goes here."

## Live demo script

<!-- Commands or portal clicks for the trainer's demo. Keep it short and recoverable. -->

1. Show the current state:

   ```bash
   command goes here
   ```

1. Perform the demo action.
1. Show the validation output.

## Common pitfalls

<!-- Include symptom, likely cause, and fix. Link to docs/troubleshooting.md when possible. -->

| Symptom | Likely cause | Fix |
| --- | --- | --- |
| Symptom text | Cause text | Fix text. |

## Checkpoint questions & answers

<!-- Keep answers concise. These should match docs/grading-checkpoints.md. -->

**Q1. Question?**

A: Model answer.

**Q2. Question?**

A: Model answer.

## Reset between cohorts

<!-- State exactly what must be removed, reset, or pre-created before the next class. Include Terraform, Azure portal, and manual cleanup notes. -->

- Run challenge-specific cleanup if applicable.
- Confirm [../docs/teardown.md](../docs/teardown.md) removes all shared resources.
- Recreate only the resources intentionally needed for the next cohort.
````
