#!/usr/bin/env bash
# Deploy the Challenge 03 resiliency module: Recovery Services vault + VM backup
# policy + Microsoft Defender for Servers Plan 2.
#
# Idempotent: re-running re-applies the same desired state (no duplicate resources).
#
# Usage: ./01-deploy-resiliency.sh <initials> [location]
#   <initials>  short id, must match your base environment (e.g. rg-mhb-<initials>)
#   [location]  optional Azure region (default: swedencentral)
set -euo pipefail

INITIALS="${1:-}"
LOCATION="${2:-swedencentral}"

if [[ -z "${INITIALS}" ]]; then
  echo "Usage: $0 <initials> [location]" >&2
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

# Resolve the infra dir relative to this script so it runs from anywhere.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INFRA_DIR="$(cd "${SCRIPT_DIR}/../infra" && pwd)"

# Locate the shared base module if it is checked out locally (optional).
BASE_DIR=""
if BASE_CANDIDATE="$(cd "${SCRIPT_DIR}/../../infra/terraform/base" 2>/dev/null && pwd)"; then
  BASE_DIR="${BASE_CANDIDATE}"
fi

export TF_VAR_initials="${INITIALS}"
export TF_VAR_location="${LOCATION}"

# Best-effort: stream vault diagnostics to the shared Log Analytics workspace if
# the base environment is deployed locally and exposes the output.
if [[ -n "${BASE_DIR}" ]]; then
  if WS_ID="$(terraform -chdir="${BASE_DIR}" output -raw log_analytics_workspace_id 2>/dev/null)"; then
    if [[ -n "${WS_ID}" ]]; then
      export TF_VAR_log_analytics_workspace_id="${WS_ID}"
      echo "==> Wiring vault diagnostics to workspace: ${WS_ID}"
    fi
  fi
fi

echo "==> Deploying resiliency module for initials='${INITIALS}' in '${LOCATION}'"
echo "    (Terraform working dir: ${INFRA_DIR})"

terraform -chdir="${INFRA_DIR}" init -input=false
terraform -chdir="${INFRA_DIR}" fmt -check -recursive || true
terraform -chdir="${INFRA_DIR}" validate
terraform -chdir="${INFRA_DIR}" plan -input=false -out=resiliency.tfplan
terraform -chdir="${INFRA_DIR}" apply -input=false resiliency.tfplan

echo
echo "==> Resiliency module deployed. Key outputs:"
terraform -chdir="${INFRA_DIR}" output
echo
echo "Next steps:"
echo "  1. Protect the base VM:  ./02-protect-base-vm.sh ${INITIALS} ${LOCATION}"
echo "  2. Review Defender for Cloud secure score in the Azure portal."
echo "  3. Collect evidence:     ./03-collect-evidence.sh ${INITIALS}"
