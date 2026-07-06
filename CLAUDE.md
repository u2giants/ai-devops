# CLAUDE.md — Claude Code notes

**Read [`AGENTS.md`](AGENTS.md) first.** It is the canonical operating guide and
documentation router for this repo. This file only holds Claude Code-specific
notes; it does not repeat AGENTS.md.

## Context / ignore

- `.claudeignore` controls what Claude Code ignores here. Keep it aligned with the
  "What to ignore" section of `AGENTS.md`.
- Do not load every `.md` file. Use the **Documentation map** in `AGENTS.md` to
  pull only the docs a task needs.

## Repo-specific behaviors

- This repo is 100% owned Bash + Markdown. There is no app, database, container,
  or CI/CD — do not go looking for them or scaffold them unprompted.
- The toolkit home is always `/worksp/ai-devops`. Never use `/opt/ai-devops`.
- Real config lives in `/etc/ai-devops/*.env` (never in the repo). Never commit
  real `.env` files or secrets; only `*.env.example` belongs in git.
- Model roles: Opus 4.8 (high reasoning) plans + final-reviews; Opus reviews the
  gates; Codex/GPT-5.5 implements + tests. **Do not mention or use Fable.**

## Commits

- Commit only when asked.
- This repo pushes with a GitHub `@users.noreply.github.com` email (email-privacy
  protection blocks the private gmail address). Keep using the noreply email.
- End commit messages with the `Co-Authored-By: Claude Opus 4.8` trailer.

## SSH / deployment

- There is no deploy automation. Installation is a local operation (`install.sh`)
  run on the target host over an ordinary SSH login. SSH is not a special deploy
  path here.
