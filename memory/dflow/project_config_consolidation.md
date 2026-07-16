---
name: project-config-consolidation
description: "ai-devops is the single hub for all machine config; \"sync my dotfiles\" skill; Phase 1 done, Phase 2/3 pending"
metadata: 
  node_type: memory
  type: project
  originSessionId: 0aae37df-4f92-41a9-96ad-2cc806c63d5e
---

The `u2giants/ai-devops` repo is the intended **single hub** that configures all
of Albert's machines (3 Windows dev boxes + 2 Ubuntu servers) on both OSes via
its existing `install.sh` / `install-ai-devops-windows.ps1` / `bin/ai-install-skills`
machinery. **Do NOT introduce chezmoi** — it would duplicate this.

**Why:** config was scattered across ai-devops, two Dropbox script folders
(`\vibe coding\ssh keys\` and `\…MCP servers\`), `~/.claude/settings.json`,
`~/.codex/config.toml`, and unsynced spots (memory, gcloud). Full map in
`ai-devops/docs/config-inventory.md`; phased plan in
`ai-devops/docs/config-consolidation-proposal.md`.

**How to apply:**
- "sync my dotfiles" → the `sync-dotfiles` skill (Claude) / `codex-sync-dotfiles`
  (Codex): pulls skills+instructions+memory from ai-devops, runs
  `bin/ai-gcloud-dflow`, pushes local memory back.
- Memory syncs machine↔repo via `bin/ai-sync-memory` into `ai-devops/memory/<project>/`;
  per-machine slugs (`C--repos-dflow` vs `D--repos-dflow`) canonicalize to one key.
- **Phase 1 = DONE** (2026-07-10): sync-dotfiles skill, `ai-gcloud-dflow`,
  `ai-sync-memory` + `memory/` tree.
- **Phase 2 = pending:** fold the Dropbox SSH + MCP scripts into `bin/`, pulling
  ALL secrets (incl. the `916-alien` SSH key + MCP tokens) from the scoped
  `vibe_coding` 1Password service account; rotate the tokens currently sitting in
  plaintext in `~/.claude/settings.json` + the Dropbox SSH script.
- **Phase 3 = pending:** retire the Dropbox scripts; one-command onboarding.

Related: [[reference_dflow_gcp_deploy]], [[feedback_1password_access]].
