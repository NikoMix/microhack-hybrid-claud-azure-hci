# Challenge 01 infra — guest-configuration policy assignment

This standalone Terraform root module assigns the built-in **guest-configuration**
policy *"Linux machines should meet requirements for the Azure compute security
baseline"* to the shared base resource group (`rg-mhb-<initials>`). It brings the
Arc-enabled *server-to-migrate* into scope and produces the **Module B B.1.1**
governance-evidence artifact for this challenge.

> [!NOTE]
> **AVM exception.** There is no Azure Verified Module (`Azure/avm-res-*` /
> `Azure/avm-ptn-*`) for a single resource-group-scoped policy assignment, so this
> module uses the raw `azurerm_resource_group_policy_assignment` resource — the same
> "raw only when no AVM fits" rule the base module applies to the workload VM.

## What it creates

| Resource | Implementation | Name |
| --- | --- | --- |
| Policy assignment (guest configuration, audit) | raw `azurerm_resource_group_policy_assignment` | `gc-baseline-mhb-<initials>-01` |
| System-assigned identity (for remediation) | part of the assignment | — |

The assignment defaults to **audit-only** (`enforce_policy = false`) so it never
gates the classroom, and passes `IncludeArcMachines = "true"` so Arc-enabled
servers are evaluated.

## Prerequisites

- The base environment from [Challenge 00](../../challenge-00-setup/) is deployed
  (the resource group `rg-mhb-<initials>` must already exist — this module reads it
  with a `data` source).
- `Microsoft.GuestConfiguration` and `Microsoft.PolicyInsights` providers are
  registered (Challenge 00 / [`scripts/00-register-providers.sh`](../scripts/00-register-providers.sh)).
- You are signed in: `az login` and `export ARM_SUBSCRIPTION_ID=$(az account show --query id -o tsv)`.

## Use

```bash
cd challenge-01-arc-foundations/infra
cp terraform.tfvars.example terraform.tfvars   # set your initials

terraform init
terraform plan
terraform apply
```

## Outputs

| Output | Description |
| --- | --- |
| `policy_assignment_id` | Resource ID of the policy assignment. |
| `policy_assignment_name` | Assignment name (`gc-baseline-mhb-<initials>-01`). |
| `policy_assignment_principal_id` | Managed-identity principal ID for remediation role assignments. |
| `resource_group_name` | The base resource group the policy is assigned to. |

## Validate (local quality gates)

```bash
terraform fmt -recursive .
terraform init -backend=false -input=false
terraform validate
tflint --config=../../.tflint.hcl
```

## Teardown

```bash
terraform destroy
```

See the challenge [README](../README.md#-cleanup) and
[trainer-notes](../trainer-notes.md#reset-between-cohorts) for the full
between-cohorts reset.
