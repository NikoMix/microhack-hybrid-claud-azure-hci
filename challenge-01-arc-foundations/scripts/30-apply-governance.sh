#!/usr/bin/env bash
# Apply governance tags to the Arc-enabled server and trigger an on-demand policy
# compliance scan. Run from Codespaces after the machine shows "Connected".
#
# Usage: ./30-apply-governance.sh <initials> [arc-machine-name]
#   <initials>          short id, e.g. rg-mhb-<initials>
#   [arc-machine-name]  defaults to vm-mhb-<initials>
set -euo pipefail

INITIALS="${1:-}"
if [[ -z "$INITIALS" ]]; then
  echo "Usage: $0 <initials> [arc-machine-name]" >&2
  exit 1
fi
RG="rg-mhb-${INITIALS}"
MACHINE="${2:-vm-mhb-${INITIALS}}"

if ! az account show >/dev/null 2>&1; then
  echo "ERROR: not logged in. Run: az login --use-device-code" >&2
  exit 1
fi

# Resolve the Arc machine resource id (Microsoft.HybridCompute/machines).
RESOURCE_ID="$(az connectedmachine show -g "$RG" -n "$MACHINE" --query id -o tsv 2>/dev/null || true)"
if [[ -z "$RESOURCE_ID" ]]; then
  echo "ERROR: Arc machine '$MACHINE' not found in '$RG'. Onboard it first (20-arc-onboard.sh)." >&2
  exit 1
fi

echo "==> Applying governance tags to $MACHINE"
az resource tag \
  --ids "$RESOURCE_ID" \
  --is-incremental \
  --tags \
  Datacenter=contoso-hq \
  City=Stockholm \
  Workload=three-tier-app \
  Environment=lab \
  CostCenter=CC-1001 \
  ManagedBy=azure-arc \
  ModuleBControl=B.1.1 \
  >/dev/null

echo "==> Triggering an on-demand policy compliance scan for $RG (async)"
az policy state trigger-scan --resource-group "$RG" --no-wait

echo
echo "OK: tags applied. Current inventory:"
az connectedmachine show -g "$RG" -n "$MACHINE" \
  --query '{name:name, status:status, agentVersion:agentVersion, osName:osName, osSku:osSku, tags:tags}' \
  -o json
