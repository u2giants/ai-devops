---
name: ansible-project-overview
description: "The u2giants/Ansible repo — host-layer Ansible for the Hetzner box, its own dedicated repo"
metadata: 
  node_type: memory
  type: project
  originSessionId: c1b93c02-75c5-4760-b6aa-f6571f8d7607
---

`u2giants/Ansible` (cloned at `C:\repos\ansible\ansible`) is a **dedicated repo** (NOT a subfolder of another repo) implementing the host-layer Ansible + gated GitHub Actions apply pipeline for the Hetzner VPS `hetz`. It follows `docs/ANSIBLE-IMPLEMENTATION-PLAN.md`.

Scope boundary: **Ansible owns the host/glue layer; Coolify owns the apps** — never manage app containers with Ansible.

Phases (plan §9): Phase 0 + **Phase 1 + most of Phase 2 applied to prod by 2026-06-24** (from WSL as root over Tailscale — see [[hetz-ssh-access]]). Live: motd/base/users/dns_hardening/backrest_watchdog (P1); docker (pin+daemon.json, no restart); firewall (reworked to declarative SSH-lockdown only — full iptables-save drifts daily via Docker nat); ssh_hardening (root off public internet, ai on key/password, root password over Tailscale); cloudflared UNIT (verbatim). All idempotent.

**Core project COMPLETE (Phases 0–4) + recovery-gap work R1–R6 as of 2026-06-24.** The mission (docs/DISASTER-RECOVERY.md) is full catastrophic recovery with zero owner knowledge: "rebuild everything" from GitHub + backrest + 1Password + Ansible. Every piece of host software is now captured: vendor apt repos + all 202 manual packages (apt_repos, packages roles), non-apt tools go/supabase/codex/npm-CLIs (dev_tools), Docker engine install (docker), Coolify install+glue (coolify, install unproven until R7). Software-inventory drift check live in drift.yml (bin/discover-software.sh vs docs/baseline-software.txt). Rebuild procedure in docs/RUNBOOK-REBUILD.md. ONLY R7 remains (rebuild-and-diff on a throwaway box — proves Coolify install + restore + runbook). Recovery plan + status: docs/RECOVERY-GAP-PLAN.md. CI pipeline live: push to `main` auto-applies to hetz (serialized, `ENABLE_AUTO_APPLY=true`); runner joins Tailscale (tag:ci OAuth in 1Password "tailscale oauth for github for ansible"), loads secrets via OP service account, SSHes as `ai` with CI key (op://vibe_coding/ci-deploy-ssh). Drift detection daily. cloudflared token reconciled (op://vibe_coding/cf-tunnel-hetz); `cloudflared_manage_token` stays false (manual). `ai` SSH password in vibe_coding/hetz-ai-ssh. Optional follow-ups + full status in repo HANDOFF.md + AGENTS.md §14. NOTE: auto-apply is ON, so every push to main triggers an apply (doc-only = no-op).

Local git workflow for this repo: see [[main-only-workflow]] (commit/push to main, no branches).
