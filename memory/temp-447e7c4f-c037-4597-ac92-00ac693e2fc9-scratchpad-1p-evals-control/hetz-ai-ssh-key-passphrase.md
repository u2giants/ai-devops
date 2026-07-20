---
name: hetz-ai-ssh-key-passphrase
description: "Where to fetch the passphrase for the hetz VPS `ai` user SSH key, and which alias/box it opens"
metadata: 
  node_type: memory
  type: reference
  originSessionId: 593aaf9f-e784-4d30-8651-18e2a2d9bfcd
---

The SSH key for the `ai` user on the Hetzner VPS (`hetz` — the Coolify box that
runs the ~20 application containers) is passphrase-protected. The passphrase
value itself lives in **1Password, vault `vibe_coding`** — fetch it from there
via the 1Password MCP at the moment you need it. It is deliberately NOT written
into any memory file, doc, or repo, per Albert's standing rule that secret
values never get pasted into files.

**Which box:** `hetz`, the Hetzner VPS. Host layer is Ansible-managed
(`u2giants/ansible`); the apps on it are Coolify-managed.

**Which alias:** connect via the `~\.ssh\config` aliases `vps` or `coolify`
(both point at the same host). Two accounts exist there: `root` and `ai`.

**Unconfirmed:** the machine atlas lists two keys for this box — `id_ed25519`
and `916-alien` — without saying which one belongs to `ai`. Read
`~\.ssh\config` to confirm the mapping before assuming (this session was denied
permission to read it).

**Windows trap:** the Windows-MCP PowerShell sandbox cannot capture SSH output
(ConPTY exit 255). Use Git's ssh at
`C:\Program Files\Git\usr\bin\ssh.exe` in place — never copy it out (msys DLLs)
and never overwrite system OpenSSH.
