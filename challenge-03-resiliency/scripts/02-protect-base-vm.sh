#!/usr/bin/env bash
# Register the base "server to migrate" VM as a protected backup item and trigger
# an initial on-demand backup so pupils get a recovery point during the lab.
#
# Idempotent: Terraform converges the protected-item state; the on-demand backup
# is skipped if a backup job is already running.
#
# Usage: ./02-protect-base-vm.sh <initials> [location]
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
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INFRA_DIR="$(cd "${SCRIPT_DIR}/../infra" && pwd)"

export TF_VAR_initials="${INITIALS}"
export TF_VAR_location="${LOCATION}"
export TF_VAR_protect_base_vm="true"

echo "==> Registering vm-mhb-${INITIALS} as a protected backup item..."
terraform -chdir="${INFRA_DIR}" apply -input=false -auto-approve -var protect_base_vm=true

RG="$(terraform -chdir="${INFRA_DIR}" output -raw resource_group_name)"
VAULT="$(terraform -chdir="${INFRA_DIR}" output -raw recovery_services_vault_name)"
VM_NAME="$(terraform -chdir="${INFRA_DIR}" output -raw protected_vm_name)"

echo "==> Triggering an initial on-demand backup (retain 30 days)..."
CONTAINER="$(az backup item list \
  --resource-group "${RG}" \
  --vault-name "${VAULT}" \
  --backup-management-type AzureIaasVM \
  --workload-type VM \
  --query "[?properties.friendlyName=='${VM_NAME}'].properties.containerName | [0]" -o tsv 2>/dev/null || true)"

if [[ -z "${CONTAINER}" || "${CONTAINER}" == "None" ]]; then
  echo "    Protected item not visible yet (backup registration can lag a few minutes)."
  echo "    Re-run this script shortly to trigger the on-demand backup."
  exit 0
fi

RETAIN_UNTIL="$(date -u -d '+30 days' '+%d-%m-%Y' 2>/dev/null || date -u -v+30d '+%d-%m-%Y')"

az backup protection backup-now \
  --resource-group "${RG}" \
  --vault-name "${VAULT}" \
  --container-name "${CONTAINER}" \
  --item-name "${VM_NAME}" \
  --backup-management-type AzureIaasVM \
  --retain-until "${RETAIN_UNTIL}" \
  --query "{job:name,status:properties.status}" -o jsonc

echo
echo "==> Protection enabled. Watch the job with:"
echo "    az backup job list --resource-group ${RG} --vault-name ${VAULT} -o table"
