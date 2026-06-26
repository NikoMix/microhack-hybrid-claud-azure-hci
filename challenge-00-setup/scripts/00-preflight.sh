#!/usr/bin/env bash
# Pre-flight check: verify the lab toolchain is present and Azure auth is ready.
# Idempotent and read-only. Safe to run repeatedly.
set -euo pipefail

ok()   { printf '  \033[0;32m✓\033[0m %s\n' "$1"; }
warn() { printf '  \033[0;33m!\033[0m %s\n' "$1"; }
miss() { printf '  \033[0;31m✗\033[0m %s\n' "$1"; }

check() {
  local name="$1" cmd="$2"
  if command -v "$cmd" >/dev/null 2>&1; then
    ok "$name ($(command -v "$cmd"))"
  else
    miss "$name not found — expected from the devcontainer"
    MISSING=$((MISSING + 1))
  fi
}

MISSING=0

echo "==> Required tooling"
check "Azure CLI"   az
check "Terraform"   terraform
check "tflint"      tflint
check "kubectl"     kubectl
check "helm"        helm
check "GitHub CLI"  gh
check "jq"          jq

echo "==> Capstone tooling (optional but recommended)"
for tool in flux copilot task pre-commit checkov; do
  if command -v "$tool" >/dev/null 2>&1; then ok "$tool"; else warn "$tool not found (install via .devcontainer/post-create.sh)"; fi
done

echo "==> Azure authentication"
if az account show >/dev/null 2>&1; then
  sub_name="$(az account show --query name -o tsv)"
  sub_id="$(az account show --query id -o tsv)"
  ok "Logged in to: ${sub_name} (${sub_id})"
  if [[ "${ARM_SUBSCRIPTION_ID:-}" == "$sub_id" ]]; then
    ok "ARM_SUBSCRIPTION_ID is exported and matches"
  else
    warn "ARM_SUBSCRIPTION_ID not set — run: export ARM_SUBSCRIPTION_ID=\$(az account show --query id -o tsv)"
  fi
else
  warn "Not logged in — run: az login --use-device-code"
fi

echo
if [[ "$MISSING" -eq 0 ]]; then
  ok "Pre-flight complete — you're ready for the base deployment."
else
  miss "$MISSING required tool(s) missing. Re-run: bash .devcontainer/post-create.sh"
  exit 1
fi
