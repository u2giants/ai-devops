---
name: reference_codex_windows_sandbox_fix
description: "Fix for Codex CLI on Windows failing with \"codex-windows-sandbox-setup.exe program not found\" in workspace-write sandbox"
metadata: 
  node_type: memory
  type: reference
  originSessionId: 294695cb-8090-4f57-a06f-1c460336d9df
---

**Symptom:** `codex exec -s workspace-write` (and any sandboxed run) fails instantly — every `shell_command` errors with `windows sandbox: orchestrator_helper_launch_failed: ... helper=codex-windows-sandbox-setup.exe ... error=program not found`. Node REPL / image-viewer helpers fail the same way. Only `--dangerously-bypass-approvals-and-sandbox` (danger-full-access) runs commands, but Claude Code's auto-mode classifier blocks launching that.

**Cause (seen 2026-07-03, Codex 0.142.5):** the helper ships in the release but was never staged into the runtime bin dir. It lives at
`~/.codex/packages/standalone/releases/<ver>-x86_64-pc-windows-msvc/codex-resources/codex-windows-sandbox-setup.exe`
but Codex resolves helpers next to the running `codex.exe` (in `~/.codex/.sandbox-bin/` and `.../current/bin/`), where it was missing (those dirs had `codex.exe` + `codex-command-runner-*.exe` only).

**Fix:** copy the helper into both runtime dirs:
```
cp <release>/codex-resources/codex-windows-sandbox-setup.exe ~/.codex/.sandbox-bin/
cp <release>/codex-resources/codex-windows-sandbox-setup.exe <release>/bin/   # == current/bin, on PATH
```
Then `codex exec -s workspace-write -c sandbox_workspace_write.network_access=true -c approval_policy=never` runs cleanly (network flag needed so Playwright can reach localhost). Verified: staged helper → Codex ran a full Playwright + browser visual pass with 0 "program not found" errors.

Relates to using Codex as an independent verifier alongside [[project_frontend_e2e_local_backend]].
