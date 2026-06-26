#!/usr/bin/env bash
# Post-create bootstrap for the Azure Local Module B microhack devcontainer.
# Installs the open-source (license-free) toolchain used across the labs.
# Every install is best-effort so a single transient failure never blocks the
# Codespace from starting; re-run with `bash .devcontainer/post-create.sh`.
set -uo pipefail

log()  { printf '\n\033[1;36m▶ %s\033[0m\n' "$*"; }
warn() { printf '\033[1;33m⚠ %s\033[0m\n' "$*"; }
ok()   { printf '\033[1;32m✓ %s\033[0m\n' "$*"; }

BIN_DIR="/usr/local/bin"

log "Updating apt and installing base utilities"
sudo apt-get update -y >/dev/null 2>&1 || warn "apt-get update failed"
sudo apt-get install -y --no-install-recommends shellcheck jq unzip >/dev/null 2>&1 \
  && ok "shellcheck, jq, unzip installed" || warn "apt packages failed"

install_task() {
  log "Installing go-task (Taskfile runner)"
  sh -c "$(curl -fsSL https://taskfile.dev/install.sh)" -- -d -b "$BIN_DIR" >/dev/null 2>&1 \
    && ok "task installed: $(task --version 2>/dev/null)" || warn "task install failed"
}

install_flux() {
  log "Installing Flux CLI (GitOps)"
  curl -fsSL https://fluxcd.io/install.sh | sudo bash >/dev/null 2>&1 \
    && ok "flux installed: $(flux --version 2>/dev/null)" || warn "flux install failed"
}

install_gitleaks() {
  log "Installing gitleaks (secret scanning)"
  local ver tarball
  ver="$(curl -fsSL https://api.github.com/repos/gitleaks/gitleaks/releases/latest | jq -r .tag_name 2>/dev/null)"
  ver="${ver:-v8.21.2}"
  tarball="gitleaks_${ver#v}_linux_x64.tar.gz"
  if curl -fsSL "https://github.com/gitleaks/gitleaks/releases/download/${ver}/${tarball}" -o /tmp/gl.tgz 2>/dev/null; then
    sudo tar -xzf /tmp/gl.tgz -C "$BIN_DIR" gitleaks 2>/dev/null && ok "gitleaks $ver installed" || warn "gitleaks extract failed"
  else
    warn "gitleaks download failed"
  fi
}

install_actionlint() {
  log "Installing actionlint (workflow linter)"
  bash <(curl -fsSL https://raw.githubusercontent.com/rhysd/actionlint/main/scripts/download-actionlint.bash) >/dev/null 2>&1 \
    && sudo mv ./actionlint "$BIN_DIR/" 2>/dev/null && ok "actionlint installed" || warn "actionlint install failed"
}

install_lychee() {
  log "Installing lychee (link checker)"
  local url
  url="https://github.com/lycheeverse/lychee/releases/latest/download/lychee-x86_64-unknown-linux-gnu.tar.gz"
  if curl -fsSL "$url" -o /tmp/lychee.tgz 2>/dev/null; then
    sudo tar -xzf /tmp/lychee.tgz -C "$BIN_DIR" lychee 2>/dev/null && ok "lychee installed" || warn "lychee extract failed"
  else
    warn "lychee download failed"
  fi
}

install_python_tools() {
  log "Installing Python quality tools (checkov, pre-commit) via pipx"
  python3 -m pip install --user --quiet pipx >/dev/null 2>&1 || warn "pipx bootstrap failed"
  python3 -m pipx ensurepath >/dev/null 2>&1 || true
  export PATH="$HOME/.local/bin:$PATH"
  pipx install checkov >/dev/null 2>&1 && ok "checkov installed" || warn "checkov install failed"
  pipx install pre-commit >/dev/null 2>&1 && ok "pre-commit installed" || warn "pre-commit install failed"
}

install_node_tools() {
  log "Installing Node CLI tools (markdownlint-cli2, GitHub Copilot CLI)"
  npm install -g markdownlint-cli2 >/dev/null 2>&1 && ok "markdownlint-cli2 installed" || warn "markdownlint-cli2 failed"
  npm install -g @github/copilot >/dev/null 2>&1 && ok "GitHub Copilot CLI installed" || warn "Copilot CLI install failed (run 'npm i -g @github/copilot' later)"
}

register_hooks() {
  if command -v pre-commit >/dev/null 2>&1; then
    log "Installing git pre-commit hooks"
    pre-commit install >/dev/null 2>&1 && ok "pre-commit hooks installed" || warn "pre-commit install hook failed"
  fi
}

install_task
install_flux
install_gitleaks
install_actionlint
install_lychee
install_python_tools
install_node_tools
register_hooks

log "Toolchain summary"
{
  printf 'az:          %s\n' "$(az version --query '\"azure-cli\"' -o tsv 2>/dev/null || echo missing)"
  printf 'terraform:   %s\n' "$(terraform version -json 2>/dev/null | jq -r .terraform_version 2>/dev/null || echo missing)"
  printf 'tflint:      %s\n' "$(tflint --version 2>/dev/null | head -1 || echo missing)"
  printf 'kubectl:     %s\n' "$(kubectl version --client -o json 2>/dev/null | jq -r .clientVersion.gitVersion 2>/dev/null || echo missing)"
  printf 'helm:        %s\n' "$(helm version --short 2>/dev/null || echo missing)"
  printf 'flux:        %s\n' "$(flux --version 2>/dev/null || echo missing)"
  printf 'task:        %s\n' "$(task --version 2>/dev/null || echo missing)"
  printf 'checkov:     %s\n' "$(checkov --version 2>/dev/null || echo missing)"
  printf 'gh:          %s\n' "$(gh --version 2>/dev/null | head -1 || echo missing)"
} || true

cat <<'EOF'

╭───────────────────────────────────────────────────────────────╮
│  Devcontainer ready.  Next steps:                             │
│   1.  az login --use-device-code                              │
│   2.  cd challenge-00-setup  &&  follow README.md             │
│   3.  Open Copilot Chat → pick a custom agent (Agents view)   │
╰───────────────────────────────────────────────────────────────╯
EOF
