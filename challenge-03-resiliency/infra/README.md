# Challenge 03 resiliency module (Terraform)

AVM-first Terraform that adds **resiliency and security** on top of the shared
base environment: an **Azure Backup** Recovery Services vault with a VM backup
policy, an optional protected-VM registration for the *server to migrate*, and
**Microsoft Defender for Servers Plan 2** enablement.

> [!NOTE]
> Built **Azure Verified Modules (AVM) first**. The vault, backup policy and
> protected item use [`Azure/avm-res-recoveryservices-vault`](https://registry.terraform.io/modules/Azure/avm-res-recoveryservices-vault/azurerm/latest).
> Defender for Servers is a subscription-scoped pricing setting with **no AVM
> module**, so it uses a justified raw `azurerm` resource.

## What gets created

| Resource | Implementation | Name |
| --- | --- | --- |
| Recovery Services vault | AVM `avm-res-recoveryservices-vault` `1.1.11` | `rsv-mhb-<initials>-03` |
| VM backup policy (daily, V2) | same AVM module | `bkpol-mhb-<initials>-03` |
| Protected VM (optional) | same AVM module (`protect_base_vm = true`) | the base `vm-mhb-<initials>` |
| Defender for Servers Plan 2 | raw `azurerm_security_center_subscription_pricing` | subscription-scoped |
| Vault diagnostics (optional) | same AVM module (`log_analytics_workspace_id`) | streamed to `log-mhb-<initials>` |

The vault is deployed **into the existing base resource group** (`rg-mhb-<initials>`).

## Prerequisites

- The shared base environment from [challenge-00-setup](../../challenge-00-setup/) is deployed.
- You are signed in (`az login`) and `ARM_SUBSCRIPTION_ID` is exported.
- `Microsoft.RecoveryServices` and `Microsoft.Security` providers are registered
  (the base [register-providers script](../../challenge-00-setup/scripts/01-register-providers.sh) does this).

## Configure

```bash
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars: set `initials` to match your base environment.
```

## Deploy

Use the helper script (recommended — wraps fmt/validate/plan/apply):

```bash
../scripts/01-deploy-resiliency.sh <your-initials>
```

Or run Terraform directly from this directory:

```bash
terraform init
terraform plan
terraform apply
```

## Protect the base VM

Backup protection of a running VM is opt-in so the vault can be created first:

```bash
../scripts/02-protect-base-vm.sh <your-initials>
# equivalent to: terraform apply -var protect_base_vm=true
```

## Outputs

| Output | Description |
| --- | --- |
| `recovery_services_vault_id` / `recovery_services_vault_name` | The Backup vault. |
| `vm_backup_policy_name` | Policy to attach protected VMs to. |
| `protected_vm_enabled` / `protected_vm_name` | Whether/which VM is registered for backup. |
| `defender_for_servers_plan2_enabled` | Whether Defender for Servers P2 was enabled. |
| `resource_group_name` | The base resource group the vault lives in. |

## Teardown

> [!WARNING]
> Backup soft-delete, protected items, and the Defender plan can incur ongoing
> cost. Removal order matters — stop protection (with `--delete-backup-data`)
> **before** deleting the vault, and revert Defender to `Free`.

Follow the day-end flow in [docs/teardown.md](../../docs/teardown.md), or for this
module:

```bash
# Revert Defender, stop protection, then destroy what Terraform owns.
terraform apply -var protect_base_vm=false -var enable_defender_for_servers=false
terraform destroy
```

## References

- [Azure/avm-res-recoveryservices-vault](https://registry.terraform.io/modules/Azure/avm-res-recoveryservices-vault/azurerm/latest)
- [Azure Backup overview](https://learn.microsoft.com/azure/backup/backup-overview)
- [Microsoft Defender for Servers](https://learn.microsoft.com/azure/defender-for-cloud/plan-defender-for-servers)
