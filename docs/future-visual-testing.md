# Future: Visual Testing

Placeholder for the automated visual-testing harness. To be built out when UI
verification is wired into the workflow.

> Not built yet. Design sketch only. The per-repo companion doc is
> `templates/repo-docs/docs-ai-visual-testing.md`.

## Goal

Give the workflow a reliable way to answer: *"Does the UI still look and behave
correctly after this change?"* — automatically, as part of Stage 05 (Test) and
the `visual-review` gate.

## Intended stack

- **Playwright** to drive a real browser and capture screenshots.
- **Visual regression** comparison against committed baselines where practical.
- Runs headless in CI and locally.

## Planned flow

1. Stage 01 plan sets **"Visual testing needed? yes/no."**
2. If yes, Stage 05 runs the Playwright visual suite:
   - key states: default, loading, empty, error, success;
   - viewports: at least one mobile + one desktop.
3. `ai-codex-review visual-review` gives a read-only second opinion on what
   should have been verified.
4. Screenshots/diffs are attached to the PR / completion report.

## Open questions to resolve when building

- Where do baselines live (per-repo `tests/visual/` vs. artifact storage)?
- How are baselines updated safely (avoid rubber-stamping regressions)?
- Which flows are worth automating vs. manual spot-checks?
- How to keep flaky rendering (fonts, animations) from causing false diffs?

## Where it will live

A future `ai-visual-test` helper (and optional Playwright config templates) will
be added to the toolkit. Until then, follow the manual steps in
`templates/repo-docs/docs-ai-visual-testing.md`.
