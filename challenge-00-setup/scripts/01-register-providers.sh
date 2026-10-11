#!/usr/bin/env bash
# Register the Azure resource providers used across the microhack.
# Idempotent: registering an already-registered provider is a no-op.
set -euo pipefail

if ! az account show >/dev/null 2>&1; then
  echo "ERROR: not logged in. Run: az login --use-device-code" >&2
  exit 1
fi

# Providers needed by challenges 00–06.
PROVIDERS=(
  Microsoft.HybridCompute        # Arc-enabled servers (Connected Machine)
  Microsoft.GuestConfiguration   # Azure Policy guest configuration
  Microsoft.HybridConnectivity   # Arc SSH / connectivity
  Microsoft.AzureArcData          # Arc data services
  Microsoft.Kubernetes            # Arc-enabled Kubernetes
  Microsoft.KubernetesConfiguration # Flux GitOps + extensions
  Microsoft.ExtendedLocation      # custom locations
  Microsoft.Insights              # Azure Monitor / alerts
  Microsoft.OperationalInsights   # Log Analytics
  Microsoft.RecoveryServices      # Backup + Site Recovery
  Microsoft.Security              # Defender for Cloud
  Microsoft.Maintenance           # Azure Update Manager
  Microsoft.Compute
  Microsoft.Network
  Microsoft.ManagedIdentity
)

echo "==> Registering ${#PROVIDERS[@]} resource providers (async)..."
for p in "${PROVIDERS[@]}"; do
  state="$(az provider show --namespace "$p" --query registrationState -o tsv 2>/dev/null || echo 'NotFound')"
  if [[ "$state" == "Registered" ]]; then
    printf '  ✓ %s already registered\n' "$p"
  else
    az provider register --namespace "$p" >/dev/null
    printf '  → %s registering...\n' "$p"
  fi
done

echo
echo "==> Registration is asynchronous. Check progress with:"
echo "    az provider list --query \"[?registrationState=='Registering'].namespace\" -o tsv"
echo "All providers will reach 'Registered' within a few minutes; you can continue meanwhile."
