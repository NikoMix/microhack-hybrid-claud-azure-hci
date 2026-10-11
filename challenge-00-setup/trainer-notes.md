# Trainer notes — Challenge 00 · Setup & Foundations

## Timing

| Segment | Minutes | Notes |
|---|---|---|
| Codespace open + toolchain check | 10 | Pre-warm a Codespace before class; builds can take 3–5 min cold. |
| `az login` + subscription select | 5 | Device-code flow; watch for tenant pickers. |
| Register providers | 3 | Runs async in Azure; fine to proceed while it finishes. |
| `terraform apply` base | 15 | The VM is the long pole (~3–5 min). Narrate while it runs. |
| Verify + SSH | 5 | Quick win — everyone reaches a server. |
| Copilot agents + MCP check | 7 | Sets up the capstone; resolve MCP issues now, not at 16:00. |

**Total:** ~45 min. This is the single most important checkpoint of the day — **do not advance until every pupil has a green base deployment.**

## Talk track

> "Azure Local needs validated physical hardware, so we can't rack a cluster in a classroom. But here's the thing — the *operational model* is identical. Whether a machine is an Azure Local node or this plain VM, once it's **Arc-enabled** you govern it with the exact same Azure services. So today we build the Azure control plane and the migration muscle. The VM you're about to deploy is your 'server to migrate' — by lunch it'll be Arc-governed; by mid-afternoon it'll be monitored, patched, backed up, and defended."

Tie it back: **B.1.1** is about demonstrating *Azure Local implementation capability*. The landing zone you stand up here is the substrate for that evidence.

## Live demo script

1. Open a fresh Codespace on the projector so latecomers can follow the build.
2. Run `00-preflight.sh` and read the output line by line — explain each tool's role (Terraform = IaC, azcmagent later = Arc, kubectl/flux = challenge 04, copilot = capstone).
3. Do the `az login --use-device-code` live; show the tenant/subscription selection.
4. Run `02-deploy-base.sh <initials>` and **show the plan** — call out the AVM modules (`Azure/avm-res-*`) and that everything is pinned.
5. While apply runs, open `infra/terraform/base/main.tf` and narrate the resources.
6. After apply, SSH in live, run `hostname` and `cat /etc/os-release`, then `exit`.
7. Switch to Copilot Agent mode, pick *Hybrid Cloud Architect*, and ask it to summarise the resource group — show the Azure MCP server being invoked.

## Common pitfalls

- **Wrong subscription / multiple tenants.** If `az account show` is empty after login, the pupil picked the wrong tenant. Re-run `az login --use-device-code` and select carefully.
- **`ARM_SUBSCRIPTION_ID` not set.** azurerm 4.x needs it. Symptom: `subscription_id is a required provider property`. Fix: `export ARM_SUBSCRIPTION_ID=$(az account show --query id -o tsv)`.
- **Provider not registered.** Terraform apply fails with `MissingSubscriptionRegistration`. Re-run `01-register-providers.sh`; registration can lag a minute.
- **Region capacity / quota.** `Standard_B2s` is broadly available, but if `swedencentral` is constrained, override with `-var location=<region>` (pass it through the script's `TF_VAR_location`).
- **Codespace prebuild stale.** If tools are missing, run `bash .devcontainer/post-create.sh` manually.
- **MCP not appearing.** Ensure the pupil opened the workspace root (so `.vscode/mcp.json` is picked up) and trust the workspace. Node must be present (it is, via the devcontainer).

## Checkpoint questions & answers

1. **Q:** Why do we Arc-enable a normal VM instead of deploying a real Azure Local cluster?
   **A:** Azure Local requires validated physical hardware; the *Azure management plane* (Arc, Monitor, Backup, Defender, Update Manager) is identical for an Arc-enabled server, so we learn the operating model that Module B B.1.1 evidences without the hardware.
2. **Q:** Why Azure Verified Modules instead of raw `azurerm` resources?
   **A:** AVM modules are Microsoft-maintained, security-hardened, versioned building blocks — they reduce drift, pass policy/security scans, and are the recommended pattern partners should demonstrate.

## Reset between cohorts

- Run `task destroy:base` (or `terraform -chdir=infra/terraform/base destroy`).
- Delete any leftover resource group: `az group delete -n rg-mhb-<initials> --yes --no-wait`.
- Delete the Codespace (Settings → Codespaces) to avoid idle billing.
- Confirm no Recovery Services vault / Defender plan lingers (see [docs/teardown.md](../docs/teardown.md)).
