#!/usr/bin/env bash
# Shared helpers for the Challenge 04 scripts. Sourced, not executed directly.
# All functions are POSIX-friendly bash and safe under `set -euo pipefail`.

# --- Colour-aware logging -----------------------------------------------------
if [[ -t 1 && -z "${NO_COLOR:-}" ]]; then
  C_RESET=$'\033[0m'; C_GREEN=$'\033[0;32m'; C_YELLOW=$'\033[0;33m'
  C_RED=$'\033[0;31m'; C_BLUE=$'\033[0;34m'
else
  C_RESET=''; C_GREEN=''; C_YELLOW=''; C_RED=''; C_BLUE=''
fi

info() { printf '%s==>%s %s\n' "$C_BLUE" "$C_RESET" "$*"; }
ok()   { printf '  %s✓%s %s\n' "$C_GREEN" "$C_RESET" "$*"; }
warn() { printf '  %s!%s %s\n' "$C_YELLOW" "$C_RESET" "$*" >&2; }
err()  { printf '  %s✗%s %s\n' "$C_RED" "$C_RESET" "$*" >&2; }
die()  { err "$*"; exit 1; }

# --- Guards -------------------------------------------------------------------
require_cmd() {
  local c
  for c in "$@"; do
    command -v "$c" >/dev/null 2>&1 || die "required command not found: '$c'"
  done
}

require_az_login() {
  az account show >/dev/null 2>&1 || die "not logged in to Azure. Run: az login --use-device-code"
}

# Validate the pupil initials used throughout the lab (2–5 lowercase alnum).
validate_initials() {
  [[ "${1:-}" =~ ^[a-z0-9]{2,5}$ ]] ||
    die "initials must be 2–5 lowercase letters/digits (got: '${1:-}')"
}

# Export ARM_SUBSCRIPTION_ID, optionally switching to a provided subscription.
ensure_subscription() {
  local sub="${1:-}"
  if [[ -n "$sub" ]]; then
    az account set --subscription "$sub"
  fi
  if [[ -z "${ARM_SUBSCRIPTION_ID:-}" ]]; then
    ARM_SUBSCRIPTION_ID="$(az account show --query id -o tsv)"
    export ARM_SUBSCRIPTION_ID
  fi
  ok "subscription: ${ARM_SUBSCRIPTION_ID}"
}

# Idempotently register a resource provider and wait until it is Registered.
register_provider() {
  local ns="$1" state tries=0
  state="$(az provider show --namespace "$ns" --query registrationState -o tsv 2>/dev/null || echo Unknown)"
  if [[ "$state" == "Registered" ]]; then
    ok "provider already registered: $ns"
    return 0
  fi
  info "registering provider: $ns"
  az provider register --namespace "$ns" >/dev/null
  while [[ "$state" != "Registered" && "$tries" -lt 30 ]]; do
    sleep 10
    state="$(az provider show --namespace "$ns" --query registrationState -o tsv 2>/dev/null || echo Unknown)"
    tries=$((tries + 1))
  done
  if [[ "$state" == "Registered" ]]; then
    ok "provider registered: $ns"
  else
    warn "provider $ns still '$state' — continuing (it may finish shortly)"
  fi
}

# Idempotently add or upgrade an Azure CLI extension.
ensure_az_extension() {
  local name="$1"
  if az extension show --name "$name" >/dev/null 2>&1; then
    az extension update --name "$name" >/dev/null 2>&1 || true
    ok "az extension ready: $name"
  else
    info "installing az extension: $name"
    az extension add --name "$name" >/dev/null
    ok "az extension installed: $name"
  fi
}

# Default resource names derived from initials (kept in one place).
rg_name()      { printf 'rg-mhb-%s' "$1"; }
cluster_name() { printf 'arck8s-mhb-%s-04' "$1"; }
flux_name()    { printf 'gitops-mhb-%s-04' "$1"; }
workspace_name() { printf 'log-mhb-%s' "$1"; }
