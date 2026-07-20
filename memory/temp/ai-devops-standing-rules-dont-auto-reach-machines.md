---
name: ai-devops-standing-rules-dont-auto-reach-machines
description: "A new standing rule added to ai-devops templates does NOT reach any machine automatically — skills overwrite, instruction files never do"
metadata: 
  node_type: memory
  type: project
  originSessionId: 447e7c4f-c037-4597-ac92-00ac693e2fc9
---

Adding a standing rule to `templates/system/CLAUDE-global.md` (or the Codex
`AGENTS-global-codex.md`) in `u2giants/ai-devops` does **not** put it on any
machine. `bin/ai-install-skills` **overwrites skills** but **seeds global
instruction files only if absent** — it prints a diff hint and moves on.

**Why:** the guard is deliberate (each machine's live `CLAUDE.md` carries its own
machine-atlas section and hand edits, which an overwrite would destroy). The
side effect is that every standing rule reaches exactly the machine it was
written on, and Albert reasonably believes it is everywhere. Distribution is
also pull-based and manual — nothing pushes; a machine updates only when someone
says "sync my dotfiles" there.

**How to apply:** after adding a rule to a template, (1) append it to the live
`~/.claude/CLAUDE.md` / `~/.codex/AGENTS.md` on every machine you can actually
reach (append-only — never rewrite those files), and (2) tell Albert which
machines still need "sync my dotfiles". As of 2026-07-16 the `sync-dotfiles`
skill has a **step 4** that makes a sync carry missing rule sections across, so
reachable-by-sync is now the norm — but only for machines where someone runs it.

Reachable from a t16 session: t16 itself, and `hetz` over SSH (`ssh vps`, then
`sudo -u ai -H` — never run git as root there). NOT reachable: 916, 4837, and
the other Ubuntu boxes (seafile, CompShop, backrest) — those need Albert.

See [[gpt56-reasoning-effort-low-medium-only]], the rule that exposed this.
