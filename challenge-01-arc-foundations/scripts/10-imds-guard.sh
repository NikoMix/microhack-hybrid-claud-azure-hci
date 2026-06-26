#!/usr/bin/env bash
# LAB-ONLY: guard the Azure Instance Metadata Service (IMDS) endpoint so this Azure
# VM presents as an off-Azure machine and can be onboarded to Azure Arc for
# evaluation. Run this ON the server-to-migrate (over SSH) as root — NOT from
# Codespaces.
#
# Why: the Connected Machine agent refuses to onboard a machine that IMDS reports
# as already running in Azure. Blocking 169.254.169.254 makes the agent treat the
# VM like an on-premises server. This is purely an evaluation technique; production
# Arc onboards genuinely off-Azure machines and never needs this.
#
# Usage: sudo ./10-imds-guard.sh [block|unblock|status]
set -euo pipefail

ACTION="${1:-block}"
IMDS_IP="169.254.169.254"

if [[ "$(id -u)" -ne 0 ]]; then
  echo "ERROR: run as root (use sudo)." >&2
  exit 1
fi

# Identical rule spec for check / insert / delete so the operation is idempotent.
rule_present() {
  iptables -C OUTPUT -d "$IMDS_IP" -j DROP 2>/dev/null
}

case "$ACTION" in
  block)
    if rule_present; then
      echo "OK: IMDS already blocked ($IMDS_IP)."
    else
      # Insert at the top so the DROP wins over any earlier ACCEPT-all rule.
      iptables -I OUTPUT 1 -d "$IMDS_IP" -j DROP
      echo "OK: blocked outbound traffic to IMDS ($IMDS_IP)."
    fi
    echo "Verify (this should fail/time out):"
    echo "  curl -s -m 3 -H 'Metadata:true' 'http://169.254.169.254/metadata/instance?api-version=2021-02-01' || echo 'IMDS unreachable (expected)'"
    echo
    echo "NOTE: this iptables rule is not persisted across reboot (by design)."
    echo "      Run the Arc onboarding in the same session, then 'unblock' to reset."
    ;;
  unblock)
    # Remove every matching rule (idempotent).
    while rule_present; do
      iptables -D OUTPUT -d "$IMDS_IP" -j DROP
    done
    echo "OK: removed the IMDS block; the VM can reach Azure IMDS again."
    ;;
  status)
    if rule_present; then
      echo "IMDS is BLOCKED ($IMDS_IP)."
    else
      echo "IMDS is reachable (not blocked)."
    fi
    ;;
  *)
    echo "Usage: sudo $0 [block|unblock|status]" >&2
    exit 1
    ;;
esac
