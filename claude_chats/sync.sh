#!/usr/bin/env bash
#
# Back up local Claude Code session transcripts into this repo.
#
# Copies ~/.claude/projects/ into claude_chats/<machine>/, then commits and
# pushes anything new or changed. Safe to run repeatedly (idempotent).
#
# Usage:
#   ./claude_chats/sync.sh            # machine name = short hostname
#   ./claude_chats/sync.sh hetz       # explicit machine name
#
set -euo pipefail

MACHINE="${1:-$(hostname -s)}"
SRC="${HOME}/.claude/projects"
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEST="${REPO_ROOT}/claude_chats/${MACHINE}"

if [[ ! -d "$SRC" ]]; then
  echo "No Claude Code projects dir found at $SRC — nothing to sync." >&2
  exit 1
fi

echo "Syncing ${SRC}/ -> claude_chats/${MACHINE}/"
mkdir -p "$DEST"

# Mirror the projects tree. --delete keeps the backup faithful to the source
# (sessions deleted locally are removed from the backup too). Drop --delete
# if you'd rather the archive only ever grow.
if command -v rsync >/dev/null 2>&1; then
  rsync -a --delete "${SRC}/" "${DEST}/"
else
  rm -rf "${DEST:?}/"* 2>/dev/null || true
  cp -a "${SRC}/." "${DEST}/"
fi

cd "$REPO_ROOT"
git add "claude_chats/${MACHINE}"

if git diff --cached --quiet; then
  echo "No changes — backup already up to date."
  exit 0
fi

COUNT=$(find "$DEST" -name '*.jsonl' | wc -l | tr -d ' ')
git commit -q -m "Sync Claude Code transcripts (${MACHINE}): ${COUNT} sessions"
git pull --rebase origin "$(git rev-parse --abbrev-ref HEAD)" >/dev/null 2>&1 || true
git push
echo "Done. ${COUNT} sessions backed up for ${MACHINE}."
