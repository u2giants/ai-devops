---
name: ai-reviewer
description: >-
  Run a read-only Codex second-opinion review (plan, diff, security, visual, or
  final-check) on the current git repo and save the result under .ai/reviews/.
  Use when the user wants Codex to independently review work without changing any
  files. Scaffolding v0.1.
---

# AI Reviewer (Codex)

Read-only second-opinion reviews from Codex / GPT-5.5, wrapping the toolkit's
`ai-codex-review` command. Reviews **never** edit, commit, push, merge, or
delete anything.

> Status: v0.1 scaffolding.

## When to use

- The user wants an independent Codex review of a plan, a diff, security, visual
  impact, or overall readiness.
- The user explicitly wants a **read-only** pass (no code changes).

## Modes

Run from inside the target git repo:

```bash
ai-codex-review plan-review       # review the current plan
ai-codex-review diff-review       # review the current git diff
ai-codex-review security-review   # security-only review of the diff
ai-codex-review visual-review     # UI/visual-testing considerations
ai-codex-review final-check       # go/no-go readiness check
```

Each run:

- creates `.ai/reviews/` if missing,
- saves output to `.ai/reviews/YYYYMMDD-HHMMSS-<mode>.md`,
- prints the saved file path,
- uses `CODEX_CMD` from `/etc/ai-devops/models.env`
  (default: `codex exec --skip-git-repo-check`).

## Guardrails

- Must be inside a git repo.
- Read-only: no commits, pushes, merges, or deletions.
- Does not read or emit secrets/`.env`/auth files.

## Relationship to the pipeline

This skill covers the Opus/Codex review gates (Stages 02, 04, 06, plus visual and
final checks) of the `ai-development-pipeline` skill, but as an independent Codex
opinion rather than the primary Opus review.
