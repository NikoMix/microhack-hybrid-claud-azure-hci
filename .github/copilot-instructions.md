# Copilot instructions — Azure Local Module B MicroHack

This repository is a **Train-the-Trainer microhack**. When generating or editing content here, follow these conventions so every challenge stays consistent and instructor-ready.

## Voice & audience

- Audience is **Microsoft partner consultants / trainers** with intermediate Azure skills (≈ AZ-104).
- Be precise, hands-on, and time-boxed. Prefer numbered, runnable steps over prose.
- Always tie technical work back to the **Module B control** it evidences (B.1.1–B.4.2).

## Challenge folder shape (every `challenge-0X-*`)

```text
README.md         student-facing lab
trainer-notes.md  Train-the-Trainer guidance
infra/            Terraform for this challenge (if any)
scripts/          idempotent helper scripts
assets/           diagrams, sample evidence
```

### Student `README.md` required headings (in order)

`# Challenge 0X — Title` → `## 🎯 Objectives` → `## 🧩 Module B coverage` → `## ⏱️ Duration & prerequisites` → `## 🛠️ Tasks` → `## ✅ Success criteria` → `## 🧹 Cleanup` → `## 📚 References`

### `trainer-notes.md` required headings

`## Timing` · `## Talk track` · `## Live demo script` · `## Common pitfalls` · `## Checkpoint questions & answers` · `## Reset between cohorts`

## Markdown

- GitHub-flavored. One `#` H1 per file. Use GitHub admonitions: `> [!NOTE]`, `> [!TIP]`, `> [!WARNING]`, `> [!IMPORTANT]`.
- Relative links only. Must pass `markdownlint-cli2` (`.markdownlint.jsonc`).

## Terraform

- Terraform `>= 1.9`; provider `azurerm ~> 4.x` (latest).
- **Azure Verified Modules first** (`Azure/avm-*`), with pinned `version`. Only write raw resources when no AVM module fits.
- Typed + `description`'d variables; documented `output`s; no hardcoded secrets; tags via a shared `tags` map.
- Must pass `terraform fmt`, `terraform validate`, `tflint`, and `checkov`.

## Shell

- `#!/usr/bin/env bash` + `set -euo pipefail`. Idempotent, parameterized (no hardcoded resource names). Must pass `shellcheck`.

## Naming & defaults

- Resource group: `rg-mhb-<initials>`; resources `*-mhb-<initials>-<challenge>`.
- Default region `swedencentral` (overridable). Small/consumption SKUs only — this is a cost-guarded lab.

## Security

- Never commit secrets. Use `az login` / managed identity. Least-privilege RBAC. Must pass `gitleaks`.

## AI capstone (challenge-06)

- The AI layer is **GitHub Copilot custom agents** (`.github/agents/*.agent.md`) + **skills** (`.github/skills/`) + **MCP servers** (`.vscode/mcp.json`: Azure MCP + GitHub MCP). Do **not** introduce a standalone coded inference app.

## Single sources of truth

- The Module B → challenge matrix and the agenda live in the **root `README.md`**. Update them there only.
- Cross-session task distribution is tracked in **GitHub Issues**.
