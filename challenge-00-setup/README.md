# Challenge 00 — Setup & Foundations

> Stand up your tooling and the shared **base environment** that every later challenge builds on.

## 🎯 Objectives

By the end of this challenge you will be able to:

- Open the lab in **GitHub Codespaces** with the full hybrid-cloud toolchain pre-installed.
- Authenticate to **your own Azure subscription** and register the resource providers the lab needs.
- Deploy the shared **base environment** (resource group, Log Analytics workspace, virtual network, a *"server to migrate"* VM, and a managed identity) with **Terraform + Azure Verified Modules**.
- Confirm the **MCP servers** and **GitHub Copilot custom agents** are wired up, ready for the capstone.

## 🧩 Module B coverage

| Control | How this challenge contributes |
|---|---|
| **B.1.1 — Azure Local Implementation Capability** | Establishes the Azure-managed landing zone and the Arc-eligible server that stands in for an Azure Local cluster node. Everything you implement in 01–04 evidences B.1.1. |

## ⏱️ Duration & prerequisites

- **Duration:** ~45 minutes.
- **Prerequisites:**
  - A **GitHub account** with **Copilot** enabled.
  - An **Azure subscription** where you are **Owner** (you will register providers and assign RBAC).
  - See **[docs/prerequisites.md](../docs/prerequisites.md)** for the full pre-flight list.

> [!IMPORTANT]
> Everything runs in **Codespaces** — you do **not** need to install anything locally. If you prefer a local devcontainer, open the repo in VS Code with the Dev Containers extension.

## 🛠️ Tasks

### 1. Open the Codespace

1. From the repo's landing page, choose **[Open in GitHub Codespaces](https://codespaces.new/NikoMix/microhack-hybrid-claud-azure-hci?quickstart=1)** (or *Code → Codespaces → Create codespace*).
2. Wait for the devcontainer to finish building. The post-create step installs Azure CLI, Terraform + tflint, kubectl/helm, Flux, the GitHub Copilot CLI, and the quality toolchain.
3. Confirm the toolchain with the pre-flight script:

   ```bash
   ./challenge-00-setup/scripts/00-preflight.sh
   ```

### 2. Sign in to Azure

1. Authenticate with the device-code flow (works inside Codespaces):

   ```bash
   az login --use-device-code
   ```

2. Select your subscription and export it for Terraform:

   ```bash
   az account set --subscription "<YOUR_SUBSCRIPTION_ID>"
   export ARM_SUBSCRIPTION_ID="$(az account show --query id -o tsv)"
   ```

> [!TIP]
> Add the `export ARM_SUBSCRIPTION_ID=...` line to your `~/.bashrc` in the Codespace so it survives terminal restarts.

### 3. Register resource providers

The lab uses Arc, Guest Configuration, Kubernetes, Insights, and Recovery Services. Register them once (idempotent):

```bash
./challenge-00-setup/scripts/01-register-providers.sh
```

### 4. Deploy the base environment

The base environment lives in **[`infra/terraform/base`](../infra/terraform/base/)**. Deploy it with your **initials** (used throughout the lab for naming, e.g. `rg-mhb-<initials>`):

```bash
./challenge-00-setup/scripts/02-deploy-base.sh <your-initials>
```

This wraps `terraform init`, `plan`, and `apply`. Review the plan before approving. When it completes, note the outputs (resource group, VM public IP, SSH command).

> [!NOTE]
> The VM is a plain Ubuntu server that **stands in for an Azure Local cluster node**. In [challenge-01](../challenge-01-arc-foundations/) you will Azure **Arc-onboard** it and govern it exactly as you would a production Azure Local machine.

### 5. Verify the deployment

```bash
# List what landed in your resource group
az resource list --resource-group "rg-mhb-<your-initials>" -o table

# SSH into the server-to-migrate (uses the key Terraform generated)
terraform -chdir=infra/terraform/base output -raw ssh_command
```

Run the printed SSH command to confirm you can reach the VM, then `exit`.

### 6. Wire up Copilot agents, skills & MCP

1. Open **Copilot Chat** in the Codespace and switch to **Agent** mode.
2. Confirm the custom agents from [`.github/agents/`](../.github/agents/) appear (e.g. *Hybrid Cloud Architect*).
3. Confirm the **MCP servers** load: open the **[`.vscode/mcp.json`](../.vscode/mcp.json)** view or run `Copilot: MCP` and check that **azure** and **github** are listed and started.
4. Smoke-test the GitHub Copilot CLI:

   ```bash
   copilot --version
   ```

5. Ask the *Hybrid Cloud Architect* agent: *"Summarise the base environment in my resource group `rg-mhb-<initials>` and which Module B control it evidences."* — it should use the Azure MCP server to read your subscription.

## ✅ Success criteria

- [ ] Codespace built and `00-preflight.sh` reports all tools present.
- [ ] `az account show` returns **your** subscription and `ARM_SUBSCRIPTION_ID` is exported.
- [ ] Required resource providers show **Registered**.
- [ ] `terraform apply` for the base environment completed with no errors.
- [ ] `az resource list` shows the resource group, Log Analytics workspace, VNet/NSG, VM, and managed identity.
- [ ] You can SSH into the *server-to-migrate* VM.
- [ ] The **azure** and **github** MCP servers are started and the custom agents are selectable in Copilot Chat.

## 🧹 Cleanup

Do **not** tear down yet — every later challenge builds on this base environment. Full teardown happens at the end of the day via **[docs/teardown.md](../docs/teardown.md)**:

```bash
task destroy:base
```

## 📚 References

- [Azure Verified Modules](https://azure.github.io/Azure-Verified-Modules/)
- [Sign in with Azure CLI](https://learn.microsoft.com/cli/azure/authenticate-azure-cli)
- [Register an Azure resource provider](https://learn.microsoft.com/azure/azure-resource-manager/management/resource-providers-and-types)
- [GitHub Codespaces](https://docs.github.com/codespaces)
- [Use MCP servers in VS Code](https://code.visualstudio.com/docs/copilot/chat/mcp-servers)
- [Azure MCP Server](https://github.com/Azure/azure-mcp)
