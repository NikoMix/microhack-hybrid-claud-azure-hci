# Sample GitOps manifests — `contoso-shop`

These manifests are the **desired state** that Flux reconciles onto the
Arc-enabled cluster. They are intentionally tiny, license-free, and
security-hardened so they pass the pod security baseline you assign in
[`../../infra`](../../infra).

| File | Kind | Notes |
| --- | --- | --- |
| `namespace.yaml` | `Namespace` | `contoso-shop` with Pod Security Admission labels (`enforce: baseline`, `warn/audit: restricted`). |
| `deployment.yaml` | `Deployment` | [podinfo](https://github.com/stefanprodan/podinfo) `6.14.0` (Apache-2.0) with a `restricted`-compliant security context and small CPU/memory footprint. |
| `service.yaml` | `Service` | `ClusterIP` exposing port `9898`. |
| `kustomization.yaml` | Kustomize | Ties the three resources together for the Flux kustomize-controller. |

## How Flux consumes this folder

`az k8s-configuration flux create` registers a Git source plus a kustomization
whose `path` points here. The kustomize-controller builds `kustomization.yaml`
and applies the result every reconcile interval (`--interval 1m` in the lab).

```text
Git repo ──▶ source-controller ──▶ kustomize-controller ──▶ contoso-shop workloads
```

## Try a change (drift demo)

1. Bump `replicas` in `deployment.yaml` from `1` to `2`, commit, and push.
2. Within one interval Flux reconciles and a second pod appears.
3. `kubectl delete deploy podinfo -n contoso-shop` — Flux restores it on the
   next reconcile (self-healing).

> [!TIP]
> Keep the security context intact. Removing it makes the pod violate the
> `baseline` PSA label and the namespace will reject it — a useful failure to
> demonstrate, then revert.
