# Teardown

Run teardown before pupils leave. The goal is no lingering lab cost in the
subscription.

> [!WARNING]
> Do not assume Terraform owns every resource. Arc-connected machines, connected
> Kubernetes resources, backup protected items, soft-delete vault data, Azure Site
> Recovery artifacts, and Defender plans often need manual cleanup.

## Set variables

```bash
export INITIALS="<initials>"
export LOCATION="swedencentral"
export RG="rg-mhb-${INITIALS}"
export SUBSCRIPTION_ID="$(az account show --query id -o tsv)"
export ARM_SUBSCRIPTION_ID="$SUBSCRIPTION_ID"
```

Confirm context:

```bash
az account show --query '{name:name,id:id,tenant:tenantId}' -o table
az resource list --resource-group "$RG" -o table
```

## Step 1 — Run the standard destroy task

From the repository root:

```bash
task destroy:base
```

If you are already in Terraform and need the direct command:

```bash
terraform -chdir=infra/terraform/base destroy -auto-approve
```

If Terraform state is unavailable, continue with the manual cleanup and resource
group deletion below.

## Step 2 — Remove Arc-enabled server resources

On the VM, disconnect locally if it is still reachable:

```bash
sudo azcmagent disconnect --force-local-only || true
```

From Codespaces, delete any remaining Azure Arc-enabled server resources:

```bash
az connectedmachine list --resource-group "$RG" -o table

for name in $(az connectedmachine list --resource-group "$RG" --query '[].name' -o tsv); do
  az connectedmachine delete \
    --name "$name" \
    --resource-group "$RG" \
    --yes
done
```

## Step 3 — Remove Arc-enabled Kubernetes and Flux

List connected clusters:

```bash
az connectedk8s list --resource-group "$RG" -o table
```

Delete Flux configurations first when present:

```bash
for cluster in $(az connectedk8s list --resource-group "$RG" --query '[].name' -o tsv); do
  for flux in $(az k8s-configuration flux list \
    --resource-group "$RG" \
    --cluster-name "$cluster" \
    --cluster-type connectedClusters \
    --query '[].name' -o tsv 2>/dev/null); do
    az k8s-configuration flux delete \
      --resource-group "$RG" \
      --cluster-name "$cluster" \
      --cluster-type connectedClusters \
      --name "$flux" \
      --yes
  done

  az connectedk8s delete \
    --name "$cluster" \
    --resource-group "$RG" \
    --yes
done
```

## Step 4 — Stop backup protection and remove vaults

List Recovery Services vaults:

```bash
az backup vault list --resource-group "$RG" -o table
```

For each vault, disable protection and delete backup data for lab VMs:

```bash
for vault in $(az backup vault list --resource-group "$RG" --query '[].name' -o tsv); do
  for item in $(az backup item list \
    --resource-group "$RG" \
    --vault-name "$vault" \
    --backup-management-type AzureIaasVM \
    --workload-type VM \
    --query '[].name' -o tsv 2>/dev/null); do
    container=$(az backup item show \
      --resource-group "$RG" \
      --vault-name "$vault" \
      --name "$item" \
      --backup-management-type AzureIaasVM \
      --workload-type VM \
      --query containerName -o tsv)

    az backup protection disable \
      --resource-group "$RG" \
      --vault-name "$vault" \
      --container-name "$container" \
      --item-name "$item" \
      --backup-management-type AzureIaasVM \
      --workload-type VM \
      --delete-backup-data true \
      --yes
  done
done
```

If a vault still refuses deletion because of soft-delete, use the Azure portal to
disable soft-delete for the lab vault, undelete any soft-deleted lab items, then
stop protection and delete data. Follow current Microsoft Learn guidance for
Azure Backup soft-delete:
<https://learn.microsoft.com/azure/backup/backup-azure-security-feature-cloud>.

Delete vault resources after protected items are removed:

```bash
for vault in $(az backup vault list --resource-group "$RG" --query '[].name' -o tsv); do
  az backup vault delete --resource-group "$RG" --name "$vault" --yes
done
```

## Step 5 — Remove Azure Site Recovery artifacts

Azure Site Recovery cleanup depends on which replication objects the challenge
created. Start by listing vaults and fabrics:

```bash
for vault in $(az backup vault list --resource-group "$RG" --query '[].name' -o tsv); do
  echo "Vault: $vault"
  az site-recovery fabric list --resource-group "$RG" --vault-name "$vault" -o table || true
done
```

If replicated items exist, disable replication from the Azure portal or with the
specific `az site-recovery` command matching the item type. Then delete
protection containers, fabrics, policies, and the vault. Use Microsoft Learn for
current ASR cleanup flow:
<https://learn.microsoft.com/azure/site-recovery/site-recovery-manage-registration-and-protection>.

## Step 6 — Downgrade or disable Defender for Servers plan

If the lab enabled Microsoft Defender for Cloud / Defender for Servers Plan 2
only for training, revert it before leaving.

Check current plan:

```bash
az security pricing show --name VirtualMachines -o json
```

Disable or return to the organization's approved plan only if this is a training
subscription and policy allows it:

```bash
az security pricing create --name VirtualMachines --tier Free
```

> [!IMPORTANT]
> In a corporate subscription, do not downgrade Defender plans without owner
> approval. For training subscriptions, make the intended post-lab state explicit
> before class.

## Step 7 — Delete the resource group as a backstop

After service-specific cleanup:

```bash
az group delete --name "$RG" --yes --no-wait
```

Poll until it is gone:

```bash
az group exists --name "$RG"
```

The command returns `false` when the group is deleted.

## Step 8 — Verification checklist

Run these checks:

```bash
az resource list --resource-group "$RG" -o table || true
az group exists --name "$RG"
az connectedmachine list --query "[?contains(name, 'mhb-${INITIALS}')].{Name:name,Group:resourceGroup}" -o table
az connectedk8s list --query "[?contains(name, 'mhb-${INITIALS}')].{Name:name,Group:resourceGroup}" -o table
az backup vault list --query "[?contains(name, 'mhb-${INITIALS}')].{Name:name,Group:resourceGroup}" -o table
az resource list --tag "workload=microhack-hybrid-b" -o table || true
```

Clean state means:

- `az group exists --name "$RG"` returns `false`, or deletion is visibly in progress.
- No Arc-enabled server remains for the pupil initials.
- No connected Kubernetes resource remains for the pupil initials.
- No Recovery Services or backup vault remains for the pupil initials.
- No public IP, disk, or VM remains in the lab resource group.
- Defender plan is back to the intended post-lab state.

## If deletion is blocked

Document the blocker before pupils leave:

| Field | Value |
| --- | --- |
| Pupil initials | `<initials>` |
| Subscription | `<subscription-id>` |
| Resource group | `rg-mhb-<initials>` |
| Blocking resource | `<resource-id>` |
| Error message | `<short error>` |
| Owner | `<trainer or subscription owner>` |
| Follow-up deadline | `<date/time>` |

Most blockers are protected backup items, ASR replication, policy locks, or
soft-deleted vault data.
