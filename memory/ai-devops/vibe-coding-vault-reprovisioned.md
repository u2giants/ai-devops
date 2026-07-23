---
name: vibe-coding-vault-reprovisioned
description: "On 2026-07-22 the 1Password service account was rotated into a new account; the vibe_coding vault + every item got new UUIDs, so old op:// UUID refs went stale."
metadata: 
  node_type: memory
  type: project
  originSessionId: 79b8e5c0-e485-4b56-94d2-01dbb90addab
  modified: 2026-07-23T03:16:57.638Z
---

On 2026-07-22 Albert rotated the 1Password service-account token. The new token
authenticates to `popcreations.1password.com` and the `vibe_coding` vault now has
**vault id `pimcaogmxxzoafh7lsluj6uxkq`** (it was `b2dsir4jze3wfygdxixoaasdeq`
before). Every item UUID changed with it, so all `op://vibe_coding/<UUID>/…`
references pinned to the OLD UUIDs stopped resolving ("isn't an item in the
vibe_coding vault"). References by item **name** (e.g. `designflow-mcp`) kept
working.

New token stored on t16 at `~/.config/ai-devops/op-service-account` (the launcher
reads the token from that FILE, not the env var) and in the OS User env var
`OP_SERVICE_ACCOUNT_TOKEN`. Old token backed up alongside as `*.bak-20260722`.

Current item UUIDs remapped in `config/mcp.env.example`, `bin/setup-secrets.sh`,
`bin/setup-machine.ps1`:
- Supabase CLI PAT → `3t2xoqk5luyz7ffgdhj24gvtpq` (field `SUPABASE_ACCESS_TOKEN`)
- Trigger.dev PAT (management) → `ylzcsfbhmjyzjy65mnu6uxw67e` (field `credential`)
- recall-ai MCP → `dwvlpanu4odty3bjnmb5my5esy` (field `password`)
- GLM z.ai API → `jjgy3uyww3creybrcz4w6lrfm4` (field `vup42ni2phmssxqfkdfadxx22i`)

Codex config (`~/.codex/config.toml`) also carried the old SA token plus stale
hardcoded bearer VALUES for trigger/devops-mcp/synology — all refreshed in place.

Lesson: after any 1Password account/vault reprovision, UUID-pinned refs are the
thing that breaks. Prefer item names where practical. Related:
[[op-service-account-token-field]], [[glm-agent-zai-field-and-forkbomb]].
