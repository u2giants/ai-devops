---
name: gpt56-reasoning-effort-low-medium-only
description: "Albert's hard rule — GPT-5.6 (Codex) runs at low or medium reasoning effort only, never high, never none/minimal"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 447e7c4f-c037-4597-ac92-00ac693e2fc9
---

**GPT-5.6 (Codex) runs at `low` or `medium` reasoning effort ONLY — never
`high`, never `none`/`minimal`.** Albert's standing directive, given 2026-07-16,
for every machine (Windows and Ubuntu) and every session.

**Why:** Albert's explicit instruction. He has not stated the underlying reason,
so do not invent one — treat it as a hard constraint, not a heuristic to
second-guess. (Worth asking him the rationale if it ever comes up; rules with a
recorded reason survive; this one is currently reason-free by necessity.)

**How to apply:**
- Pass `-c model_reasoning_effort='low'` or `'medium'` **explicitly** on every
  `codex exec` (and on `codex exec resume`). Omitting it is NOT compliant: where
  the config key is unset, an omitted effort starts the run at `none` — observed
  on hetz on 2026-07-16, whose header printed `reasoning effort: none`.
- Read the header Codex prints (`reasoning effort: …`) after launching and kill
  any run that is not low/medium. That is the only reliable check.
- `low` for mechanical grinding, `medium` for anything needing judgement. If a
  task looks like it needs `high`, split it or tighten the brief — never raise
  the dial.
- In `~/.codex/config.toml`, `model_reasoning_effort` must sit **above the first
  `[table]` header** or TOML scopes it into that table and it silently does
  nothing.

Canonical copies live in `u2giants/ai-devops`:
`templates/system/CLAUDE-global.md`, `templates/system/AGENTS-global-codex.md`,
and pinned in the `codex-handoff` / `codex-second-opinion` skills and
`bin/ai-codex-review`. See [[ai-devops-standing-rules-dont-auto-reach-machines]].
