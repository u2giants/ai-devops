---
name: Albert's server and app infrastructure
description: Coolify server, Docker containers, databases, and Roo Code MCP setup for all of Albert's projects
type: project
---

Albert runs all apps on a Coolify instance at 178.156.180.212 (SSH alias: `coolify`). SSH key: `~/.ssh/id_ed25519`. Coolify abstracts Docker — no direct container UI.

**Projects on Coolify:**

1. **OpenClaw** (claw.designflow.app) — AI agent gateway app. Containers: `openclaw-yxz0hmaien0bgn0sv64g8q3p-044544225829`, `browser-yxz0hmaien0bgn0sv64g8q3p-044544240347`. NO database — fully self-contained. No Supabase project.

2. **POP Creations CRM / Twenty** (Twenty CRM instance). Containers: `pkhhmt4r7n0xt25jmmlkkfi8-125130450026`, `rd261bt0wy7ifjrkoe1tkl92-125130345971`. Internal Postgres: container `g5j115bwrn8125ev6ap1tjrv`, user=twenty, db=twenty. Tunneled to localhost:15432 via `C:\Users\ahazan2\.roo-mcp\tunnel_twenty_pg.js`.

3. **Mission Control / Paperclip** (mc.designflow.app) — Container: `paperclip-jihoc2f68xmgi2gfomhhr9g3-052451089218`. No DB of its own.

4. **Synology Monitor** (mon.designflow.app) — Container: `lrddgp8im0276gllujfu7wm3-010449503799`. Uses **external Supabase**: project `qnjimovrsaacneqkggsn` (SynoMon).

5. **popdam** — hosted on Lovable cloud (NOT on Coolify). Uses Supabase project `ryltkzzernhwnojzouyb` (popdam-prod).

**Supabase token:** stored in Roo Code MCP config. Projects: popdam-prod (ryltkzzernhwnojzouyb), SynoMon (qnjimovrsaacneqkggsn).

**Roo Code MCP config location:** `C:\Users\ahazan2\AppData\Roaming\Windsurf\User\globalStorage\rooveterinaryinc.roo-cline\settings\mcp_settings.json`

**MCPs configured:**
- `coolify-server`: mcp-shell, runs `ssh coolify "docker ..."` commands on server
- `twenty-crm-postgres`: Postgres MCP via SSH tunnel on localhost:15432
- `supabase`: Supabase MCP with token sbp_30745... covers both Supabase projects

**SSH tunnel helper:** `C:\Users\ahazan2\.roo-mcp\tunnel_twenty_pg.js` (node script, must be running for Twenty DB access). Start script: `C:\Users\ahazan2\.roo-mcp\start_tunnels.bat`

**Why:** To plan ahead — if Tailscale is set up across all machines, SSH tunneling becomes unnecessary and direct DB connections work everywhere.
