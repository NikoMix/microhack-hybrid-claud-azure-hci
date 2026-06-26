# Contributing

Thanks for helping improve this microhack! This is open training content (MIT). All tooling is open-source — no paid licenses required.

## Ground rules

- Keep every challenge **deliverable**: a student `README.md` and a `trainer-notes.md`.
- Follow the conventions in [`.github/copilot-instructions.md`](.github/copilot-instructions.md).
- Tie each hands-on task to the **Module B control** it evidences (B.1.1–B.4.2).
- Prefer **Azure Verified Modules** for Terraform. Small/consumption SKUs only.

## Local quality gates

Everything CI runs, you can run locally in the devcontainer:

```bash
task setup       # install git hooks + show toolchain
task lint        # markdown + terraform + actions
task validate    # terraform init + validate (base)
task security    # checkov + gitleaks
task links       # lychee link check
pre-commit run --all-files
```

## Pull requests

1. Branch from `main` (or the foundation branch if your work depends on it).
2. Keep PRs scoped to **one challenge or workstream** where possible.
3. Ensure CI is green (lint, terraform validate, security, actionlint).
4. Reference the GitHub Issue your PR closes.

## Reporting content issues

Open an issue using the **Content / lab issue** template. Include the challenge number and the step that needs attention.
