#!/usr/bin/env bash
# 00-create-cluster.sh — stand up a lightweight, license-free Kubernetes cluster.
#
# Engines:
#   k3s  (default) — Rancher k3s (Apache-2.0). Best on the base "server-to-migrate"
#                    VM or any systemd Linux host. Outbound 443 only.
#   kind          — Kubernetes-in-Docker (Apache-2.0). Requires a Docker daemon.
#
# Idempotent: re-running detects an existing cluster and leaves it untouched.
#
# Usage: ./00-create-cluster.sh [--engine k3s|kind] [--name <cluster-name>]
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

ENGINE="k3s"
NAME="mhb-arc"

usage() { grep '^#' "$0" | sed 's/^# \{0,1\}//'; exit "${1:-0}"; }

while [[ $# -gt 0 ]]; do
  case "$1" in
    --engine) ENGINE="${2:-}"; shift 2 ;;
    --name)   NAME="${2:-}"; shift 2 ;;
    -h|--help) usage 0 ;;
    *) die "unknown argument: $1 (try --help)" ;;
  esac
done

create_k3s() {
  require_cmd curl
  if command -v k3s >/dev/null 2>&1 && systemctl is-active --quiet k3s 2>/dev/null; then
    ok "k3s already installed and running"
  else
    info "installing k3s (write-kubeconfig-mode 644)…"
    curl -sfL https://get.k3s.io | sh -s - --write-kubeconfig-mode 644
    ok "k3s installed"
  fi

  # Make kubeconfig usable by the current (non-root) user.
  mkdir -p "${HOME}/.kube"
  if [[ -r /etc/rancher/k3s/k3s.yaml ]]; then
    install -m 600 /etc/rancher/k3s/k3s.yaml "${HOME}/.kube/config"
  else
    sudo cp /etc/rancher/k3s/k3s.yaml "${HOME}/.kube/config"
    sudo chown "$(id -u):$(id -g)" "${HOME}/.kube/config"
    chmod 600 "${HOME}/.kube/config"
  fi
  ok "kubeconfig written to ${HOME}/.kube/config"
}

create_kind() {
  require_cmd kind kubectl docker
  docker info >/dev/null 2>&1 || die "Docker daemon not reachable — kind needs Docker"
  if kind get clusters 2>/dev/null | grep -qx "$NAME"; then
    ok "kind cluster already exists: $NAME"
  else
    info "creating kind cluster: $NAME"
    kind create cluster --name "$NAME"
    ok "kind cluster created: $NAME"
  fi
}

case "$ENGINE" in
  k3s)  create_k3s ;;
  kind) create_kind ;;
  *) die "unsupported --engine '$ENGINE' (use k3s or kind)" ;;
esac

info "cluster nodes:"
kubectl get nodes -o wide || warn "kubectl could not reach the cluster yet — re-check KUBECONFIG"

cat <<'NEXT'

Next: connect this cluster to Azure Arc with
    ./01-connect-arc.sh --initials <abc>
NEXT
