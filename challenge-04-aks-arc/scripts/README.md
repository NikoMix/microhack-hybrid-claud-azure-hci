# Helper scripts — Challenge 04

Idempotent bash helpers that drive the CLI-side of the challenge. Each script is
self-documenting (`--help`) and parameterised — no hardcoded resource names.

| Script | Purpose |
| --- | --- |
| `00-create-cluster.sh` | Stand up a local k3s (default) or kind cluster. |
| `01-connect-arc.sh` | Register providers + `az connectedk8s connect`. |
| `02-bootstrap-flux.sh` | `az k8s-configuration flux create` against `../assets/gitops`. |
| `03-enable-monitor-policy.sh` | Install Container Insights + Azure Policy extensions. |
| `99-cleanup.sh` | Remove Flux config, extensions, Arc connection, local cluster. |
| `lib/common.sh` | Shared logging, guards, provider/extension helpers (sourced). |

## Order of operations

```bash
./00-create-cluster.sh --engine k3s
./01-connect-arc.sh         --initials abc
./02-bootstrap-flux.sh      --initials abc --git-url https://github.com/<you>/microhack-hybrid-claud-azure-hci.git
./03-enable-monitor-policy.sh --initials abc
# …lab…
./99-cleanup.sh             --initials abc --yes
```

## Conventions

- `#!/usr/bin/env bash` + `set -euo pipefail`, LF line endings.
- Re-runnable: existing clusters, connections, extensions, and Flux configs are
  detected and left intact (or updated in place).
- Defaults follow the lab naming standard: `rg-mhb-<initials>`,
  `arck8s-mhb-<initials>-04`, `gitops-mhb-<initials>-04`.
- Override any default with the matching flag (`--resource-group`,
  `--cluster-name`, `--location`, `--subscription`, …).

> [!IMPORTANT]
> Run `01`–`03` from the **base VM** when your cluster is k3s on that VM, so the
> Arc agent uses its outbound 443. They are equally runnable from Codespaces when
> your `KUBECONFIG` points at the target cluster.

Validate locally with [`shellcheck`](https://www.shellcheck.net/):

```bash
shellcheck -x scripts/*.sh scripts/lib/common.sh
```
