#!/usr/bin/env bash
# 03-enable-monitor-policy.sh — observability + governance on the Arc cluster.
#
# Installs two cluster extensions (idempotently):
#   * azuremonitor-containers  — Container Insights → shared Log Analytics.
#   * azurepolicy              — Azure Policy (Gatekeeper) for Kubernetes.
#
# Usage:
#   ./03-enable-monitor-policy.sh --initials <abc>
#         [--resource-group <rg>] [--cluster-name <name>]
#         [--workspace-resource-id <id>] [--subscription <id>]
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

INITIALS=""; RG=""; CLUSTER=""; WORKSPACE_ID=""; SUBSCRIPTION=""

usage() { grep '^#' "$0" | sed 's/^# \{0,1\}//'; exit "${1:-0}"; }

while [[ $# -gt 0 ]]; do
  case "$1" in
    --initials)              INITIALS="${2:-}"; shift 2 ;;
    --resource-group)        RG="${2:-}"; shift 2 ;;
    --cluster-name)          CLUSTER="${2:-}"; shift 2 ;;
    --workspace-resource-id) WORKSPACE_ID="${2:-}"; shift 2 ;;
    --subscription)          SUBSCRIPTION="${2:-}"; shift 2 ;;
    -h|--help) usage 0 ;;
    *) die "unknown argument: $1 (try --help)" ;;
  esac
done

validate_initials "$INITIALS"
RG="${RG:-$(rg_name "$INITIALS")}"
CLUSTER="${CLUSTER:-$(cluster_name "$INITIALS")}"

require_cmd az
require_az_login
ensure_subscription "$SUBSCRIPTION"
ensure_az_extension k8s-extension

# Resolve the shared Log Analytics workspace if not supplied.
if [[ -z "$WORKSPACE_ID" ]]; then
  info "resolving Log Analytics workspace '$(workspace_name "$INITIALS")' in '${RG}'…"
  WORKSPACE_ID="$(az monitor log-analytics workspace show \
    --resource-group "$RG" --workspace-name "$(workspace_name "$INITIALS")" \
    --query id -o tsv 2>/dev/null || true)"
  [[ -n "$WORKSPACE_ID" ]] ||
    die "could not resolve workspace — pass --workspace-resource-id <id>"
fi
ok "workspace: ${WORKSPACE_ID}"

# --- Azure Monitor (Container Insights) --------------------------------------
if az k8s-extension show --name azuremonitor-containers \
    --resource-group "$RG" --cluster-name "$CLUSTER" \
    --cluster-type connectedClusters >/dev/null 2>&1; then
  ok "Azure Monitor extension already installed"
else
  info "installing Azure Monitor (Container Insights) extension…"
  az k8s-extension create \
    --name azuremonitor-containers \
    --resource-group "$RG" \
    --cluster-name "$CLUSTER" \
    --cluster-type connectedClusters \
    --extension-type Microsoft.AzureMonitor.Containers \
    --configuration-settings amalogs.useAADAuth=true \
    --configuration-settings "logAnalyticsWorkspaceResourceID=${WORKSPACE_ID}"
  ok "Azure Monitor extension installed"
fi

# --- Azure Policy for Kubernetes ---------------------------------------------
register_provider Microsoft.PolicyInsights
if az k8s-extension show --name azurepolicy \
    --resource-group "$RG" --cluster-name "$CLUSTER" \
    --cluster-type connectedClusters >/dev/null 2>&1; then
  ok "Azure Policy extension already installed"
else
  info "installing Azure Policy extension…"
  az k8s-extension create \
    --name azurepolicy \
    --resource-group "$RG" \
    --cluster-name "$CLUSTER" \
    --cluster-type connectedClusters \
    --extension-type Microsoft.PolicyInsights
  ok "Azure Policy extension installed"
fi

info "installed extensions:"
az k8s-extension list \
  --resource-group "$RG" --cluster-name "$CLUSTER" \
  --cluster-type connectedClusters \
  --query '[].{name:name, type:extensionType, state:provisioningState}' \
  -o table || true

cat <<'NEXT'

Container Insights data appears in the workspace within ~10–15 minutes.
Assign the pod security baseline policy from ../infra (terraform apply) to
complete the governance story.
NEXT
