# Cluster evidence — Challenge 04

Capture these artifacts during the lab to evidence **Module B** controls
**B.1.1** (implementation of the Arc-enabled hybrid estate) and **B.2.1**
(consumption / workload performance signal). The helper scripts write here when
run with `--evidence`, or capture manually with the commands below.

| File | Command | Evidences |
| --- | --- | --- |
| `connectedk8s-show.json` | `az connectedk8s show -g <rg> -n <cluster> -o json` | Cluster is Connected to Azure Arc (B.1.1). |
| `nodes.txt` | `kubectl get nodes -o wide` | Kubernetes control plane is healthy (B.1.1). |
| `flux-kustomizations.txt` | `az k8s-configuration flux list -g <rg> -c <cluster> -t connectedClusters -o table` | GitOps reconciliation is active (B.1.1). |
| `flux-pods.txt` | `kubectl get pods -n flux-system` | Flux controllers running (B.1.1). |
| `workload-pods.txt` | `kubectl get pods -n contoso-shop -o wide` | Sample workload reconciled and running (B.2.1). |
| `k8s-extensions.txt` | `az k8s-extension list -g <rg> -c <cluster> -t connectedClusters -o table` | Azure Monitor + Azure Policy extensions installed (B.1.1 / B.2.1). |
| `policy-compliance.json` | `az policy state summarize -g <rg> -o json` | Pod security baseline compliance result (B.1.1). |

> [!NOTE]
> Replace `<rg>`, `<cluster>` with your values (`rg-mhb-<initials>`,
> `arck8s-mhb-<initials>-04`). Redact subscription IDs / tenant IDs before
> sharing evidence outside the lab.

The `.placeholder` files are committed only to keep this folder in version
control; overwrite them with your real captures.
