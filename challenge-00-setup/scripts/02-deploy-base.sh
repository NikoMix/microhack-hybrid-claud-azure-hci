#!/usr/bin/env bash
# Deploy the shared base environment (infra/terraform/base) for the microhack.
# Usage: ./02-deploy-base.sh <initials> [location]
#   <initials>  short id used in resource names, e.g. rg-mhb-<initials>
#   [location]  optional Azure region (default: swedencentral)
set -euo pipefail

INITIALS="${1:-}"
LOCATION="${2:-swedencentral}"

if [[ -z "$INITIALS" ]]; then
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

# Resolve the base dir relative to this script so it runs from anywhere.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(cd "${SCRIPT_DIR}/../../infra/terraform/base" && pwd)"

export TF_VAR_initials="$INITIALS"
export TF_VAR_location="$LOCATION"

echo "==> Deploying base environment for initials='${INITIALS}' in '${LOCATION}'"
echo "    (Terraform working dir: ${BASE_DIR})"

terraform -chdir="$BASE_DIR" init -input=false
terraform -chdir="$BASE_DIR" fmt -check -recursive || true
terraform -chdir="$BASE_DIR" validate
terraform -chdir="$BASE_DIR" plan -input=false -out=base.tfplan
terraform -chdir="$BASE_DIR" apply -input=false base.tfplan

echo
echo "==> Base environment deployed. Key outputs:"
terraform -chdir="$BASE_DIR" output
echo
echo "Next: SSH into your server-to-migrate with"
echo "    \$(terraform -chdir=\"$BASE_DIR\" output -raw ssh_command)"
echo "Then continue with challenge-01-arc-foundations."
