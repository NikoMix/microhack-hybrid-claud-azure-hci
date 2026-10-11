# Challenge 04 trainer notes

Private guidance for delivering **AKS enabled by Azure Arc & GitOps**. The pupils'
biggest "aha" is that the *same* Arc + GitOps + Monitor + Policy loop they build
on a 1-node k3s cluster is exactly what operates a production AKS-on-Azure-Local
estate — only the substrate changes.

## Timing

| Minute | Activity | Trainer cue |
| ---: | --- | --- |
| 0-5 | Context + demo: why one control plane for clusters | Recall Arc-for-servers from Ch01; promise the same for Kubernetes. |
| 5-15 | Task 1 — create k3s/kind cluster | Pre-pull is unnecessary; watch for missing `KUBECONFIG`. |
| 15-30 | Task 2 — connect to Arc | Provider registration is the slow part — start it talking. |
| 30-45 | Task 3 — Flux GitOps | Emphasise Git as source of truth; show the reconcile land. |
| 45-55 | Task 4 — Monitor + Policy extensions | Note Container Insights data lags ~10-15 min. |
| 55-60 | Task 5 + checkpoint | Minimum viable checkpoint: **cluster Connected + Flux reconciled**. |

> [!NOTE]
> Minimum viable outcome if you run short: pupils reach **Connected** (Task 2) and
> see Flux reconcile `contoso-shop` (Task 3). Monitor/Policy/Terraform (Tasks 4-5)
> can be shown from your screen if pupils run out of time.

## Talk track

"In Challenge 01 we made a *server* an Azure resource. Application teams live in
Kubernetes, and they want the same deal: one control plane, consistent policy,
and an audit trail of what's running. Azure Arc projects *any* CNCF-conformant
cluster into Azure — the very mechanism behind AKS enabled by Azure Arc on Azure
Local. We'll prove the model on a tiny k3s cluster: connect it to Arc, hand its
desired state to Flux so Git is the single source of truth, then switch on
Monitor and Policy. For Contoso that means the migration to Azure Local is a
*change of substrate, not a change of operating model* — and every step here is
B.1.1 implementation evidence plus B.2.1 consumption signal."

## Live demo script

1. Show an empty cluster reconciling from Git in real time:

   ```bash
   kubectl get pods -n contoso-shop -w
   ```

1. In another pane, show the Arc resource and its GitOps config in Azure:

   ```bash
   az connectedk8s show -g rg-mhb-<abc> -n arck8s-mhb-<abc>-04 -o table
   az k8s-configuration flux list -g rg-mhb-<abc> -c arck8s-mhb-<abc>-04 \
     -t connectedClusters -o table
   ```

1. Demonstrate self-healing: delete the deployment and watch Flux restore it:

   ```bash
   kubectl delete deploy podinfo -n contoso-shop
   # …within one interval it returns…
   kubectl get deploy -n contoso-shop
   ```

## Common pitfalls

| Symptom | Likely cause | Fix |
| --- | --- | --- |
| `kubectl` cannot reach cluster | `KUBECONFIG` not set / k3s file unreadable | Re-run `00-create-cluster.sh`; it writes `~/.kube/config` mode 600. |
| `connectedk8s connect` fails fast | Providers not registered | The script registers `Microsoft.Kubernetes`, `…KubernetesConfiguration`, `…ExtendedLocation`; allow a few minutes the first time. |
| Flux config `Pending` forever | Wrong `--url` / private repo / bad `path` | Use a **public HTTPS** URL; confirm `path` resolves to `assets/gitops`. |
| Pods rejected in `contoso-shop` | Manifest violates PSA `baseline` label | Keep the `securityContext` intact; that is the teaching point — revert the edit. |
| No Container Insights data | Normal ingestion lag | Wait ~10-15 min; verify the workspace ID passed to the extension. |
| `az connectedk8s` command not found | Extension missing | Scripts run `ensure_az_extension`; otherwise `az extension add --name connectedk8s`. |

See [../docs/troubleshooting.md](../docs/troubleshooting.md) for shared issues.

## Checkpoint questions & answers

**Q1. What problem does GitOps solve in the hybrid story?**

A: It applies desired state consistently to distributed clusters and creates an
auditable, Git-backed history of every change — the same workflow whether the
cluster runs in class, in Azure, or on Azure Local.

**Q2. Why use a lightweight cluster in class?**

A: It safely demonstrates the Azure Arc and GitOps operating model without
requiring physical Azure Local hardware; the Arc/Flux/Monitor/Policy layer is
identical regardless of the underlying cluster.

**Q3. Which Module B controls does this challenge evidence, and how?**

A: B.1.1 (implementation) — an Arc-enabled cluster governed through the Azure
control plane; and B.2.1 (ACR performance) — the Arc, Monitor/Log Analytics, and
Policy consumption it drives. Do not quote numeric thresholds; point to the
official requirements PDF.

## Reset between cohorts

- Run the per-challenge cleanup for each pupil:
  `./scripts/99-cleanup.sh --initials <abc> --yes` then
  `terraform -chdir=infra destroy`.
- Confirm no leftover `arck8s-mhb-*-04` resources or `gitops-mhb-*-04` Flux
  configs remain in the resource group.
- Restore `assets/evidence/*.placeholder` if a previous cohort overwrote them.
- Confirm [../docs/teardown.md](../docs/teardown.md) removes all shared resources.
- Recreate only the resources intentionally needed for the next cohort (the base
  environment and workspace are shared and usually left in place).
