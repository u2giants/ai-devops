---
name: 4837-home-drive-z-trap
description: "On 4837, interactive Git Bash $HOME was Z: (roaming profile), so $HOME-based installs hit a network drive Claude/Codex never read; fixed by pinning HOME=C: and making ai-install-skills use %USERPROFILE%."
metadata: 
  node_type: memory
  type: project
  originSessionId: 8c1a636c-de2a-4f4c-a77c-13a83d803bec
  modified: 2026-07-24T16:48:33.531Z
---

On the 4837 Windows dev box, the **interactive** logon maps the home drive to
`Z:` (roaming profile, `HOMEDRIVE=Z:`), so Git Bash computed `$HOME=Z:\`. Any
`$HOME`-based installer (notably `bin/ai-install-skills`) then wrote to
`Z:\.claude`, `Z:\.config`, `Z:\.ssh` — a network share that Claude Code and
Codex **never** read (they use `%USERPROFILE%` = `C:\Users\ahazan2`). It also
silently skipped Codex (`Z:\.codex` didn't exist). SSH/service logons are
unaffected — they resolve to `C:`.

**Fixed 2026-07-24 two ways:** (1) set a User env var `HOME=C:\Users\ahazan2`
on 4837; (2) `bin/ai-install-skills` now bases the install on `%USERPROFILE%`
when set (Windows) instead of `$HOME`, with a loud NOTE when they differ.
Explicit `CLAUDE_HOME`/`CODEX_HOME` still override. t16/916 were never affected.

Leftover `Z:\.claude|.config|.ssh` folders are stray — safe to delete after
checking `.ssh` for a real private key. See also [[mcp-1password-launcher-storm]]
for another "silent wrong-location" class bug in this repo.
