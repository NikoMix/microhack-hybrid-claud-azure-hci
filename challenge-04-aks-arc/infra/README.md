# Challenge 04 — supporting infrastructure (`infra/`)

Terraform for the **cloud-side** governance and observability resources that back
the Arc-enabled Kubernetes cluster you stand up in this challenge:

| Resource | Module / type | Purpose |
| --- | --- | --- |
| Container Insights DCR | `Azure/avm-res-insights-datacollectionrule/azurerm` (AVM) | Routes the `Microsoft-ContainerInsights-Group-Default` stream to the shared Log Analytics workspace. |
| Pod security baseline assignment | `azurerm_resource_group_policy_assignment` | Assigns the built-in *pod security baseline standards for Linux-based workloads* initiative to the base resource group. |

> [!NOTE]
> The cluster-to-Arc connection itself is **CLI-driven** (see [`../scripts/`](../scripts/)).
> This module only provisions the cloud resources those CLI extensions point at,
> so it stays small, declarative, and cheap.

## Prerequisites

- The shared base environment from [`infra/terraform/base`](../../infra/terraform/base)
  is already deployed (this module reads its resource group and Log Analytics
  workspace via data sources).
- Terraform `>= 1.9`, `azurerm ~> 4.x`.
- `az login` to the target subscription (or set `subscription_id`).

## Usage

```bash
cp terraform.tfvars.example terraform.tfvars   # set your initials
terraform init
terraform plan
terraform apply
```

## Inputs

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `initials` | `string` | — | Lowercase pupil initials (`2–5` chars) — must match the base environment. |
| `location` | `string` | `swedencentral` | Azure region for the DCR. |
| `policy_effect` | `string` | `audit` | Initiative effect: `audit`, `deny`, or `disabled`. |
| `policy_enforce` | `bool` | `true` | Whether the assignment enforces (vs. *Do Not Enforce*). |
| `policy_excluded_namespaces` | `list(string)` | system + `flux-system` | Namespaces exempt from evaluation. |
| `subscription_id` | `string` | `null` | Target subscription (falls back to `ARM_SUBSCRIPTION_ID` / CLI). |
| `tags` | `map(string)` | lab tags | Tags applied to created resources. |

## Outputs

| Name | Description |
| --- | --- |
| `container_insights_dcr_id` | DCR resource ID — associate it with the Arc cluster. |
| `container_insights_dcr_name` | DCR name. |
| `policy_assignment_id` | Pod security baseline assignment ID. |
| `policy_assignment_name` | Assignment name. |
| `log_analytics_workspace_id` | Shared workspace ID (pass to `az k8s-extension`). |

> [!TIP]
> `policy_effect = "audit"` keeps the lab non-blocking. Switch to `deny` only to
> demonstrate admission rejection, then revert so later challenges aren't impacted.

## Validation

```bash
terraform fmt -recursive .
terraform -chdir=. init -backend=false -input=false
terraform -chdir=. validate
tflint --chdir=. --config=../../.tflint.hcl
```
