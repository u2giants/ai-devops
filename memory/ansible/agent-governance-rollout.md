---
name: agent-governance-rollout
description: "Where the \"host changes route through Ansible\" rule is published for AI agents"
metadata: 
  node_type: memory
  type: project
  originSessionId: c1b93c02-75c5-4760-b6aa-f6571f8d7607
---

The rule **"host/server changes go through `u2giants/ansible` (PR→CI), never hand-edit the box; apps stay in their repos via Coolify"** is published in:

- **Global agent memories** on this PC: `~/.claude/CLAUDE.md` and `~/.codex/AGENTS.md` (every Claude/Codex session inherits it). Created 2026-06-23.
- **The Ansible repo:** `AGENTS.md` + `CLAUDE.md` at root, plus the on-box `motd` role banner.
- **All 12 u2giants repos** via an `AGENTS.md` section marked `<!-- ansible-host-policy -->`:
  - Direct-to-main commits (repos with a "no branches" ruleset): popdam3, compshop, devops-mcp.
  - PRs (branches allowed): albert-standards#2, theoracle#3, popcrm-web#2, poppim-web#2, synology-monitor#2, backrest-wiz#2, seafile#3, hiclaw#7, authentik#2.

Note: popdam3/compshop/devops-mcp enforce main-only via a GitHub ruleset — consistent with [[main-only-workflow]]. The 9 PRs were left for the owner to merge (each merge may trigger a Coolify redeploy). See [[ansible-project-overview]].
