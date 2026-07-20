---
name: op-run-mcp-wsl-env-trap
description: "op_run works fully; on Windows bare bash = WSL which drops injected env. Since v2.6.0 the tool rejects bare bash and refuses WSL+secrets before running"
metadata:
  node_type: memory
  type: reference
  originSessionId: 47a8c8ae-99f1-484c-be31-03be46cf4f10
---

`mcp__1password__op_run` is NOT broken (an earlier session wrongly concluded it was). Its `env` map,
`op://` resolution, `stdin`, `cwd`, and stdout **redaction** (`«REDACTED:NAME»`) all work.

**The trap:** on Windows, `bash` resolves via PATH to **WSL** bash (a child's `pwd` returns
`/mnt/c/…`). WSL starts an isolated Linux env that does NOT inherit the Windows process environment
(no WSLENV forwarding), so injected vars/secrets are empty *inside WSL* — which looks exactly like
"env is broken." It isn't. **Debugging lesson: an empty result is not proof a tool is broken —
establish platform / resolved executable / shell / cwd / env-boundary BEFORE blaming the tool.**

**Since v2.6.0 (released 2026-07-16) the tool guards this itself:**
- bare `shell:"bash"`/`"sh"` on Windows → **rejected** ("Ambiguous shell ... may resolve to WSL").
- WSL target + a resolved `op://` secret → **refused before spawning** (would otherwise run
  de-authenticated). Override with `allowMissingSecretsInWsl:true` or `forwardEnvToWsl:true`.
- Every result now returns diagnostics: `executionMode`, `shellUsed`, `executable`, `platform`,
  `wsl`, `injectedEnvNames`, `requested/resolvedSecretCount`. Use these to self-verify injection.
- Server-level `instructions` now ship with the MCP, so the rules load every session.

**How to use it here:** native processes only — cmd (`command` form, `%VAR%`), `shell:"powershell"`
(`$env:VAR`), or `node` (`process.env.VAR`). e.g. `op_run command:"node x.js" env:{DBPASS:"op://..."}`.
For POSIX work use `shell:"git-bash"`. `argv` = direct spawn, no shell, no `$VAR`/`%VAR%` expansion,
element 0 must be a real executable (`argv:["echo",…]` fails ENOENT — echo is a cmd builtin).
`op://` is resolved ONLY for values in `env`, never inside command/argv text.

**KNOWN DEFECT (as of 2.6.0):** `shell:"wsl"` cannot execute — Node appends `-c`, which `wsl.exe`
rejects ("Invalid command line argument: -c"). The safety guard is fine; the opt-in escape path is
broken. Fix planned for 2.6.1 (`wsl.exe -e bash -lc …`). See `handoff.md` §4 in `u2giants/1Password-MCP`.

Repo: `u2giants/1Password-MCP` (`@u2giants/1password-mcp`, main-only). Release = push a `v*` tag from
main (OIDC Trusted Publishing, no token). Version lives in FOUR places that must match: package.json,
server.json (×2), src/config.ts. Consumers (Windows Claude Desktop + Codex; VPS `hetz`
`/root/.codex/config.toml`) all use unpinned `npx -y @u2giants/1password-mcp` → restart picks up latest.

Ancillary: `psql` is NOT installed on this Windows box — for ad-hoc shared-db queries use Node + `pg`
(install into scratchpad) against the pooler `aws-1-us-east-1.pooler.supabase.com:6543`, user
`postgres.qsllyeztdwjgirsysgai`. See [[shared-db-change]].
