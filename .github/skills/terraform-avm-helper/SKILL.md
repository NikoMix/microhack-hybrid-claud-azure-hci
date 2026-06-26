---
name: terraform-avm-helper
description: >-
  Author, refine, and validate Terraform that uses Azure Verified Modules (AVM) to the
  repo's quality bar. Use when a learner asks to write or fix Terraform, pick or pin an
  AVM module, resolve fmt/validate/tflint/checkov findings, or follow AVM-first IaC
  conventions for the Azure Local microhack.
---

# Terraform AVM Helper

Help learners write and fix **Azure Verified Modules**–based Terraform that passes the
repo's quality gates. Mirrors the conventions in `.github/copilot-instructions.md`.

## When to use

- "Write Terraform for X using AVM", "which AVM module should I use?", "pin the right
  version", "fix these tflint/checkov/validate errors", "is this AVM-first?".

## Standards to enforce

- Terraform `>= 1.9`; provider `azurerm ~> 4.x` (latest).
- **AVM-first**: prefer `Azure/avm-res-*` (resource) and `Azure/avm-ptn-*` (pattern)
  modules. Pin an explicit `version`. Only drop to raw `azurerm_*` resources when no AVM
  module fits — and justify it in a comment.
- Variables typed + `description`'d; outputs documented; a shared `tags` map; no hardcoded
  secrets or names (parameterize with `var.initials`, `var.location`).
- Must pass `terraform fmt -recursive`, `terraform validate`, `tflint` (repo `.tflint.hcl`),
  and `checkov`.

## Procedure

1. Clarify the resource(s) to create and the naming/region inputs.
2. **Resolve the module + version from the Terraform Registry before writing** — never
   guess a version or an input name. Confirm the module's required inputs and the current
   latest version.
   - Quick check (read-only): `curl -s https://registry.terraform.io/v1/modules/Azure/<module>/azurerm/versions`.
3. Write the HCL using the verified module call, typed variables, outputs, and tags.
4. Validate locally: `terraform fmt -recursive`, `terraform init -backend=false`,
   `terraform validate`, then `tflint`. Iterate until clean.
5. Run `checkov` and address findings; if a finding is a justified lab exception, add an
   inline `# checkov:skip=<id>:<reason>` rather than silently ignoring it.
6. Summarize the module/version chosen and any input decisions.

## Common AVM modules for this lab

`Azure/avm-res-resources-resourcegroup`, `Azure/avm-res-operationalinsights-workspace`,
`Azure/avm-res-network-virtualnetwork`, `Azure/avm-res-network-networksecuritygroup`,
`Azure/avm-res-managedidentity-userassignedidentity`,
`Azure/avm-res-compute-virtualmachine`. **Always re-check the latest version** before use.

## Output

Valid, formatted HCL plus a short note of the modules/versions used and the validation
status (fmt/validate/tflint/checkov). Never present unvalidated module input names.
