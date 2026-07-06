---
name: project_vps_1password_mcp_secrets
description: "How MCP/project secrets are managed: 1Password vibe_coding vault via op CLI (vault-scoped service account on the VPS), the .mcp.json placeholder + op run setup, and the held-docker fix for the recurring coolify-proxy socket failure"
metadata: 
  node_type: memory
  type: project
  originSessionId: 18f5033f-df76-4d6c-a271-171812318866
---

This Claude Code runs ON the Hetzner VPS (`hetz`) that hosts the Coolify stack (frontend, the two MCP servers, popcrm/poppim/directus, etc.). I have docker access via passwordless `sudo`.

**Secrets live in 1Password vault `vibe_coding`** (id b2dsir4jze3wfygdxixoaasdeq). A 1Password **service account** token is at `/root/.bashrc` as `OP_SERVICE_ACCOUNT_TOKEN` — it is **scoped to `vibe_coding` ONLY** (read+write), so `op` CLI on the VPS cannot see other vaults. Load it in a fresh shell with:
`export OP_SERVICE_ACCOUNT_TOKEN="$(sudo grep -m1 OP_SERVICE_ACCOUNT_TOKEN /root/.bashrc | sed -E 's/^[^=]*=//; s/^["'\'']//; s/["'\'']$//')"`. There is **no 1Password MCP** connected to the session (user is forking one; it needs write ops: create-with-notes, edit fields, **edit notesPlain after creation** — `op` CLI does all these). The user prefers the MCP over `op` CLI when available, but the SA is already least-privilege.

**Vault items (all with detailed notesPlain):** `designflow-mcp` (devops_token→Coolify TOKEN_ROOCODE, nas_token→Coolify MCP_BEARER_TOKEN, supabase_pat), `github-pat`, `ai-provider-api-keys`, `devops-mcp-client-tokens`, `nas-monitor-secrets`, plus a pre-existing Azure secret.

**`.mcp.json` (repo root) carries NO secrets** — `devops-mcp` and `synology-monitor` use `${DEVOPS_MCP_TOKEN}`/`${NAS_MCP_TOKEN}` (both native `type:http` at `/mcp`). Launch Claude Code via `op run --env-file=<refs to vibe_coding/designflow-mcp> -- claude` so they resolve. supabase MCP reads `SUPABASE_ACCESS_TOKEN`. See [[project_supabase_virginia_cutover]].

**MCP servers are Coolify-managed on the VPS** (token check is on the VPS, not the NAS): devops-mcp = Coolify **Service** `vj5f76xet05bxwdq4utw1kho` (file-provider routing); nas-mcp = Coolify **Application** `efl17f5iocnz94840pexre9d` (docker-provider routing). Rotate a token: update the field in 1Password + the Coolify env var (TOKEN_ROOCODE / MCP_BEARER_TOKEN) + redeploy that resource (Coolify API: create a Sanctum token in tinker — needs `team_id` set — then `GET /api/v1/deploy?uuid=...`). Coolify env vars are encrypted rows in coolify-db; edit via `docker exec coolify php artisan tinker` (EnvironmentVariable model, polymorphic resourceable_type/id; nas-mcp has prod + is_preview rows).

**Recurring coolify-proxy socket failure (root-caused 2026-06-22):** `unattended-upgrades` auto-upgrades docker-ce/containerd → daemon restart recreates `/var/run/docker.sock` → coolify-proxy's read-only **file** mount goes stale → Traefik docker provider blind → new/changed containers 502 (services on the file provider survive). **Fix applied:** `apt-mark hold` docker packages (no auto-restart) + a self-healing watchdog backstop (`deploy/vps/coolify-proxy-socket-watchdog.sh` + systemd timer). Manual docker updates need `docker restart coolify-proxy` after. See AGENTS.md 2026-06-22 incident + `deploy/vps/README.md`.
