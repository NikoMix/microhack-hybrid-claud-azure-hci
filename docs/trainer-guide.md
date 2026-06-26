# Trainer guide

This guide is the master operating manual for delivering the one-day
Train-the-Trainer microhack. Use it with the [agenda](agenda.md),
[facilitation playbook](facilitation.md), [talk tracks](talk-tracks.md),
[grading checkpoints](grading-checkpoints.md), [troubleshooting guide](troubleshooting.md),
and [teardown guide](teardown.md).

> [!IMPORTANT]
> Work from the root [README](../README.md) as the source of truth for the
> Module B-to-challenge matrix and headline agenda. This guide adds delivery
> detail; it does not replace the README.

## Delivery model

- **Format:** one-day, classroom-led, hands-on microhack for Microsoft partner trainers.
- **Audience:** trainers and consultants with intermediate Azure skills, roughly AZ-104 level.
- **Platform:** GitHub Codespaces plus each pupil's own Azure subscription.
- **Permissions:** pupils need Owner on their subscription so they can register providers, assign RBAC, and enable security/resiliency services.
- **Default naming:** resource group `rg-mhb-<initials>`, resources `*-mhb-<initials>-<challenge>`, region `swedencentral` unless capacity requires a trainer-approved alternate.
- **Guardrail:** small or consumption SKUs only; all resources are removed the same day.

## Pre-day preparation

### T-1 week checklist

- Confirm the training objective: Module B capability evidence, not a complete Azure Local hardware deployment.
- Send pupils [prerequisites](prerequisites.md), [cost estimate](cost-estimate.md), and the repo link.
- Confirm every pupil has:
  - GitHub account with GitHub Copilot enabled.
  - Azure subscription with Owner.
  - Permission to create public IPs, VMs, managed identities, Log Analytics, Recovery Services, and Arc resources.
  - Browser access to GitHub Codespaces and the Azure portal.
- Ask pupils to check subscription policy restrictions that may block `swedencentral`, Standard_B2s VMs, public IPs, or provider registration.
- Ask pupils to verify current Advanced Specialization requirements from the official Microsoft-issued PDF. Do not teach numeric thresholds from memory.
- Dry-run at least Challenge 00, Arc onboarding, teardown, and the Copilot capstone in a clean subscription.

### T-1 day checklist

- Open a fresh Codespace and confirm the devcontainer completes.
- Run:

  ```bash
  task setup
  task lint:md
  task validate
  task security
  task links
  ```

- Confirm the key CLIs are present: `az`, `terraform`, `task`, `kubectl`, `helm`, `flux`, `gh`, `markdownlint-cli2`, `checkov`, and `gitleaks`.
- Confirm [`.vscode/mcp.json`](../.vscode/mcp.json) exists if the capstone depends on Azure and GitHub MCP servers.
- Prepare a trainer demo subscription with a full successful run or screenshots in case a room-wide service issue appears.
- Prepare links to Microsoft Learn pages used during the day:
  - Azure Arc-enabled servers: <https://learn.microsoft.com/azure/azure-arc/servers/overview>
  - Azure Monitor: <https://learn.microsoft.com/azure/azure-monitor/overview>
  - Azure Update Manager: <https://learn.microsoft.com/azure/update-manager/overview>
  - Azure Backup: <https://learn.microsoft.com/azure/backup/backup-overview>
  - Azure Site Recovery: <https://learn.microsoft.com/azure/site-recovery/site-recovery-overview>
  - Microsoft Defender for Cloud: <https://learn.microsoft.com/azure/defender-for-cloud/defender-for-cloud-introduction>
  - AKS enabled by Azure Arc: <https://learn.microsoft.com/azure/aks/hybrid/aks-overview>
  - Azure Arc-enabled Kubernetes GitOps with Flux: <https://learn.microsoft.com/azure/azure-arc/kubernetes/conceptual-gitops-flux2>

### Morning-of checklist

- Arrive early. Test projector, audio, Wi-Fi, and any virtual meeting bridge.
- Open the root [README](../README.md), [agenda](agenda.md), [architecture](architecture/README.md), and Azure portal.
- Start a timer visible only to the trainer team.
- Reconfirm your demo subscription default:

  ```bash
  az account show --query '{name:name,id:id,tenant:tenantId}' -o table
  ```

- Confirm the repo still builds in Codespaces if possible.
- Place the teardown reminder on the board: `task destroy:base` plus manual cleanup for Arc, backup, ASR, Defender, and connected Kubernetes.

## Room and virtual setup

### In-person

- Use tables of two or three. Pair strong Azure operators with trainers who are new to hybrid.
- Keep one screen on the challenge instructions and one screen on Azure portal or terminal.
- Create a visible help queue. Do not let one broken subscription consume the whole room.
- Put naming conventions on a slide or whiteboard.

### Virtual

- Use a main room for demos and a support breakout for troubleshooting.
- Ask pupils to keep cameras optional but chat active.
- Use short status polls at each checkpoint: green, yellow, red.
- Have pupils paste only non-sensitive command output. Never ask for secrets, tokens, or full subscription inventories.

## How Codespaces plus own subscription works

Codespaces is the workstation. The Azure subscription is the lab target.

- The devcontainer installs Azure CLI, Terraform and tflint, kubectl and Helm, Flux, GitHub CLI, Node, Python, markdownlint, checkov, pre-commit, gitleaks, lychee, and the GitHub Copilot CLI.
- `ARM_USE_CLI=true` lets Terraform use the Azure CLI login.
- Pupils authenticate interactively with:

  ```bash
  az login --use-device-code
  az account set --subscription "<subscription-id>"
  export ARM_SUBSCRIPTION_ID="<subscription-id>"
  ```

- The lab uses Terraform and Azure Verified Modules where available for the base environment.
- Pupils should not store secrets in files. Use Azure login, managed identities, and short-lived device-code flows.

## Pacing strategy

- Use the [agenda](agenda.md) as a timebox, not a checklist of every possible Azure feature.
- Demo the first three minutes of a new service, then let pupils operate.
- Stop the room at each checkpoint even if a few pupils are still finishing.
- Convert unresolved individual issues into table pairing, trainer demo mode, or post-lab follow-up.
- Keep B.1.1 concrete: pupils must show they can onboard and manage hybrid assets, not merely discuss them.
- Keep B.2-B.4 evidence-oriented: pupils should understand what evidence partners need and where exact requirements are verified.

## Running checkpoints

Use [grading checkpoints](grading-checkpoints.md) at the end of each challenge.

1. Ask for the visible artifact: Azure resource, CLI output, KQL result, GitOps status, or evidence map.
1. Ask one control-mapping question.
1. Ask one operational question.
1. Mark the pupil green, yellow, or red.
1. For yellow/red pupils, choose one of three paths: quick fix, paired recovery, or trainer demo mode.

Recommended checkpoint command pattern:

```bash
az resource list --resource-group "rg-mhb-<initials>" -o table
az connectedmachine list --resource-group "rg-mhb-<initials>" -o table
```

## Handling the AI capstone

Challenge 06 is not a standalone coded inference app. It is the repo's GitHub
Copilot custom agents, skills, and MCP servers applied to the hybrid evidence
package.

Trainer approach:

- Start with a two-minute demo of an agent validating evidence and opening a GitHub Issue for a gap.
- Give pupils prompt patterns, not scripts to memorize:
  - "Map my lab evidence to Module B controls and flag gaps."
  - "Generate a customer onboarding runbook from the Arc and Monitor artifacts."
  - "Review my Terraform for cost and teardown risks."
  - "Create concise audit questions for B.4.1 evidence readiness."
- Require human review before accepting generated runbooks or issue text.
- Remind pupils not to paste secrets, customer data, or proprietary audit material into prompts.
- If MCP servers are not visible, continue with built-in Copilot Chat and the repository files; the learning outcome is human-governed evidence acceleration.

## Post-day wrap

### Feedback

Collect feedback before teardown fatigue sets in:

- Which challenge best explained Azure Local through the Azure control plane?
- Which checkpoint made Module B evidence clearer?
- Where did timing feel too tight?
- Which agent or skill would pupils reuse with customers?

### Teardown verification

Run the [teardown guide](teardown.md) live. Do not close the day until pupils can
show one of:

- Empty lab resource group.
- Resource group deletion in progress.
- Documented exception with owner and deadline.

### Train-the-Trainer: make this your own

- Keep the Module B matrix and agenda aligned with the root [README](../README.md).
- Adapt the Contoso story to your customer segment, but preserve the journey: ageing estate, Arc governance, Azure Local target state, evidence package, AI-assisted review.
- Add local examples only when they do not alter the control mapping.
- Replace screenshots with your own tenant only after removing subscription IDs, user names, and customer identifiers.
- Use [challenge template](challenge-template.md) when authoring or refreshing Challenges 01-05.
- Re-run `task lint:md`, `task validate`, `task security`, and `task links` before delivering a modified version.
