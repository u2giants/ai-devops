---
name: feedback-branch-pr-flow
description: "Albert's git workflow — sync develop into sandbox-albert before new code, ship via PR to develop, in both repos"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: ef9660ab-2c3b-4a4e-b8b3-493d852d262c
---

For both `designflow-frontend` and `designflow-backend` (and likely the other repos): before adding new code to `sandbox-albert`, first pull/merge the latest `origin/develop` into `sandbox-albert`, then write the code on top. Ship the work by opening a PR from `sandbox-albert` → `develop` (use `gh pr create --base develop --head sandbox-albert`). Always include unit tests for new functions (see [[feedback_ag_grid_rules]]).

**Why:** Albert asked for exactly this flow on 2026-05-29 (price_sales_snapshots feature): "pull the latest changes from develop into sandbox-albert, then start adding your code" and "create a PR for sandbox-albert with develop". The repos' own CLAUDE.md and [[project_designflow]] still say "sandbox-albert only, never merge" — when asked, Albert chose to do the develop→sandbox-albert merge but **leave that rule text unchanged**, so the docs intentionally conflict with this practice.

**How to apply:** When starting work, `git fetch origin` then merge `origin/develop` into `sandbox-albert` (confirm first if there are conflicts or uncommitted work). Commit feature + docs, push `sandbox-albert`, open the PR to `develop`. Backend changes accidentally made on the `develop` branch should be moved to `sandbox-albert` (stash → checkout → pop). Do not edit the "never merge" wording in CLAUDE.md/AGENTS.md unless Albert says so.
