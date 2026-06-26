#!/usr/bin/env bash
# Reset Challenge 01 between cohorts. Removes the cloud-side artifacts created by
# the CLI scripts: the Azure Arc machine resource and the onboarding service
# principal. The guest-configuration policy assignment is Terraform-managed, and
# the on-VM IMDS block / agent are cleared on the server itself (see the printed
# steps). Run from Codespaces.
#
# Usage: ./90-reset.sh <initials> [arc-machine-name]
set -euo pipefail

INITIALS="${1:-}"
if [[ -z "$INITIALS" ]]; then
  echo "Usage: $0 <initials> [arc-machine-name]" >&2
  exit 1
fi
RG="rg-mhb-${INITIALS}"
MACHINE="${2:-vm-mhb-${INITIALS}}"
SP_NAME="sp-arc-onboard-mhb-${INITIALS}-01"

if ! az account show >/dev/null 2>&1; then
  echo "ERROR: not logged in. Run: az login --use-device-code" >&2
  exit 1
fi

echo "==> Removing Azure Arc machine resource (if present): $MACHINE"
if az connectedmachine show -g "$RG" -n "$MACHINE" >/dev/null 2>&1; then
  az connectedmachine delete -g "$RG" -n "$MACHINE" --yes
  echo "  removed $MACHINE"
else
  echo "  (no Arc machine to delete)"
fi

echo "==> Removing the onboarding service principal (if present): $SP_NAME"
APP_ID="$(az ad sp list --display-name "$SP_NAME" --query '[0].appId' -o tsv 2>/dev/null || true)"
if [[ -n "$APP_ID" ]]; then
  az ad sp delete --id "$APP_ID"
  echo "  removed $SP_NAME"
else
  echo "  (no service principal to delete)"
fi

cat <<EOF

Remaining reset steps:
  1. Remove the guest-configuration policy assignment (Terraform-managed):
       terraform -chdir=challenge-01-arc-foundations/infra destroy
  2. On the server-to-migrate (over SSH), disconnect the agent and clear the block:
       sudo azcmagent disconnect --force-local-only || true
       sudo ./10-imds-guard.sh unblock
EOF
