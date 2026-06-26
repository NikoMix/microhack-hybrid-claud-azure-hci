#!/usr/bin/env bash
# 99-cleanup.sh — tear down everything this challenge created.
#
# Removes (in order): the Flux configuration, the cluster extensions, the Arc
# connection, and finally the local cluster. Idempotent and safe to re-run.
#
# It does NOT delete the shared base resource group, nor the Terraform-managed
# DCR/policy in ../infra (use `terraform destroy` there for those).
#
# Usage:
#   ./99-cleanup.sh --initials <abc> [--engine k3s|kind] [--name <kind-name>]
#         [--resource-group <rg>] [--cluster-name <name>]
#         [--subscription <id>] [--yes]
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

INITIALS=""; RG=""; CLUSTER=""; CONFIG=""; SUBSCRIPTION=""
ENGINE="k3s"; NAME="mhb-arc"; ASSUME_YES="false"

usage() { grep '^#' "$0" | sed 's/^# \{0,1\}//'; exit "${1:-0}"; }

while [[ $# -gt 0 ]]; do
  case "$1" in
    --initials)       INITIALS="${2:-}"; shift 2 ;;
    --engine)         ENGINE="${2:-}"; shift 2 ;;
    --name)           NAME="${2:-}"; shift 2 ;;
    --resource-group) RG="${2:-}"; shift 2 ;;
    --cluster-name)   CLUSTER="${2:-}"; shift 2 ;;
    --subscription)   SUBSCRIPTION="${2:-}"; shift 2 ;;
    --yes)            ASSUME_YES="true"; shift ;;
    -h|--help) usage 0 ;;
    *) die "unknown argument: $1 (try --help)" ;;
  esac
done

validate_initials "$INITIALS"
RG="${RG:-$(rg_name "$INITIALS")}"
CLUSTER="${CLUSTER:-$(cluster_name "$INITIALS")}"
CONFIG="${CONFIG:-$(flux_name "$INITIALS")}"

if [[ "$ASSUME_YES" != "true" ]]; then
  warn "About to remove Arc cluster '${CLUSTER}' (${RG}) and the local ${ENGINE} cluster."
  read -r -p "  Type 'yes' to continue: " reply
  [[ "$reply" == "yes" ]] || die "aborted"
fi

# --- Azure side (best-effort, only if logged in) -----------------------------
if az account show >/dev/null 2>&1; then
  ensure_subscription "$SUBSCRIPTION"

  info "deleting Flux configuration (if present)…"
  if az k8s-configuration flux delete \
    --resource-group "$RG" --cluster-name "$CLUSTER" \
    --cluster-type connectedClusters --name "$CONFIG" --yes >/dev/null 2>&1; then
    ok "Flux configuration deleted"
  else
    warn "no Flux configuration to delete"
  fi

  for ext in azuremonitor-containers azurepolicy; do
    info "deleting extension '${ext}' (if present)…"
    if az k8s-extension delete \
      --resource-group "$RG" --cluster-name "$CLUSTER" \
      --cluster-type connectedClusters --name "$ext" --yes --force >/dev/null 2>&1; then
      ok "extension ${ext} deleted"
    else
      warn "no ${ext} extension to delete"
    fi
  done

  info "deleting Arc connection (if present)…"
  if az connectedk8s delete \
    --resource-group "$RG" --name "$CLUSTER" --yes >/dev/null 2>&1; then
    ok "Arc connection deleted"
  else
    warn "no Arc connection to delete"
  fi
else
  warn "not logged in to Azure — skipping cloud-side cleanup"
fi

# --- Local cluster -----------------------------------------------------------
case "$ENGINE" in
  k3s)
    if [[ -x /usr/local/bin/k3s-uninstall.sh ]]; then
      info "uninstalling k3s…"
      sudo /usr/local/bin/k3s-uninstall.sh
      ok "k3s removed"
    else
      warn "k3s uninstaller not found — nothing to remove"
    fi
    ;;
  kind)
    if command -v kind >/dev/null 2>&1 && kind get clusters 2>/dev/null | grep -qx "$NAME"; then
      info "deleting kind cluster '${NAME}'…"
      kind delete cluster --name "$NAME"
      ok "kind cluster removed"
    else
      warn "kind cluster '${NAME}' not found — nothing to remove"
    fi
    ;;
  *) die "unsupported --engine '$ENGINE' (use k3s or kind)" ;;
esac

ok "cleanup complete"
