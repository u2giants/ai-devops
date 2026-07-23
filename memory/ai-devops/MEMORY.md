# Memory index — C:\repos\ai-devops

- [op service-account token field](op-service-account-token-field.md) — the token is in `op_service_account_token`, NOT the empty `credential` field; verify resolved secrets are non-empty.
- [GLM agent Z.ai field + fork bomb](glm-agent-zai-field-and-forkbomb.md) — GLM key is in the "api key" field (id vup42…), not `credential`; empty key fork-bombed the launcher; fixed with field-id ref + re-exec guard.
- [vibe_coding vault reprovisioned](vibe-coding-vault-reprovisioned.md) — 2026-07-22 SA token rotation moved to a new account; vault + all item UUIDs changed, breaking old op:// UUID refs; new UUIDs + token locations recorded.
