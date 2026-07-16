---
name: feedback_1password_access
description: "Use the scoped 1Password MCP (vibe_coding only) — NOT the op CLI (full-account, all vaults)"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: dca4a837-f0a9-4e15-8bc1-b36cec545e10
---

For 1Password, ALWAYS use the **MCP** tools (`mcp__1password__*`). That server is backed by a service account scoped to **only the `vibe_coding` vault** (id `b2dsir4jze3wfygdxixoaasdeq`) — `vault_list` returns just that one. Store any secrets there and nowhere else.

Do NOT use the `op` CLI via the shell. On this machine `op` is wired to the user's full 1Password **desktop app** account (hazan@isaacmorris.com), which can see every vault (Private, Isaac+Albert, Shared, vibe_coding, Zarina+Albert). The user explicitly wants my access limited to vibe_coding only. Also: each shell tool call is a fresh process, so a token/session the user sets in their own PowerShell window does NOT reach my shell; and the desktop integration is non-interactive-unfriendly (write ops hang on the approval prompt, reads hit "authorization timeout").

**Why:** the user was (rightly) alarmed that I could enumerate all vaults via the CLI. The MCP is the correct least-privilege channel.
**How to apply:** create/read items with `mcp__1password__password_create` / `item_lookup` against the vibe_coding vault id. Note `password_create` takes the secret as a parameter, and reading a real secret value into context is blocked by the safety classifier (credential leakage) — so for real secrets, create the item with full notes + a placeholder and have the user paste the value, or have them retrieve it from the source of truth (e.g. GCP Secret Manager) themselves. See [[project_graph_photos]] / [[project_graph_profile_photos]] for the AZURE_CLIENT_SECRET item created this way.
