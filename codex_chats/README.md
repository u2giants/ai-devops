# codex_chats

Archived Codex session transcripts, backed up from local Codex data directories.

These files are scrubbed copies of `rollout-*.jsonl` transcripts and
`session_index.jsonl` files. The scrub pass redacts common API tokens, bearer
tokens, JWTs, password/key fields, private-key blocks, and encrypted reasoning
payloads.

> Sensitive data: transcripts can still contain private business context,
> hostnames, emails, paths, and non-standard secret formats. Keep this repository
> private and rotate any credential that was exposed in a prior session.

## Machines

### `916/`

Codex transcripts copied from this server's local Codex homes:

- `/root/.codex`
- `/home/ai/.codex`

The archive preserves the source path shape under `codex_chats/916/`.
