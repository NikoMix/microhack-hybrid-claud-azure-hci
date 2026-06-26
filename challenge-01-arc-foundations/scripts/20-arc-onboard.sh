#!/usr/bin/env bash
# Install the Azure Connected Machine agent and onboard this server to Azure Arc.
# Run this ON the server-to-migrate (over SSH) as root, AFTER blocking IMDS with
# 10-imds-guard.sh block.
#
# Required environment (from 05-create-onboarding-sp.sh):
#   ARC_SUBSCRIPTION_ID ARC_TENANT_ID ARC_RESOURCE_GROUP ARC_LOCATION
#   ARC_SP_APP_ID ARC_SP_SECRET
# Optional:
#   ARC_TAGS            comma-separated key=value pairs (governance tags)
#   ARC_CORRELATION_ID  onboarding correlation id (defaults to a random UUID)
#
# Usage: sudo -E ./20-arc-onboard.sh      # -E preserves the ARC_* environment
set -euo pipefail

require_env() {
  local name="$1"
  if [[ -z "${!name:-}" ]]; then
    echo "ERROR: \$$name is required (run 05-create-onboarding-sp.sh and export its output)." >&2
    exit 1
  fi
}
for v in ARC_SUBSCRIPTION_ID ARC_TENANT_ID ARC_RESOURCE_GROUP ARC_LOCATION ARC_SP_APP_ID ARC_SP_SECRET; do
  require_env "$v"
done

if [[ "$(id -u)" -ne 0 ]]; then
  echo "ERROR: run as root (use 'sudo -E' to preserve the ARC_* environment)." >&2
  exit 1
fi

ARC_TAGS="${ARC_TAGS:-Datacenter=contoso-hq,City=Stockholm,Workload=three-tier-app,Environment=lab,ManagedBy=azure-arc,ModuleBControl=B.1.1}"
ARC_CORRELATION_ID="${ARC_CORRELATION_ID:-$(cat /proc/sys/kernel/random/uuid)}"

# 1. Install the agent if it is not already present (idempotent).
if ! command -v azcmagent >/dev/null 2>&1; then
  echo "==> Installing the Connected Machine agent (azcmagent)..."
  curl -fsSL https://aka.ms/azcmagent -o /tmp/install_linux_azcmagent.sh
  bash /tmp/install_linux_azcmagent.sh
else
  echo "OK: azcmagent already installed."
fi

# 2. Skip if the machine is already connected (idempotent).
if azcmagent show 2>/dev/null | grep -qw "Connected"; then
  echo "OK: already connected to Azure Arc; nothing to do."
  azcmagent show
  exit 0
fi

# 3. Connect using the least-privilege onboarding service principal.
echo "==> Connecting to Azure Arc (resource group: $ARC_RESOURCE_GROUP)..."
azcmagent connect \
  --service-principal-id "$ARC_SP_APP_ID" \
  --service-principal-secret "$ARC_SP_SECRET" \
  --tenant-id "$ARC_TENANT_ID" \
  --subscription-id "$ARC_SUBSCRIPTION_ID" \
  --resource-group "$ARC_RESOURCE_GROUP" \
  --location "$ARC_LOCATION" \
  --cloud "AzureCloud" \
  --tags "$ARC_TAGS" \
  --correlation-id "$ARC_CORRELATION_ID"

echo
echo "==> Connected. Agent status:"
azcmagent show
