# Partner runbook — Azure Arc server onboarding

A reusable, customer-ready procedure for onboarding a server estate to **Azure
Arc-enabled servers** and bringing it under Azure governance. It generalises the
hands-on work in [Challenge 01](../README.md) into a repeatable **partner
onboarding asset** — the deliverable for Module B control **B.4.2**, reinforcing
**B.1.1** implementation capability.

> [!NOTE]
> This runbook targets **genuinely off-Azure** machines (on-premises, edge, or
> other clouds — including Azure Local nodes). The classroom **IMDS-block**
> technique exists only to make an Azure VM *simulate* an off-Azure server and is
> **not** part of a real customer engagement.

## 1. Scope and outcomes

| Item | Description |
| --- | --- |
| In scope | Windows/Linux servers, physical or virtual, off-Azure. |
| Outcome | Each server is an Azure resource (`Microsoft.HybridCompute/machines`), tagged, policy-governed, and inventoried. |
| Not in scope | Workload migration, application refactoring, network redesign. |
| Evidence | Connected machines in Azure, applied tags, a guest-configuration policy assignment, and an Azure Resource Graph inventory export. |

## 2. Prerequisites

- **Access:** the operator holds **Azure Connected Machine Onboarding** (or
  Contributor) on the target resource group, and local administrator/root on each
  server.
- **Providers registered** in the subscription: `Microsoft.HybridCompute`,
  `Microsoft.GuestConfiguration`, `Microsoft.HybridConnectivity`,
  `Microsoft.PolicyInsights`.
- **Connectivity:** outbound HTTPS (443) to the Azure Arc endpoints, ideally via
  **[Azure Arc gateway](https://learn.microsoft.com/azure/azure-arc/servers/arc-gateway)**
  to reduce the required endpoints to a small, auditable set behind enterprise
  proxies.
- **Naming & tagging standard** agreed with the customer (this lab uses
  `*-mhb-<initials>-01` and the governance tags below).

## 3. Onboarding methods (choose per scale)

| Scale | Method | Notes |
| --- | --- | --- |
| 1–few servers | Interactive `azcmagent connect` (device code) | Fastest for a pilot. |
| Many servers | **Service principal** with the onboarding role | Non-interactive, scriptable, least-privilege; used below. |
| Fleet | Onboarding script from the portal / configuration management | Pair with the service-principal method. |

## 4. Procedure

> [!WARNING]
> Steps 4.2–4.4 change the server and create Azure resources. In a customer
> engagement, obtain change approval first and run against a pilot group before
> the fleet.

1. **Create a least-privilege onboarding identity** (once per engagement), scoped
   to the target resource group with the **Azure Connected Machine Onboarding**
   role. Treat the secret as short-lived and never store it in source control.
2. **Install the Connected Machine agent** on each server (`azcmagent`), from the
   official `https://aka.ms/azcmagent` installer.
3. **Connect to Azure Arc**, supplying subscription, resource group, region,
   tenant, governance tags, and a correlation id:

   ```bash
   azcmagent connect \
     --service-principal-id "<appId>" \
     --service-principal-secret "<secret>" \
     --tenant-id "<tenantId>" \
     --subscription-id "<subId>" \
     --resource-group "<resourceGroup>" \
     --location "<region>" \
     --cloud "AzureCloud" \
     --tags "Datacenter=<dc>,Workload=<app>,Environment=<env>,ManagedBy=azure-arc" \
     --correlation-id "<guid>"
   ```

4. **Verify Connected state** on the server (`azcmagent show`) and in Azure
   (`az connectedmachine show`).
5. **Apply governance tags and policy.** Tag the machine consistently and assign
   the guest-configuration **compute security baseline** policy so the server is
   continuously audited.
6. **Inventory.** Export an Azure Resource Graph snapshot of the onboarded fleet
   (see [`arc-inventory.kql`](./arc-inventory.kql)) as engagement evidence.

## 5. Governance tags (standard)

| Tag | Example | Purpose |
| --- | --- | --- |
| `Datacenter` | `contoso-hq` | Physical/logical location. |
| `City` | `Stockholm` | Geography for residency/ops. |
| `Workload` | `three-tier-app` | Business application served. |
| `Environment` | `prod` / `lab` | Lifecycle stage. |
| `CostCenter` | `CC-1001` | Chargeback. |
| `ManagedBy` | `azure-arc` | Management plane of record. |
| `ModuleBControl` | `B.1.1` | Evidence linkage (lab convention). |

## 6. Day-2 management enabled by Arc

Once Connected, the same server is governed by the Azure control plane — the value
story to land with the customer:

- **Monitoring:** Azure Monitor + **Arc Insights** (performance, dependency map).
- **Patching:** **Azure Update Manager** (assessment, scheduled maintenance;
  hotpatch on supported Windows Server via Arc).
- **Security:** Microsoft **Defender for Servers Plan 2** (EDR, vulnerability
  assessment, posture).
- **Configuration:** **machine configuration** (guest configuration) audit and
  remediation via Azure Policy.
- **Resiliency:** Azure Backup and Site Recovery patterns.

## 7. Rollback / offboarding

1. Disconnect the agent on the server: `sudo azcmagent disconnect`.
2. Remove the Azure resource if it lingers:
   `az connectedmachine delete -g <rg> -n <name> --yes`.
3. Remove the policy assignment and the onboarding service principal.
4. Uninstall the agent if required by the customer.

## 8. Acceptance checklist

- [ ] Every target server shows **Connected** in Azure.
- [ ] Agent version is current (auto-upgrade considered).
- [ ] Governance tags applied and validated.
- [ ] Guest-configuration policy assigned; first compliance scan triggered.
- [ ] Resource Graph inventory exported and stored with engagement records.
- [ ] Onboarding service principal credential rotated or removed post-onboarding.

## References

- [Azure Arc-enabled servers overview](https://learn.microsoft.com/azure/azure-arc/servers/overview)
- [Connect machines at scale using a service principal](https://learn.microsoft.com/azure/azure-arc/servers/onboard-service-principal)
- [Azure Arc gateway](https://learn.microsoft.com/azure/azure-arc/servers/arc-gateway)
- [Understand the machine configuration feature of Azure Policy](https://learn.microsoft.com/azure/governance/machine-configuration/overview)
