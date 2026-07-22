---
name: headroom-proxy-setup
description: Headroom token-compression proxy runs on the hetz VPS; our Claude sessions route through it over Tailscale. Full details in ai-devops docs/headroom.md.
metadata: 
  node_type: memory
  type: project
  originSessionId: c574d21e-5260-46f7-8b65-df8253ba0eab
---

Headroom (token-compression proxy, v0.30.0, pipx under user `ai`) runs on the
**hetz VPS** at `/home/ai/.local/bin/headroom`, NOT on any Windows machine. It
reduces Claude input tokens by compressing tool outputs before they reach
Anthropic. Full writeup: `ai-devops/docs/headroom.md` (routed from AGENTS.md).

**Design (as of 2026-07-14):** systemd `headroom.service` runs the proxy bound to
the **private Tailscale IP `100.66.37.58:8787`** only (never public — the VPS
firewall is default-open, so binding 0.0.0.0 would expose Albert's Claude quota
to the internet). Two workflows both point at `http://100.66.37.58:8787`:
- **Claude on the VPS** (SSH/remote mode, `ai` user): `/home/ai/.bashrc` exports
  `ANTHROPIC_BASE_URL`.
- **Claude local on a Windows box** (clone-and-code): `~/.claude/settings.json`
  `env` block. Only **AL8960OFC** (office computer) + the VPS ai user are wired;
  the other 2 Windows machines are not. Takes effect after a full Claude Desktop
  quit+relaunch. `ssh vps2` (LocalForward 8787 → 100.66.37.58:8787) is an
  optional tunnel fallback.

**2026-07-14 fix:** it was crash-looping 35,859 times (an orphan hand-started
proxy held port 8787). Killed the orphan + stale locks, rebound to Tailscale,
hardened the unit (`After/Wants=tailscaled.service`) so a reboot can't relaunch
the loop.

**Payoff unproven — standing decision: if it's not clearly worth it, PULL IT.**
Lifetime savings at fix time: 50 requests, 594 tokens (0.27%), ~$0.003; only real
activity was one 10-min window on 2026-07-07. Measure real sessions before
trusting it. See savings: `/home/ai/.headroom/proxy_savings.json`,
`savings_events.jsonl`, or `headroom perf`. Reach VPS via `ssh hetzner` / the
devops-mcp. **Revert:** delete the `env` block (Windows) or the `.bashrc` export
(VPS) and restart the client; `systemctl stop/disable headroom.service` to halt.
