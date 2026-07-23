---
name: glm-agent-zai-field-and-forkbomb
description: "GLM agent's Z.ai key lives in the \"api key\" field (not `credential`), and op run's silent empty caused a launcher fork bomb — fixed 2026-07-22."
metadata: 
  node_type: memory
  type: project
  originSessionId: 2cd8d694-cdd5-4296-b5a5-42569943dd7f
  modified: 2026-07-23T01:05:25.045Z
---

The `ai-glm-agent` launchers read `ZAI_API_KEY` from `~/.config/ai-devops/mcp.env`
via `op run --env-file`. Two traps bit here (fixed 2026-07-22, commit on
u2giants/ai-devops main):

1. **The key is NOT in the item's built-in `credential` field.** 1Password item
   "GLM z.ai API" (vibe_coding, id `lc35ogs6lrvtjfsosathibgcwm`) stores the real
   Z.ai key in a custom field labelled **"api key"** (field id
   `vup42ni2phmssxqfkdfadxx22i`). The `credential` field is EMPTY. `op read`/`op run`
   of an empty field return `""` with exit 0 — a silent empty. Same class of trap
   as [[op-service-account-token-field]]. Correct ref (item id + field id, both
   space-free so `op run --env-file` parses it):
   `op://vibe_coding/lc35ogs6lrvtjfsosathibgcwm/vup42ni2phmssxqfkdfadxx22i`.

2. **Empty key → fork bomb.** The launcher re-execs itself under `op run` whenever
   `ZAI_API_KEY` is empty. With the key permanently empty the re-exec looped without
   bound (340+ stacked `op run … ai-glm-agent` processes on hetz before it was
   killed). Both `bin/ai-glm-agent` and `bin/ai-glm-agent.ps1` now set
   `AI_GLM_REEXEC=1` before re-exec and fail loudly on the second empty pass.

**Why to check by field id, not title:** `op run --env-file` also mis-parses op://
refs whose item title or field label contains spaces ("GLM z.ai API", "api key") —
it silently injects empty. `op read` tolerates the spaces; `op run` does not.

**Verified working end-to-end 2026-07-22** on both Windows (t16, launcher ps1) and
hetz (`ai` user) — GLM_AGENT_OK, model glm-5.2, no process pile-up. Windows op
happened to resolve the old `/credential` ref anyway (version-dependent); hetz op
2.34.1 did not — the field-id ref is correct on both.
