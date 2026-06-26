#!/usr/bin/env bash
# Register the Azure resource providers required to Arc-enable a server and to run
# guest-configuration Azure Policy. Idempotent: re-registering is a no-op.
# Run from Codespaces (or anywhere with Azure CLI signed in).
# Usage: ./00-register-providers.sh
set -euo pipefail

if ! az account show >/dev/null 2>&1; then
  echo "ERROR: not logged in. Run: az login --use-device-code" >&2
  exit 1
fi

# Providers used by Challenge 01 (Arc onboarding + guest configuration + policy state).
PROVIDERS=(
  Microsoft.HybridCompute        # Arc-enabled servers (Connected Machine)
  Microsoft.GuestConfiguration   # Azure Policy guest configuration / machine config
  Microsoft.HybridConnectivity   # Arc SSH and connectivity
  Microsoft.PolicyInsights       # On-demand policy compliance scans
)

echo "==> Registering ${#PROVIDERS[@]} resource providers (async)..."
for p in "${PROVIDERS[@]}"; do
  state="$(az provider show --namespace "$p" --query registrationState -o tsv 2>/dev/null || echo 'NotFound')"
  if [[ "$state" == "Registered" ]]; then
    printf '  \xe2\x9c\x93 %s already registered\n' "$p"
  else
    az provider register --namespace "$p" >/dev/null
    printf '  \xe2\x86\x92 %s registering...\n' "$p"
  fi
done

echo
echo "Registration is asynchronous. Check progress with:"
echo "  az provider show --namespace Microsoft.HybridCompute --query registrationState -o tsv"
