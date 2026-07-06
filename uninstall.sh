#!/usr/bin/env bash
# uninstall.sh — remove this toolkit's symlinks (and optionally config/repo).
#
#   - Removes /usr/local/bin symlinks that point into this repo's bin/.
#   - Keeps /etc/ai-devops unless --purge is passed.
#   - Never deletes Claude/Codex auth files or login state.
#   - Keeps /worksp/ai-devops unless --remove-repo is passed.
#
# Usage:
#   ./uninstall.sh                 # remove symlinks only
#   ./uninstall.sh --purge         # also remove /etc/ai-devops (config)
#   ./uninstall.sh --remove-repo   # also remove /worksp/ai-devops checkout

set -uo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ETC_DIR="/etc/ai-devops"
BIN_TARGET="/usr/local/bin"

PURGE=0
REMOVE_REPO=0
for arg in "$@"; do
  case "$arg" in
    --purge) PURGE=1 ;;
    --remove-repo) REMOVE_REPO=1 ;;
    -h|--help)
      grep '^#' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "Unknown flag: $arg" >&2; exit 2 ;;
  esac
done

info() { printf '\033[1m==>\033[0m %s\n' "$1"; }
warn() { printf '\033[33m[WARN]\033[0m %s\n' "$1"; }

SUDO=""
if [ "$(id -u)" -ne 0 ] && command -v sudo >/dev/null 2>&1; then
  SUDO="sudo"
fi

# --- Remove symlinks that point into this repo's bin/ ----------------------
info "Removing symlinks in $BIN_TARGET that point into $REPO_ROOT/bin"
for src in "$REPO_ROOT"/bin/*; do
  [ -e "$src" ] || continue
  name="$(basename "$src")"
  dest="$BIN_TARGET/$name"
  if [ -L "$dest" ]; then
    target="$(readlink -f "$dest" 2>/dev/null || true)"
    if [ "$target" = "$(readlink -f "$src")" ]; then
      $SUDO rm -f "$dest"
      info "  removed $dest"
    else
      warn "  $dest points elsewhere ($target); leaving it"
    fi
  fi
done

# --- Config (only with --purge) --------------------------------------------
if [ "$PURGE" -eq 1 ]; then
  warn "--purge: removing $ETC_DIR (config)"
  $SUDO rm -rf "$ETC_DIR"
else
  info "Keeping $ETC_DIR (pass --purge to remove config)"
fi

# --- Auth files: NEVER touched ---------------------------------------------
info "Leaving Claude/Codex/gh auth and login state untouched (never removed)."

# --- Repo checkout (only with --remove-repo) -------------------------------
if [ "$REMOVE_REPO" -eq 1 ]; then
  warn "--remove-repo: removing $REPO_ROOT"
  # cd out first so we don't rm the CWD from under ourselves.
  cd / || true
  $SUDO rm -rf "$REPO_ROOT"
else
  info "Keeping $REPO_ROOT (pass --remove-repo to delete the checkout)"
fi

info "uninstall.sh complete."
