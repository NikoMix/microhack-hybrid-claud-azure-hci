# Shared base environment (Terraform)

This is the **shared base** Terraform environment for the Azure Local Module B
microhack. Deploy it once at the start of the day — later challenges (Arc
onboarding, Azure Monitor, Backup, ASR, Defender, AKS-on-Arc) build on top of it.

It provisions a small, cost-guarded footprint, including the key workload
resource: a plain Ubuntu Linux VM that acts as the **"server to migrate"** and is
Azure Arc-onboarded in a later challenge.

> [!NOTE]
> Built **Azure Verified Modules (AVM) first**. The workload VM uses raw
> `azurerm` resources because the lab needs a plain, internet-reachable Ubuntu
> host (the AVM compute module adds surface area the lab does not need).

## What gets created

| Resource | Implementation | Name |
| --- | --- | --- |
| Resource group | AVM `avm-res-resources-resourcegroup` `0.4.0` | `rg-mhb-<initials>` |
| Log Analytics workspace | AVM `avm-res-operationalinsights-workspace` `0.5.1` | `log-mhb-<initials>` |
| User-assigned managed identity | AVM `avm-res-managedidentity-userassignedidentity` `0.5.0` | `uami-mhb-<initials>` |
| Network security group | AVM `avm-res-network-networksecuritygroup` `0.5.1` | `nsg-mhb-<initials>` |
| Virtual network + subnet | AVM `avm-res-network-virtualnetwork` `0.19.0` | `vnet-mhb-<initials>` / `snet-mhb-<initials>` |
| Public IP, NIC, Linux VM | raw `azurerm` | `vm-mhb-<initials>` (`Standard_B2s`, Ubuntu 22.04 LTS, SSH-key only) |

## Prerequisites

Run these from your GitHub Codespace:

```bash
# 1. Sign in to Azure.
az login

# 2. Select your subscription and export it for the AzureRM provider.
az account set --subscription "<your-subscription-name-or-id>"
export ARM_SUBSCRIPTION_ID=$(az account show --query id -o tsv)

# 3. Register the resource providers later challenges depend on (one-time per sub).
for ns in Microsoft.HybridCompute Microsoft.GuestConfiguration \
          Microsoft.AzureArcData Microsoft.Kubernetes \
          Microsoft.Insights Microsoft.RecoveryServices; do
  az provider register --namespace "$ns"
done
```

> [!TIP]
> Provider registration runs asynchronously. Check progress with
> `az provider show --namespace Microsoft.HybridCompute --query registrationState -o tsv`.

## Configure

```bash
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars: set `initials`, and ideally `allowed_ssh_source`.
```

> [!WARNING]
> `allowed_ssh_source` defaults to `0.0.0.0/0`, which opens SSH (port 22) to the
> entire internet. Set it to your own public IP/CIDR (find it with
> `curl -s https://api.ipify.org`), e.g. `allowed_ssh_source = "203.0.113.10/32"`.

## Deploy

```bash
terraform init
terraform plan
terraform apply
```

## Outputs

After `apply`, Terraform prints (and you can re-read with `terraform output`):

| Output | Description |
| --- | --- |
| `resource_group_name` | Shared base resource group name. |
| `log_analytics_workspace_id` / `log_analytics_workspace_name` | Workspace for later observability work. |
| `user_assigned_identity_id` / `user_assigned_identity_principal_id` | Managed identity for RBAC. |
| `vm_name` / `vm_public_ip` | The "server to migrate". |
| `ssh_command` | Ready-to-run SSH command. |
| `ssh_private_key` | Generated private key (sensitive; also written to `./id_rsa_mhb`, mode `0600`). |

Connect to the VM:

```bash
$(terraform output -raw ssh_command)
# e.g. ssh azureuser@<public-ip> -i ./id_rsa_mhb
```

> [!IMPORTANT]
> The private key file `./id_rsa_mhb` is generated locally and gitignored. Keep
> it safe and never commit it.

## Teardown

```bash
terraform destroy
```
