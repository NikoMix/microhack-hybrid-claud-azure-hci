#!/usr/bin/env bash
# 01-connect-arc.sh — connect the local Kubernetes cluster to Azure Arc.
#
# Registers the required resource providers, installs the connectedk8s CLI
# extension, and runs `az connectedk8s connect`. Idempotent: an already-connected
# cluster is detected and left in place.
#
# Usage:
#   ./01-connect-arc.sh --initials <abc> [--resource-group <rg>]
#                       [--cluster-name <name>] [--location <region>]
#                       [--subscription <id>]
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

INITIALS=""; RG=""; CLUSTER=""; LOCATION="swedencentral"; SUBSCRIPTION=""

usage() { grep '^#' "$0" | sed 's/^# \{0,1\}//'; exit "${1:-0}"; }

while [[ $# -gt 0 ]]; do
  case "$1" in
    --initials)       INITIALS="${2:-}"; shift 2 ;;
    --resource-group) RG="${2:-}"; shift 2 ;;
    --cluster-name)   CLUSTER="${2:-}"; shift 2 ;;
    --location)       LOCATION="${2:-}"; shift 2 ;;
    --subscription)   SUBSCRIPTION="${2:-}"; shift 2 ;;
    -h|--help) usage 0 ;;
    *) die "unknown argument: $1 (try --help)" ;;
  esac
done

validate_initials "$INITIALS"
RG="${RG:-$(rg_name "$INITIALS")}"
CLUSTER="${CLUSTER:-$(cluster_name "$INITIALS")}"

require_cmd az kubectl
require_az_login
ensure_subscription "$SUBSCRIPTION"
ensure_az_extension connectedk8s

# Providers needed for Arc-enabled Kubernetes + configurations + custom locations.
register_provider Microsoft.Kubernetes
register_provider Microsoft.KubernetesConfiguration
register_provider Microsoft.ExtendedLocation

if az connectedk8s show --resource-group "$RG" --name "$CLUSTER" >/dev/null 2>&1; then
  ok "cluster already connected to Arc: ${CLUSTER}"
else
  info "connecting '${CLUSTER}' to Azure Arc in '${RG}' (${LOCATION})…"
  az connectedk8s connect \
    --resource-group "$RG" \
    --name "$CLUSTER" \
    --location "$LOCATION"
  ok "cluster connected to Azure Arc"
fi

info "Arc connection summary:"
az connectedk8s show --resource-group "$RG" --name "$CLUSTER" \
  --query '{name:name, state:connectivityStatus, agentVersion:agentVersion, distribution:distribution}' \
  -o table || true

cat <<'NEXT'

Next: bootstrap GitOps with Flux
    ./02-bootstrap-flux.sh --initials <abc> --git-url <https-repo-url>
NEXT
