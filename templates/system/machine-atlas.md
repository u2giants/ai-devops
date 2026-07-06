# Machine atlas — per-machine environment facts

Facts every AI session otherwise rediscovers the hard way. Keep the relevant
machine's section in that machine's user-level `~/.claude/CLAUDE.md` (appended
after `CLAUDE-global.md`), or reference this file. Update when infrastructure
changes; convert to that machine's reality, don't guess.

## hetz — Hetzner VPS (Ubuntu), the production server

- IP `178.156.180.212`, 32 GB RAM. Claude runs as user `ai` (uid 1000);
  repos have the setgid/ACL group fix (`/home/ai/permfix/setup-shared-worksp.sh`)
  so root and ai sessions don't collide on .git objects.
- All projects under `/worksp/`: popdam3, popcrm-web, poppim-web, shared-db,
  monitor, hiclaw, ai-devops, albert-standards. **Never `/opt/ai-devops`.**
- Deploy stack: GitHub Actions → GHCR (`ghcr.io/u2giants/*`) → **Coolify** v4
  (API :8000, token in 1Password) behind Traefik + Let's Encrypt.
  - QUIRK-1: Coolify *services* (poppim-web) restart via
    `GET /api/v1/services/{uuid}/restart` — `/api/v1/deploy?uuid=` silently no-ops.
  - QUIRK-2: verify deploys by grepping `<meta name="build-sha">` in served
    HTML — `version.json` is intercepted by try_files.
- Domains (`*.designflow.app`): pm=poppim-web, crm=popcrm-web, dam=popdam,
  sg=PopSG (same image as dam, mode by hostname), mon=synology-monitor,
  seafile, mcp=devops-mcp, nas-mcp=synology-monitor MCP.
- Coolify also hosts: Mission Control/Paperclip (mc.designflow.app), OpenClaw
  gateway "ocgate" (claw.designflow.app). Model calls route via OpenRouter.
- Supabase projects — never mix refs: shared backend `qsllyeztdwjgirsysgai`,
  popdam prod `ryltkzzernhwnojzouyb`, SynoMon Virginia `aaxtrlfpnoutziwhshlt`,
  oracle `eqccjfbyrywsqkxxpjvg`.
- GCP OAuth lives in project `oauth-popdam`, not the default project.
- 1Password service account `hetzner_vps`, vault `vibe_coding`.

## Off-box infra (reachable from several machines)

- Two Synology NASes over Tailscale: `edgesynology1` (primary/authoritative,
  NYC, 192.168.3.100) and `edgesynology2` (replica via Drive ShareSync; has
  had Btrfs corruption). SSH alias `edge1` from Windows boxes.
- Synology facts: docker binary is
  `/var/packages/ContainerManager/target/usr/bin/docker` (plain `docker` fails
  for non-root); no `visudo` on DSM; user `ai` has passwordless sudo for docker
  only; compose stacks live in `/volume1/docker/<stack>` with `.env` chmod 600
  — NEVER deploy from a home dir or /tmp (caused untracked drift).
- Seafile: VPS `seafile-br` (Brazil), https://seafile.designflow.app;
  seaf-cli sync container `ghcr.io/u2giants/seafile:seaf-cli-latest` on
  edgesynology1. Gotchas: raise `fs.inotify.max_user_watches` ≥ 1048576;
  ignore file is `seafile-ignore.txt` (not `.seafile-ignore`) and must include
  `@eaDir #recycle #snapshot @tmp`.
- ShareSync unstick procedure (the ONLY thing that works — restarts don't):
  move the stuck file out of its folder, rename it, wait for sync, move back.
  See the `synology-sharesync-stuck-triage` skill.
- File-archive jobs on NAS shares must NEVER change file dates
  (created/modified) — hard requirement.
- Bridge-agent containers at `/volume1/docker/popdam` on the NAS; Watchtower
  updates images but not compose config. Windows render agent does thumbnails.

## 916 ("916-alien") and t16 and 4837 — Windows 11 dev machines

- User `ahazan2`. PowerShell 7 primary; WSL Ubuntu available (used for Ansible
  on t16 — Ansible doesn't run on native Windows).
- dflow working copies: `D:\repos\dflow` / `C:\repos\dflow` (branch
  `sandbox-albert`), `…\dflow-alsand2` / `dflow alsand2` (branch
  `albert-2sandbox`). Six popcre repos as siblings. See `dflow-session-start`
  skill for all dflow rules.
- Other repos: oracle (pnpm+turbo monorepo, Vercel + Trigger.dev + Drizzle),
  shared-db, ansible (t16), synology-monitor, popdam3 checkout, 1Password-MCP
  fork (`@u2giants/1password-mcp`, main-only, Trusted Publishing via tag push;
  version bumps go in package.json + server.json ×2 + src/config.ts).
- Claude Desktop is the Store/MSIX install — config is at
  `C:\Users\ahazan2\AppData\Local\Packages\Claude_pzs8sxrjxfjjc\LocalCache\Roaming\Claude\claude_desktop_config.json`,
  NOT `%APPDATA%\Claude`. MCP servers are added via the two Dropbox scripts
  (`setup-claude-mcps.ps1` / `setup-codex-mcps.ps1` under
  `C:\Dropbox\vibe coding\set up synology and VPS MCP servers…`) — never
  hand-edit configs, never let Claude scripts touch Codex config
  (`C:\Users\ahazan2\.codex\config.toml`).
- Remote MCPs: devops-mcp `https://mcp.designflow.app/mcp` (VPS root access),
  synology-monitor `https://nas-mcp.designflow.app/sse` (NAS); AG-Grid MCP for
  dflow docs.
- Known trap: the Windows-MCP PowerShell sandbox cannot capture SSH output
  (ConPTY exit 255); use Git's ssh (`C:\Program Files\Git\usr\bin\ssh.exe`)
  in-place — never copy it out (msys DLLs) and never overwrite system OpenSSH.
- Hetzner VPS SSH from Windows: alias `vps`/`coolify` in `~\.ssh\config`,
  users `root`/`ai`, keys `id_ed25519` / `916-alien`.
- Local scans stay on the system drive — network drives (P:\ Images SMB, Z:\
  Documentation) are large mounts; don't traverse them uninvited.
- dflow test login: sandbox email+password in 1Password (`vibe_coding`);
  Microsoft SSO via Azure tenant (popcre.com); Adam Dweck
  (adweck@popcre.com) is the one Salesman user with special column visibility.

## People

- **Uma** (`devopswithkube`) — the human developer; reviews all dflow PRs to
  `develop`. Never merge dflow PRs.
- **Adam Dweck** — salesman user (special grid columns).
- Microsoft 365/Entra tenant = popcre.com; Albert's admin account
  albert@popcre.com.
