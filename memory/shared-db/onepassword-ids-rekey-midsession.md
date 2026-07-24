---
name: onepassword-ids-rekey-midsession
description: "1Password MCP item/vault IDs can change mid-session; look up by title+vault, never reuse a cached ID or a title-with-spaces op:// ref"
metadata: 
  node_type: memory
  type: reference
  originSessionId: 923133fa-ddf7-43f5-aaad-4ece284bd343
  modified: 2026-07-24T19:57:36.387Z
---

Observed 2026-07-23 (shared-db session): the 1Password MCP `vibe_coding` vault ID
and item IDs **changed partway through a single session** (the MCP reconnected to
a different backing service account). Calls that had worked started failing with
`itemNotFound` / vault-not-found, and `op_run` returned
`itemNotFound` for a previously-good `op://vibe_coding/<itemId>/FIELD` reference.

How to work around it reliably:
- Do not cache and reuse a 1Password **item ID** across a long session. Re-run
  `item_lookup` (with the current `vault_list` vault ID) to re-resolve the item ID
  before an `op_run` if a prior call started failing.
- For `op_run`, reference by item ID in the `op://vault/<itemId>/FIELD` form —
  but note the item ID may need refreshing (above). A title with **spaces or
  parentheses cannot be parsed** in an `op://` reference at all (e.g. the Supabase
  preview-credentials item), which is why the ID form is used.
- Secrets never enter chat: keep `op://` refs in `op_run`'s `env` only. See
  [[op-run-mcp-wsl-env-trap]] for the WSL/argv caveat.

Preview DB creds item: "Supabase Preview Branch Credentials - shared POP database
(shared-db-schema-rehearsal)", field `POSTGRES_URL` (transaction pooler). Prod DB
password item: "Supabase DB Password - shared POP database" (field `password`);
CLI PAT: "Supabase CLI Personal Access Token" (field `credential`).
