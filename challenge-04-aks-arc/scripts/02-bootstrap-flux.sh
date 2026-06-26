#!/usr/bin/env bash
# 02-bootstrap-flux.sh — configure GitOps (Flux v2) on the Arc-enabled cluster.
#
# Creates a Flux configuration that reconciles the sample manifests in
# ../assets/gitops onto the cluster. Idempotent: an existing configuration of the
# same name is updated in place rather than duplicated.
#
# Usage:
#   ./02-bootstrap-flux.sh --initials <abc> --git-url <https-repo-url>
#         [--branch <branch>] [--path <repo-path>]
#         [--resource-group <rg>] [--cluster-name <name>]
#         [--config-name <name>] [--subscription <id>]
#
# Defaults:
#   --branch main
#   --path   ./challenge-04-aks-arc/assets/gitops
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

INITIALS=""; RG=""; CLUSTER=""; CONFIG=""; SUBSCRIPTION=""
GIT_URL=""; BRANCH="main"; GIT_PATH="./challenge-04-aks-arc/assets/gitops"

usage() { grep '^#' "$0" | sed 's/^# \{0,1\}//'; exit "${1:-0}"; }

while [[ $# -gt 0 ]]; do
  case "$1" in
    --initials)       INITIALS="${2:-}"; shift 2 ;;
    --git-url)        GIT_URL="${2:-}"; shift 2 ;;
    --branch)         BRANCH="${2:-}"; shift 2 ;;
    --path)           GIT_PATH="${2:-}"; shift 2 ;;
    --resource-group) RG="${2:-}"; shift 2 ;;
    --cluster-name)   CLUSTER="${2:-}"; shift 2 ;;
    --config-name)    CONFIG="${2:-}"; shift 2 ;;
    --subscription)   SUBSCRIPTION="${2:-}"; shift 2 ;;
    -h|--help) usage 0 ;;
    *) die "unknown argument: $1 (try --help)" ;;
  esac
done

validate_initials "$INITIALS"
[[ -n "$GIT_URL" ]] || die "--git-url is required (the HTTPS URL of the Git repo Flux should track)"
RG="${RG:-$(rg_name "$INITIALS")}"
CLUSTER="${CLUSTER:-$(cluster_name "$INITIALS")}"
CONFIG="${CONFIG:-$(flux_name "$INITIALS")}"

require_cmd az
require_az_login
ensure_subscription "$SUBSCRIPTION"
ensure_az_extension k8s-configuration
register_provider Microsoft.KubernetesConfiguration

if az k8s-configuration flux show \
    --resource-group "$RG" --cluster-name "$CLUSTER" \
    --cluster-type connectedClusters --name "$CONFIG" >/dev/null 2>&1; then
  ok "Flux configuration already exists: ${CONFIG} (re-applying desired settings)"
fi

info "creating/updating Flux configuration '${CONFIG}' → ${GIT_URL} (${BRANCH}:${GIT_PATH})"
az k8s-configuration flux create \
  --resource-group "$RG" \
  --cluster-name "$CLUSTER" \
  --cluster-type connectedClusters \
  --name "$CONFIG" \
  --namespace flux-system \
  --scope cluster \
  --url "$GIT_URL" \
  --branch "$BRANCH" \
  --kustomization name=contoso-shop path="$GIT_PATH" prune=true \
  --interval 1m

ok "Flux configuration applied"

info "compliance state:"
az k8s-configuration flux show \
  --resource-group "$RG" --cluster-name "$CLUSTER" \
  --cluster-type connectedClusters --name "$CONFIG" \
  --query '{name:name, compliance:complianceState, provisioning:provisioningState}' \
  -o table || true

cat <<'NEXT'

Tip: watch reconciliation land the sample app
    kubectl get pods -n contoso-shop -w

Next: enable Azure Monitor + Azure Policy
    ./03-enable-monitor-policy.sh --initials <abc>
NEXT
