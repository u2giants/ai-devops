#!/usr/bin/env bash
# update.sh — pull the latest toolkit and re-install.
#
#   - git pull (fast-forward) inside /worksp/ai-devops
#   - re-run install.sh
#   - never overwrites /etc/ai-devops/*.env (install.sh handles that)

set -uo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
info() { printf '\033[1m==>\033[0m %s\n' "$1"; }
warn() { printf '\033[33m[WARN]\033[0m %s\n' "$1"; }

cd "$REPO_ROOT" || { echo "Cannot cd to $REPO_ROOT" >&2; exit 1; }

if [ -d .git ]; then
  info "Pulling latest changes in $REPO_ROOT"
  if ! git pull --ff-only; then
    warn "git pull --ff-only failed (local changes or diverged history)."
    warn "Resolve manually, then re-run ./update.sh"
    exit 1
  fi
else
  warn "$REPO_ROOT is not a git checkout; skipping pull."
fi

info "Re-running install.sh"
exec "$REPO_ROOT/install.sh"
