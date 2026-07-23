---
name: glm-agent-zai-field-and-forkbomb
description: "GLM agent's Z.ai key lives in the \"api key\" field (not `credential`), and op run's silent empty caused a launcher fork bomb — fixed 2026-07-22."
metadata: 
  node_type: memory
  type: project
  originSessionId: 2cd8d694-cdd5-4296-b5a5-42569943dd7f
  modified: 2026-07-23T12:29:28.221Z
---

The `ai-glm-agent` launchers read `ZAI_API_KEY` from `~/.config/ai-devops/mcp.env`
via `op run --env-file`. Two traps bit here (fixed 2026-07-22, commit on
u2giants/ai-devops main):

1. **The key is NOT in the item's built-in `credential` field.** 1Password item
   "GLM z.ai API" (vibe_coding) stores the real Z.ai key in a custom field
   labelled **"api key"** (field id `vup42ni2phmssxqfkdfadxx22i`). The
   `credential` field is EMPTY. `op read`/`op run` of an empty field return `""`
   with exit 0 — a silent empty. Same class of trap as
   [[op-service-account-token-field]]. Current ref (the repo now uses the
   name-based form, which survives account migration — see
   [[vibe-coding-vault-reprovisioned]]):
   `op://vibe_coding/GLM z.ai API/api key`.
   (The item's UUID changed in the 2026-07-22/23 account migration, which is why
   name-based refs are preferred over the old UUID `lc35ogs6lrvtjfsosathibgcwm`.)

2. **Empty key → fork bomb.** The launcher re-execs itself under `op run` whenever
   `ZAI_API_KEY` is empty. With the key permanently empty the re-exec looped without
   bound (340+ stacked `op run … ai-glm-agent` processes on hetz before it was
   killed). Both `bin/ai-glm-agent` and `bin/ai-glm-agent.ps1` now set
   `AI_GLM_REEXEC=1` before re-exec and fail loudly on the second empty pass.

**Spaces in refs — version-dependent, not a blanket ban.** On **op 2.34.1**
(hetz) `op run --env-file` mis-parsed op:// refs whose item title or field label
contained spaces ("GLM z.ai API", "api key") and silently injected empty, which is
why the field-id form was originally chosen. On the current op (t16, verified
2026-07-23) name-and-label refs **with spaces resolve correctly** via
`op run --env-file` — this is what the repo now uses. If you hit a silent empty on
an older op, fall back to the space-free item-id + field-id form. `op read`
tolerates spaces on all versions.

**Verified working end-to-end 2026-07-22** on both Windows (t16, launcher ps1) and
hetz (`ai` user) — GLM_AGENT_OK, model glm-5.2, no process pile-up. Windows op
happened to resolve the old `/credential` ref anyway (version-dependent); hetz op
2.34.1 did not — the field-id ref is correct on both.
