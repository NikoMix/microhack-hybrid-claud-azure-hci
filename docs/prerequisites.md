# Prerequisites

Use this checklist before day 1. The lab is designed for GitHub Codespaces plus
each pupil's own Azure subscription.

## Accounts and access

| Requirement | Why it is needed | Self-check |
| --- | --- | --- |
| GitHub account | Access the repository and Codespaces | You can open the repo in GitHub. |
| GitHub Copilot enabled | Challenge 06 uses Copilot custom agents, skills, and MCP | Copilot Chat opens in Codespaces. |
| Azure subscription | Lab resources are deployed into each pupil's subscription | `az account show` returns the intended subscription. |
| Owner role on subscription | Provider registration, RBAC assignments, Defender, Arc, and recovery services may need broad permissions | Azure portal shows Owner at subscription scope. |
| Browser | Codespaces, Azure portal, and GitHub are browser-first | Current Edge, Chrome, Firefox, or Safari works. |

> [!WARNING]
> Contributor is often not enough. If a tenant blocks provider registration, role
> assignments, public IPs, or Defender plans, the pupil may need a different
> subscription or trainer demo mode.

## Azure subscription requirements

The default region is `swedencentral`. If capacity or policy blocks the region,
trainers may approve another Azure region.

Expected resource families:

- Resource group `rg-mhb-<initials>`.
- Log Analytics workspace.
- Virtual network and network security group.
- Standard_B2s Linux VM, public IP, NIC, and managed disk.
- User-assigned managed identity.
- Azure Arc-enabled server resource.
- Recovery Services or backup vault resources.
- Azure Site Recovery components where used.
- Microsoft Defender for Cloud / Defender for Servers Plan 2, preferably trial or short lab window.
- Arc-enabled Kubernetes / connected cluster resources and Flux configuration.

## Resource providers

Provider registration can take several minutes. Register only what the current
subscription policy allows.

```bash
providers=(
  Microsoft.Compute
  Microsoft.Network
  Microsoft.ManagedIdentity
  Microsoft.OperationalInsights
  Microsoft.Insights
  Microsoft.HybridCompute
  Microsoft.GuestConfiguration
  Microsoft.Kubernetes
  Microsoft.KubernetesConfiguration
  Microsoft.ContainerService
  Microsoft.RecoveryServices
  Microsoft.DataProtection
  Microsoft.Security
)

for provider in "${providers[@]}"; do
  az provider register --namespace "$provider"
done

az provider list \
  --query "[?namespace=='Microsoft.HybridCompute' || namespace=='Microsoft.KubernetesConfiguration' || namespace=='Microsoft.RecoveryServices' || namespace=='Microsoft.Security'].{Namespace:namespace,State:registrationState}" \
  -o table
```

## Codespaces flow

1. Open the repository in GitHub.
1. Select **Code** > **Codespaces** > **Create codespace**.
1. Wait for the devcontainer post-create script to finish.
1. Open a terminal.
1. Sign in to Azure:

   ```bash
   az login --use-device-code
   az account set --subscription "<subscription-id>"
   export ARM_SUBSCRIPTION_ID="<subscription-id>"
   ```

1. Run the setup smoke test:

   ```bash
   task setup
   az account show --query '{name:name,id:id,tenant:tenantId}' -o table
   terraform version
   kubectl version --client=true
   flux --version
   gh --version
   ```

## Devcontainer toolchain reference

The Codespace is built from Ubuntu 24.04 and installs the tools used across the
labs:

- Azure CLI.
- Terraform with tflint and terraform-docs.
- kubectl and Helm.
- GitHub CLI.
- Node.js LTS.
- Python 3.12.
- ShellCheck, jq, unzip.
- go-task (`task`).
- Flux CLI.
- gitleaks.
- actionlint.
- lychee.
- checkov and pre-commit.
- markdownlint-cli2.
- GitHub Copilot CLI.
- VS Code extensions for Copilot, Terraform, Azure resources, Kubernetes, YAML, markdownlint, ShellCheck, GitHub Actions, and Prettier.

The devcontainer also sets:

```bash
ARM_USE_CLI=true
```

This lets Terraform authenticate with the current Azure CLI session.

## Pupil self-check

Run this before the instructor starts Challenge 00:

```bash
az account show --query '{subscription:name,id:id,user:user.name}' -o table
echo "ARM_SUBSCRIPTION_ID=$ARM_SUBSCRIPTION_ID"
task --list
az provider show --namespace Microsoft.HybridCompute --query registrationState -o tsv
```

You are ready when:

- Codespaces is open and the post-create script completed or was rerun successfully.
- Azure CLI is signed in to the intended subscription.
- `ARM_SUBSCRIPTION_ID` matches the intended subscription.
- You know your initials for resource naming.
- You understand that all lab resources must be removed at the end of the day.

## Trainer pre-flight checklist

- Verify the repo opens in a clean Codespace.
- Run `task setup`, `task lint:md`, `task validate`, `task security`, and `task links`.
- Confirm at least one demo subscription can deploy the base environment with `task deploy:base`.
- Confirm teardown works with `task destroy:base` plus manual cleanup in [teardown](teardown.md).
- Prepare a fallback region if `swedencentral` capacity is constrained.
- Prepare a fallback demo for Defender for Cloud or Azure Site Recovery if tenant policy blocks pupil subscriptions.
- Confirm Copilot custom agents and MCP configuration are visible enough for Challenge 06.
- Remind pupils to use the Azure Pricing Calculator for current prices: <https://azure.microsoft.com/pricing/calculator/>.
