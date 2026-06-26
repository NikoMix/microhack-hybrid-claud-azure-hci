# Runbook — Azure Arc onboarding for the server-to-migrate

> [!NOTE]
> **Illustrative training sample** that fully fills the
> [runbook template](../templates/runbook-template.md) for a fictitious partner,
> *Northwind Cloud*. Commands are lab-accurate and parameterized. It is primary evidence for
> **Module B control B.4.2** and strengthens **B.1.1**.

## Purpose & scope

- **What this automates:** connecting the *server-to-migrate* to **Azure Arc** so it is
  governed by the Azure control plane.
- **In scope:** a single Linux/Windows server reachable over SSH/WinRM.
- **Out of scope:** Arc-enabled Kubernetes (see [Challenge 04](../../challenge-04-aks-arc/)).
- **Module B control evidenced:** B.4.2 (reusable onboarding asset) and B.1.1.

## Prerequisites

- **Access / RBAC:** *Azure Connected Machine Onboarding* (or Contributor) on `rg-mhb-<initials>`.
- **Registered providers:** `Microsoft.HybridCompute`, `Microsoft.GuestConfiguration`,
  `Microsoft.HybridConnectivity`.
- **Tools:** Azure CLI on the operator workstation; `azcmagent` on the target server.
- **Inputs:** `INITIALS`, `LOCATION`, `RG`, `SUBSCRIPTION_ID`, `TENANT_ID`.

## Roles & RACI

| Activity | Responsible | Accountable | Consulted | Informed |
| --- | --- | --- | --- | --- |
| Run onboarding | Hybrid engineer | Delivery lead | Customer admin | Security |
| Approve RBAC | Delivery lead | Customer sponsor | Security | Hybrid engineer |

## Procedure

1. Set parameters on the operator workstation:

   ```bash
   set -euo pipefail
   export INITIALS="<initials>"
   export LOCATION="swedencentral"
   export RG="rg-mhb-${INITIALS}"
   export SUBSCRIPTION_ID="$(az account show --query id -o tsv)"
   export TENANT_ID="$(az account show --query tenantId -o tsv)"
   ```

1. Register the required providers (idempotent):

   ```bash
   for ns in Microsoft.HybridCompute Microsoft.GuestConfiguration Microsoft.HybridConnectivity; do
     az provider register --namespace "$ns"
   done
   ```

   **Expected result:** each provider reports `Registered` within a few minutes.

1. On the **target server**, install the Connected Machine agent:

   ```bash
   curl -fsSL https://aka.ms/azcmagent | bash
   ```

   **Expected result:** `azcmagent version` prints an agent version.

1. Connect the server to Azure Arc:

   ```bash
   azcmagent connect \
     --resource-group "$RG" \
     --tenant-id "$TENANT_ID" \
     --location "$LOCATION" \
     --subscription-id "$SUBSCRIPTION_ID"
   ```

   **Expected result:** `Connected machine ... to Azure` and a new **Machine - Azure Arc**
   resource appears in `rg-mhb-<initials>`.

## Validation

```bash
azcmagent show
az connectedmachine show --name "$(hostname)" --resource-group "$RG" -o table
```

- **Good looks like:** `Agent Status: Connected`, and the resource lists a `Connected` status
  with the expected OS and version.

## Rollback / recovery

> [!WARNING]
> Disconnecting removes the Arc resource and any attached extensions. Confirm before running.

1. Disconnect the agent:

   ```bash
   azcmagent disconnect
   ```

1. Confirm the Arc resource is gone:

   ```bash
   az connectedmachine list --resource-group "$RG" -o table
   ```

## Evidence captured

- **Control:** B.4.2 (Partner Onboarding Assets); also B.1.1.
- **Artifact to file:** save `azcmagent show` output to
  `evidence-package/b1.1-implementation/arc-onboarding/azcmagent-show.txt` and add a row to the
  [Evidence Index](./sample-evidence-index.md).

## References

- [Connect hybrid machines with Azure Arc](https://learn.microsoft.com/azure/azure-arc/servers/learn/quick-enable-hybrid-vm)
- [`azcmagent` reference](https://learn.microsoft.com/azure/azure-arc/servers/azcmagent)
