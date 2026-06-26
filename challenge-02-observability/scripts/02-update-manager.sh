#!/usr/bin/env bash
# Run an Azure Update Manager assessment (and optionally one on-demand patch
# deployment) against a hybrid machine — Azure VM or Arc-enabled server.
#
# Usage: ./02-update-manager.sh <machine-resource-id> [--install]
#   <machine-resource-id>  resource ID of the target machine, e.g.
#       /subscriptions/<sub>/resourceGroups/rg-mhb-<initials>/providers/Microsoft.HybridCompute/machines/<name>
#       /subscriptions/<sub>/resourceGroups/rg-mhb-<initials>/providers/Microsoft.Compute/virtualMachines/<name>
#   --install              also deploy Critical+Security patches (reboot IfRequired).
#
# Safe by default: without --install it only ASSESSES (read-only).
set -euo pipefail

MACHINE_ID="${1:-}"
INSTALL="false"

if [[ "${2:-}" == "--install" ]]; then
  INSTALL="true"
fi

if [[ -z "$MACHINE_ID" ]]; then
  echo "Usage: $0 <machine-resource-id> [--install]" >&2
  exit 1
fi

if ! az account show >/dev/null 2>&1; then
  echo "ERROR: not logged in. Run: az login --use-device-code" >&2
  exit 1
fi

API_VERSION="2024-07-10"
MGMT="https://management.azure.com"

# Detect the machine type from its resource ID (case-insensitive).
shopt -s nocasematch
if [[ "$MACHINE_ID" == *"/providers/Microsoft.HybridCompute/machines/"* ]]; then
  KIND="arc"
elif [[ "$MACHINE_ID" == *"/providers/Microsoft.Compute/virtualMachines/"* ]]; then
  KIND="vm"
else
  echo "ERROR: unrecognized resource ID. Expected Microsoft.HybridCompute/machines" >&2
  echo "       or Microsoft.Compute/virtualMachines." >&2
  exit 1
fi
shopt -u nocasematch

# Derive resource group and machine name from the ID for the CLI fast paths.
RG="$(sed -n 's#.*/resourceGroups/\([^/]*\)/.*#\1#p' <<<"$MACHINE_ID")"
NAME="${MACHINE_ID##*/}"

echo "==> Target: ${NAME} (${KIND}) in resource group ${RG}"

echo "==> Running update assessment (read-only)..."
if [[ "$KIND" == "vm" ]]; then
  az vm assess-patches --resource-group "$RG" --name "$NAME" -o table
else
  az rest --method post \
    --url "${MGMT}${MACHINE_ID}/assessPatches?api-version=${API_VERSION}" \
    --query "{status:status, critical:availablePatchCountByClassification.critical, security:availablePatchCountByClassification.security, other:availablePatchCountByClassification.other}" \
    -o table
fi

if [[ "$INSTALL" != "true" ]]; then
  echo
  echo "Assessment complete. Re-run with --install to deploy Critical+Security patches."
  exit 0
fi

echo
echo "==> WARNING: installing Critical+Security patches (reboot IfRequired)."
echo "    This may reboot ${NAME}. Press Ctrl+C within 10s to abort."
sleep 10

if [[ "$KIND" == "vm" ]]; then
  az vm install-patches --resource-group "$RG" --name "$NAME" \
    --maximum-duration PT2H --reboot-setting IfRequired \
    --classifications-to-include-linux Critical Security -o table
else
  az rest --method post \
    --url "${MGMT}${MACHINE_ID}/installPatches?api-version=${API_VERSION}" \
    --body '{"maximumDuration":"PT2H","rebootSetting":"IfRequired","linuxParameters":{"classificationsToInclude":["Critical","Security"]}}' \
    --query "{status:status, installed:installedPatchCount, failed:failedPatchCount, reboot:rebootStatus}" \
    -o table
fi

echo
echo "==> Patch deployment submitted. Review results in Azure Update Manager."
