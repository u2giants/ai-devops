---
name: remote-shell-cwd-trap
description: "A remote `bash -lc`/`-c` shell (SSH into a Windows box, or any non-interactive remote shell) starts in $HOME, NOT the repo — relative commands run in the wrong place. Use `git -C <path>` and absolute paths, or `cd <path> &&` first. Also: ssh alias `4837` now lives in the config template + Dropbox generator."
metadata:
  type: feedback
---

When an AI session runs commands on another machine over SSH via `bash -lc "..."`
(or `bash -c`, or a bare remote command), the shell opens in **`$HOME`, not in
the repo directory** — even if a human's interactive terminal on that box would
have been sitting in the repo. Relative paths (`git pull`, `bash bin/...`) then
fail with `fatal: not a git repository` or `not recognized`, and it is easy to
resend the same relative command several times without noticing the missing
`cd`.

**Why:** the assumption "the shell is where I expect" is false for remote/
non-login shells. The CWD is whatever the login lands on (usually `$HOME`).

**How to apply:** never rely on the remote CWD. Make every command
location-explicit so it works regardless of where the shell starts:

- Git: `git -C /c/repos/ai-devops pull …` (no `cd` needed).
- Scripts/installers: call by absolute path — `bash /c/repos/ai-devops/bin/ai-install-skills`.
- If a step genuinely needs the CWD, prepend it in the same command:
  `cd /c/repos/ai-devops && …`.
- On Windows over SSH, git-bash lives at `C:\Program Files\Git\bin\bash.exe`;
  invoke the repo tooling through it explicitly, e.g.
  `ssh 4837 '"C:\Program Files\Git\bin\bash.exe" -lc "git -C /c/repos/ai-devops pull …"'`.

This is the same "silent wrong-location" failure class as the
[[4837-home-drive-z-trap]] ($HOME resolved to `Z:`) and the
[[mcp-1password-launcher-storm]] — assume nothing about environment; make it
explicit and verify.

**Reaching 4837 specifically:** alias `4837` → `100.123.87.44`, user `ahazan2`,
key `~/.ssh/916-alien` (Tailscale only). This block is in the repo template
`config/ssh-config.template` and the Dropbox `master_setupsshwindows.ps1`
generator, but a live `~/.ssh/config` only gets it after the generator /
`bin/setup-machine.ps1` runs. If `ssh 4837` says "Could not resolve hostname",
the live config is stale — append the template's `Host 4837` block (append-only)
or re-run the setup generator. t16's live config was patched 2026-07-24.
