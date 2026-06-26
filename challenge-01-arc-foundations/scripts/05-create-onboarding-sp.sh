#!/usr/bin/env bash
# Create (or reuse) a least-privilege service principal for Azure Arc onboarding,
# scoped to the lab resource group with the "Azure Connected Machine Onboarding"
# role. The secret is printed ONCE to stdout — copy it to the VM session; never
# commit it. Run from Codespaces.
#
# Usage: ./05-create-onboarding-sp.sh <initials> [location]
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

SUBSCRIPTION_ID="$(az account show --query id -o tsv)"
TENANT_ID="$(az account show --query tenantId -o tsv)"
RG="rg-mhb-${INITIALS}"
SP_NAME="sp-arc-onboard-mhb-${INITIALS}-01"
SCOPE="/subscriptions/${SUBSCRIPTION_ID}/resourceGroups/${RG}"
ROLE="Azure Connected Machine Onboarding"

if ! az group show --name "$RG" >/dev/null 2>&1; then
  echo "ERROR: resource group '$RG' not found. Deploy the base environment first." >&2
  exit 1
fi

# Reuse an existing app registration if present (idempotent) and reset its secret.
APP_ID="$(az ad sp list --display-name "$SP_NAME" --query '[0].appId' -o tsv 2>/dev/null || true)"

if [[ -n "$APP_ID" ]]; then
  echo "==> Reusing existing service principal '$SP_NAME' ($APP_ID); resetting credential." >&2
  SECRET="$(az ad sp credential reset --id "$APP_ID" --query password -o tsv)"
else
  echo "==> Creating service principal '$SP_NAME' scoped to $SCOPE" >&2
  CREATE_JSON="$(az ad sp create-for-rbac \
    --name "$SP_NAME" \
    --role "$ROLE" \
    --scopes "$SCOPE" \
    -o json)"
  APP_ID="$(echo "$CREATE_JSON" | jq -r '.appId')"
  SECRET="$(echo "$CREATE_JSON" | jq -r '.password')"
fi

# Print the exports on stdout so they can be piped or copied. The secret appears
# only here — it cannot be retrieved again.
cat <<EOF

# ---------------------------------------------------------------------------
# Copy these exports into the SSH session on the server-to-migrate, then run
# 20-arc-onboard.sh. The service principal is used ONLY for onboarding.
# ---------------------------------------------------------------------------
export ARC_SUBSCRIPTION_ID="${SUBSCRIPTION_ID}"
export ARC_TENANT_ID="${TENANT_ID}"
export ARC_RESOURCE_GROUP="${RG}"
export ARC_LOCATION="${LOCATION}"
export ARC_SP_APP_ID="${APP_ID}"
export ARC_SP_SECRET="${SECRET}"
EOF
