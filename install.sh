#!/usr/bin/env bash
# install.sh — install / verify the AI DevOps toolkit on this machine.
#
# What it does:
#   - Verifies (and, where possible via apt, installs) base dependencies.
#   - Creates /etc/ai-devops and /var/log/ai-devops.
#   - Copies config/*.env.example into /etc/ai-devops ONLY if the real file
#     does not already exist (never overwrites real config).
#   - Symlinks bin/* into /usr/local/bin.
#   - Runs `ai-devops doctor` at the end.
#
# Safe to re-run (idempotent). Uses sudo for system paths.

set -uo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ETC_DIR="/etc/ai-devops"
LOG_DIR="/var/log/ai-devops"
BIN_TARGET="/usr/local/bin"

info() { printf '\033[1m==>\033[0m %s\n' "$1"; }
warn() { printf '\033[33m[WARN]\033[0m %s\n' "$1"; }

# Pick a sudo prefix only if we are not already root.
SUDO=""
if [ "$(id -u)" -ne 0 ]; then
  if command -v sudo >/dev/null 2>&1; then
    SUDO="sudo"
  else
    warn "Not root and sudo not found; system-path steps may fail."
  fi
fi

# --------------------------------------------------------------------------
# 1. Dependencies
# --------------------------------------------------------------------------
info "Checking dependencies"
APT_PKGS=(git curl jq ripgrep unzip python3 python3-pip)
# nodejs/npm added only if apt can provide them (some servers use nvm instead).
MISSING=()
for bin in git curl jq rg unzip python3 pip3; do
  command -v "$bin" >/dev/null 2>&1 || MISSING+=("$bin")
done

if [ "${#MISSING[@]}" -gt 0 ]; then
  info "Attempting to install missing packages via apt: ${MISSING[*]}"
  if command -v apt-get >/dev/null 2>&1; then
    $SUDO apt-get update -y || warn "apt-get update failed; continuing"
    $SUDO apt-get install -y "${APT_PKGS[@]}" || warn "apt-get install failed for some packages"
    # node/npm are best-effort via apt.
    $SUDO apt-get install -y nodejs npm || warn "nodejs/npm not installed via apt (nvm/other is fine)"
  else
    warn "apt-get not available; install these manually: ${MISSING[*]}"
  fi
else
  info "All base dependencies present"
fi

# gh is required but is not always in apt; verify and instruct if missing.
if ! command -v gh >/dev/null 2>&1; then
  warn "GitHub CLI (gh) not found. Install: https://github.com/cli/cli#installation"
fi

# --------------------------------------------------------------------------
# 2. System directories
# --------------------------------------------------------------------------
info "Creating $ETC_DIR and $LOG_DIR"
$SUDO mkdir -p "$ETC_DIR" "$LOG_DIR"

# --------------------------------------------------------------------------
# 3. Config files (never overwrite real config)
# --------------------------------------------------------------------------
install_config() {
  local example="$1" dest="$2"
  if [ -f "$dest" ]; then
    info "Keeping existing $dest (not overwritten)"
  else
    info "Installing $dest from example"
    $SUDO cp "$example" "$dest"
  fi
}
install_config "$REPO_ROOT/config/models.env.example" "$ETC_DIR/models.env"
install_config "$REPO_ROOT/config/server.env.example" "$ETC_DIR/server.env"

# --------------------------------------------------------------------------
# 4. Symlink bin/* into /usr/local/bin
# --------------------------------------------------------------------------
info "Symlinking scripts into $BIN_TARGET"
chmod +x "$REPO_ROOT"/bin/* 2>/dev/null || true
for src in "$REPO_ROOT"/bin/*; do
  [ -f "$src" ] || continue
  name="$(basename "$src")"
  dest="$BIN_TARGET/$name"
  # Only replace if missing or already points into this repo.
  if [ -L "$dest" ] || [ ! -e "$dest" ]; then
    $SUDO ln -sfn "$src" "$dest"
    info "  linked $name"
  else
    warn "  $dest exists and is not a symlink; leaving it untouched"
  fi
done

# --------------------------------------------------------------------------
# 5. Doctor
# --------------------------------------------------------------------------
info "Running ai-devops doctor"
echo
if command -v ai-devops >/dev/null 2>&1; then
  ai-devops doctor || true
else
  "$REPO_ROOT/bin/ai-devops" doctor || true
fi

echo
info "install.sh complete."
