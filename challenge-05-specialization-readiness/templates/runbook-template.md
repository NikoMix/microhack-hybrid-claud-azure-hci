# Runbook — `<Runbook title>`

> Reusable, parameterized operational runbook template. Copy it per procedure (Arc
> onboarding, monitoring, backup/DR, patching, incident response). Keep the section order —
> it matches the **`runbook-generator`** skill and is primary evidence for **Module B control
> B.4.2 (Partner Onboarding Assets)**.

> [!TIP]
> Parameterize everything (`<initials>`, `<region>`, `<resource-group>`) so the runbook is
> engagement-agnostic and genuinely reusable. Never hardcode a customer name or secret.

## Purpose & scope

- **What this automates:** `<one sentence>`.
- **In scope:** `<systems / resources covered>`.
- **Out of scope:** `<explicit boundaries>`.
- **Module B control evidenced:** B.4.2 (and strengthens B.1.1).

## Prerequisites

- **Access / RBAC:** `<least-privilege role, e.g. Contributor on rg-mhb-<initials>>`.
- **Registered providers:** `<e.g. Microsoft.HybridCompute, Microsoft.Insights>`.
- **Tools:** `<az CLI, azcmagent, terraform, kubectl — as needed>`.
- **Inputs:** `INITIALS=<initials>`, `LOCATION=<region>`, `RG=rg-mhb-<initials>`.

## Roles & RACI

| Activity | Responsible | Accountable | Consulted | Informed |
| --- | --- | --- | --- | --- |
| Execute the procedure | `<role>` | `<role>` | `<role>` | `<role>` |
| Approve changes | `<role>` | `<role>` | `<role>` | `<role>` |

## Procedure

Each Azure-changing step shows the exact command and the expected result.

1. Set parameters:

   ```bash
   set -euo pipefail
   export INITIALS="<initials>"
   export LOCATION="<region>"
   export RG="rg-mhb-${INITIALS}"
   ```

1. `<Action>`:

   ```bash
   <az / azcmagent / terraform command>
   ```

   **Expected result:** `<what success looks like>`.

1. `<Next action>` — repeat the command + expected-result pattern.

> [!WARNING]
> Mark any destructive step explicitly and require confirmation before running it.

## Validation

```bash
<validation command, e.g. az resource list -g "$RG" -o table>
```

- **Good looks like:** `<observable success criteria>`.

## Rollback / recovery

1. `<How to undo or recover, with commands>`.
1. `<How to confirm the rollback succeeded>`.

## Evidence captured

- **Control:** B.4.2 (Partner Onboarding Assets); also supports B.1.1.
- **Artifact to file:** save this completed runbook under the engagement's
  `evidence-package/b4.2-onboarding/runbooks/` and add a row to the
  [Evidence Index](./evidence-index.md).

## References

- [Azure Arc-enabled servers — operations](https://learn.microsoft.com/azure/azure-arc/servers/overview)
- [Azure CLI reference](https://learn.microsoft.com/cli/azure/)
