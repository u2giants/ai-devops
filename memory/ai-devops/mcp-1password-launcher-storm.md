---
name: mcp-1password-launcher-storm
description: "1Password service-account hourly lockout came from a per-launch op-run MCP launcher; fix is the single-flight DPAPI cache in ai-devops. Don't re-add per-launch op run, `--`, or remove Position=0."
metadata: 
  node_type: memory
  type: project
  originSessionId: e4659263-b95e-4450-9ff7-3e4c57a0d576
  modified: 2026-07-23T19:27:23.600Z
---

The shared 1Password **service account** (one account across all 5 machines) was
locked out on 2026-07-23 by a "parallel initialization storm": the deployed MCP
secret launcher (`~/.config/ai-devops/mcp-launch.cmd`, 2026-07-17 version) ran
`op run --env-file=mcp.env` on **every** MCP-server launch, re-resolving ~11
`op://` refs each time × every Claude/Codex window/server/subagent × 5 machines,
overrunning 1Password's **per-hour request cap**.

**Fix (all committed in `u2giants/ai-devops`):**
- `bin/mcp-secret-launch.ps1` resolves all secrets **once** behind a machine-wide
  mutex (`Local\ai-devops-1password-refresh`) and reuses a **15-minute
  DPAPI-encrypted cache** (`mcp-secrets.dpapi.json`). ≤1 refresh/15 min/machine.
- `bin/setup-machine.ps1` generates both `.cmd` launchers and now calls
  `bin/configure-codex-1password.ps1`, which routes Codex's `config.toml`
  `[mcp_servers."1password"]` through the launcher and removes its inline
  plaintext token (preserves the `.tools.*` approval guards).

**Why / How to apply:** the limit is total-requests-per-hour, so the lever is
"resolve once, reuse" (cache) — NOT a concurrency mutex and NOT a shared HTTP
broker (rejected: no new moving parts on 5 machines). Persists to a new machine
because `bin/setup-machine.ps1` generates every machine's launcher + client
configs. After pulling, **re-run `bin/setup-machine.ps1` on each machine** to
deploy — the on-disk `.cmd` can lag the repo (a committed-but-undeployed fix is
not a fix).

**Traps — do not regress:** never restore a per-launch `op run --env-file`; in
`mcp-secret-launch.ps1` keep `$CommandArgs` as
`[Parameter(Position = 0, ValueFromRemainingArguments = $true)]` (forces
`-Url`/`-SecretRef` name-only so a Stdio child's `cmd /c` isn't swallowed); and
keep the generated launchers passing `%*` with **no `--`** (`pwsh -File`
mis-parses `--` as an empty parameter name). Related: [[op-service-account-token-field]],
[[vibe-coding-vault-reprovisioned]]. Full doc:
`docs/mcp-1password-rate-limit-hardening.md`.
