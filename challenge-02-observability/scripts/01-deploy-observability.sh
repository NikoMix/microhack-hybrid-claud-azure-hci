#!/usr/bin/env bash
# Deploy the Challenge 02 observability stack (DCRs, alert, workbook, Update
# Manager maintenance config) reusing the shared base Log Analytics workspace.
#
# Usage: ./01-deploy-observability.sh <initials> [location] [machine-resource-id]
#   <initials>            short id used in resource names, e.g. rg-mhb-<initials>
#   [location]            optional Azure region (default: swedencentral)
#   [machine-resource-id] optional resource ID of the machine to monitor
#                         (Arc: Microsoft.HybridCompute/machines/<name>, or
#                          VM:  Microsoft.Compute/virtualMachines/<name>).
#                         When omitted, the rules are created but not associated.
set -euo pipefail

INITIALS="${1:-}"
LOCATION="${2:-swedencentral}"
MACHINE_ID="${3:-}"

if [[ -z "$INITIALS" ]]; then
  echo "Usage: $0 <initials> [location] [machine-resource-id]" >&2
  exit 1
fi

if ! az account show >/dev/null 2>&1; then
  echo "ERROR: not logged in. Run: az login --use-device-code" >&2
  exit 1
fi

if [[ -z "${ARM_SUBSCRIPTION_ID:-}" ]]; then
  ARM_SUBSCRIPTION_ID="$(az account show --query id -o tsv)"
  export ARM_SUBSCRIPTION_ID
  echo "==> Exported ARM_SUBSCRIPTION_ID=${ARM_SUBSCRIPTION_ID}"
fi

# Resolve dirs relative to this script so it runs from anywhere.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INFRA_DIR="$(cd "${SCRIPT_DIR}/../infra" && pwd)"
BASE_DIR="$(cd "${SCRIPT_DIR}/../../infra/terraform/base" && pwd)"

# Reuse the shared base Log Analytics workspace (base output:
# log_analytics_workspace_id) unless an override is already supplied.
WORKSPACE_ID="${TF_VAR_log_analytics_workspace_id:-}"
if [[ -z "$WORKSPACE_ID" ]]; then
  echo "==> Resolving Log Analytics workspace ID from base output..."
  WORKSPACE_ID="$(terraform -chdir="$BASE_DIR" output -raw log_analytics_workspace_id)"
fi

if [[ -z "$WORKSPACE_ID" ]]; then
  echo "ERROR: could not resolve log_analytics_workspace_id. Deploy the base first" >&2
  echo "       (challenge-00-setup) or set TF_VAR_log_analytics_workspace_id." >&2
  exit 1
fi

export TF_VAR_initials="$INITIALS"
export TF_VAR_location="$LOCATION"
export TF_VAR_log_analytics_workspace_id="$WORKSPACE_ID"

if [[ -n "$MACHINE_ID" ]]; then
  export TF_VAR_monitored_resource_id="$MACHINE_ID"
  echo "==> Will associate DCRs with: ${MACHINE_ID}"
else
  echo "==> No machine-resource-id supplied; DCRs will be created but not associated."
fi

echo "==> Deploying observability stack for initials='${INITIALS}' in '${LOCATION}'"
echo "    (Terraform working dir: ${INFRA_DIR})"
echo "    (Reusing workspace: ${WORKSPACE_ID})"

terraform -chdir="$INFRA_DIR" init -input=false
terraform -chdir="$INFRA_DIR" fmt -check -recursive || true
terraform -chdir="$INFRA_DIR" validate
terraform -chdir="$INFRA_DIR" plan -input=false -out=observability.tfplan
terraform -chdir="$INFRA_DIR" apply -input=false observability.tfplan

echo
echo "==> Observability stack deployed. Key outputs:"
terraform -chdir="$INFRA_DIR" output
echo
echo "Next: run ./02-update-manager.sh <machine-resource-id> to assess and patch."
