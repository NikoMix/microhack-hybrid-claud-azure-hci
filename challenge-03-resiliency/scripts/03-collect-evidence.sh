#!/usr/bin/env bash
# Collect a protection-evidence bundle (Azure Backup + Defender for Cloud posture)
# for the base VM and write it as JSON. This is the B.4.2 / B.2.1 evidence artifact.
#
# Idempotent: read-only against Azure; safe to run repeatedly.
#
# Usage: ./03-collect-evidence.sh <initials> [output_file]
#   <initials>    short id matching your environment
#   [output_file] default: ../assets/protection-evidence.<initials>.json
set -euo pipefail

INITIALS="${1:-}"

if [[ -z "${INITIALS}" ]]; then
  echo "Usage: $0 <initials> [output_file]" >&2
  exit 1
fi

for tool in az jq; do
  if ! command -v "${tool}" >/dev/null 2>&1; then
    echo "ERROR: required tool '${tool}' not found on PATH." >&2
    exit 1
  fi
done

if ! az account show >/dev/null 2>&1; then
  echo "ERROR: not logged in. Run: az login --use-device-code" >&2
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INFRA_DIR="$(cd "${SCRIPT_DIR}/../infra" && pwd)"
ASSETS_DIR="$(cd "${SCRIPT_DIR}/../assets" && pwd)"
OUT_FILE="${2:-${ASSETS_DIR}/protection-evidence.${INITIALS}.json}"

# Prefer Terraform outputs; fall back to the documented naming convention.
RG="$(terraform -chdir="${INFRA_DIR}" output -raw resource_group_name 2>/dev/null || echo "rg-mhb-${INITIALS}")"
VAULT="$(terraform -chdir="${INFRA_DIR}" output -raw recovery_services_vault_name 2>/dev/null || echo "rsv-mhb-${INITIALS}-03")"
VM_NAME="$(terraform -chdir="${INFRA_DIR}" output -raw protected_vm_name 2>/dev/null || echo "vm-mhb-${INITIALS}")"
SUB_ID="$(az account show --query id -o tsv)"

echo "==> Collecting protection evidence for ${VM_NAME} (vault ${VAULT})..."

BACKUP_ITEMS="$(az backup item list \
  --resource-group "${RG}" \
  --vault-name "${VAULT}" \
  --backup-management-type AzureIaasVM \
  --workload-type VM \
  --query "[].{name:properties.friendlyName,protectionState:properties.protectionState,lastBackupStatus:properties.lastBackupStatus,lastRecoveryPoint:properties.lastRecoveryPoint,policyName:properties.policyName,healthStatus:properties.healthStatus}" \
  -o json 2>/dev/null || echo '[]')"

BACKUP_JOBS="$(az backup job list \
  --resource-group "${RG}" \
  --vault-name "${VAULT}" \
  --query "[0:5].{operation:properties.operation,status:properties.status,startTime:properties.startTime,entity:properties.entityFriendlyName}" \
  -o json 2>/dev/null || echo '[]')"

DEFENDER_VM="$(az security pricing show --name VirtualMachines \
  --query "{name:name,tier:pricingTier,subPlan:subPlan}" \
  -o json 2>/dev/null || echo '{}')"

SECURE_SCORE="$(az security secure-scores show --name ascScore \
  --query "{current:score.current,max:score.max,percentage:score.percentage}" \
  -o json 2>/dev/null || echo '{}')"

GENERATED_AT="$(date -u '+%Y-%m-%dT%H:%M:%SZ')"

jq -n \
  --arg generated_at "${GENERATED_AT}" \
  --arg subscription_id "${SUB_ID}" \
  --arg resource_group "${RG}" \
  --arg vault "${VAULT}" \
  --arg vm "${VM_NAME}" \
  --argjson backup_items "${BACKUP_ITEMS}" \
  --argjson backup_jobs "${BACKUP_JOBS}" \
  --argjson defender_for_servers "${DEFENDER_VM}" \
  --argjson secure_score "${SECURE_SCORE}" \
  '{
    evidence_type: "challenge-03-resiliency-protection-evidence",
    module_b_controls: ["B.1.1", "B.2.1", "B.4.2"],
    generated_at: $generated_at,
    subscription_id: $subscription_id,
    resource_group: $resource_group,
    recovery_services_vault: $vault,
    protected_vm: $vm,
    backup: { items: $backup_items, recent_jobs: $backup_jobs },
    defender_for_cloud: { for_servers: $defender_for_servers, secure_score: $secure_score }
  }' > "${OUT_FILE}"

echo "==> Wrote evidence bundle: ${OUT_FILE}"
echo "    Attach this file to your Module B evidence package (controls B.1.1 / B.2.1 / B.4.2)."
