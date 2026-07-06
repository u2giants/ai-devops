# AI Agent Roles

This document defines who does what in the staged AI coding workflow. Drop it
into an application repo's docs when onboarding.

## The models

| Model | When it is used | It never… |
|-------|-----------------|-----------|
| **Opus 4.8 (high reasoning)** | Implementation planning, architecture review, final product/architecture review | edits code during planning/review |
| **GPT-5.5 / Codex** | Implementation, testing, fixing | expands scope or refactors unrelated code |
| **Opus** | Independent review at every gate (plan, diff, security, final) | edits code during a review |

## The stages

1. **Plan** — *Opus 4.8 high reasoning* writes the implementation plan.
2. **Plan review** — *Opus* approves / approves-with-changes / blocks the plan.
3. **Implement** — *GPT-5.5 / Codex* makes the smallest safe change + tests.
4. **Diff review** — *Opus* reviews the git diff for correctness/regressions.
5. **Test** — *GPT-5.5 / Codex* runs and fixes tests (and visual checks).
6. **Security review** — *Opus* reviews for auth/data/secret issues only.
7. **Final review** — *Opus 4.8 high reasoning* signs off and summarizes for
   Albert.

## Guardrails that apply to every stage

- Feature branches only — never work directly on `main`/`master`.
- No secrets in code or logs. No weakening of auth/permission checks.
- Reviews are read-only. Implementation stages add/adjust tests.
- Any plan deviation is reported, not hidden.
