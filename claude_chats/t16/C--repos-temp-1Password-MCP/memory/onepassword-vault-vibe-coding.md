---
name: onepassword-vault-vibe-coding
description: "The only 1Password vault to use for any u2giants project is \"vibe_coding\""
metadata: 
  node_type: memory
  type: project
  originSessionId: b066c30f-4eaf-4d62-af0c-55928ddb9e7b
---

The **only** 1Password vault anyone/anything should use across u2giants projects is **`vibe_coding`**. It is the single vault the shared service account can access; all `op://` secret references must start with `op://vibe_coding/...`. Do not create or reference other vaults.

**Why:** The OP service account is scoped to `vibe_coding` only; references to other vaults will fail and fragment secret storage.

**How to apply:** In any 1Password MCP / `op` CLI usage and docs, use `op://vibe_coding/<item>/<field>`, `op item list --vault vibe_coding`, etc. This is baked into the `docs/1password.md` (root `1PASSWORD.md` in albert-standards) files committed to all 12 u2giants repos. The deprecated npm token lived at `op://vibe_coding/npm-publish-token` (now OIDC — see publishing docs).
