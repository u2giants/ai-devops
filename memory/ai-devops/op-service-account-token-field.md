---
name: op-service-account-token-field
description: "The vibe_coding service-account token lives in the op_service_account_token field, not credential (which is empty)"
metadata: 
  node_type: memory
  type: reference
  originSessionId: 873a5bf6-5d3d-4b93-b632-e0e90dc85759
---

In the 1Password `vibe_coding` vault, item **`vibe_coding-service-account`**, the
`ops_...` service-account token is stored in the field
**`op_service_account_token`** (field id `dl3627qamlngy3aisi455tpyvy`, stable
across accounts).

**2026-07-22 account migration:** the service account moved from
`my.1password.com` to a NEW account `popcreations.1password.com`. The vault was
re-created, so the item UUID changed: **new item id `5rc7vid3gfvvmqsbtrt2sipq5y`**
(old was `2mwhq624vphlsoqafxpkljp45y`, now dead). See [[op-account-migration-2026-07]]
for the full list of UUID changes and the read-only-SA gotcha. On the OLD account
the `credential` field was EMPTY (silent-empty trap); after migration BOTH
`credential` and `op_service_account_token` now hold the current 866-char token
(refreshed once the read-write SA was in place, Integration ID
`OEO2NT4575H6XPSVHZE7AQXPZM`). The live source of truth is still the machine's
`OP_SERVICE_ACCOUNT_TOKEN` OS env var; the vault copy is a backup/record.

Historical (still true on any read that returns 0 bytes): every read of an empty
field returns 0 bytes with exit 0 (silent empty), which looks like success but
writes an empty token file.

**Correct reference:** `op://vibe_coding/vibe_coding-service-account/op_service_account_token`

Gotcha: `op_check_ref` / the 1Password MCP report the `credential` field as
"resolved: true" because the field *exists* — that only validates existence, not
that it holds a value. Verify a resolved secret is non-empty (write to a temp file
with `op read --out-file --force` and check byte count) before trusting it.

To install the token leak-free: `op read <ref> --out-file <path> --force`
(needs `--force` to skip the write-to-disk confirmation; never pipes the value to
stdout, so it doesn't materialize in the transcript). The Phase 2 setup scripts
([[ai-devops-phase2-state]]) read it back from that locked-down file.
