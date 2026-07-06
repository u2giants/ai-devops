# Memory index

- [User: Albert](user-albert.md) — non-programmer owner of dflow PLM; explain in plain language
- [Git commit identity](git-commit-identity.md) — user.* unset; commit via `-c user.name/email`, use the **noreply** email (gmail/popcre → GH007)
- [AG Grid v36 theming](aggrid-v36-legacy-theming.md) — MIGRATED to Theming API (themeAlpine/APP_GRID_THEME); legacy CSS removed; keep .ag-theme-alpine class as styling hook
- [AG Grid version drift](aggrid-version-drift-local-install.md) — local node_modules was 35.2.1 vs repo 36.0.0; always `yarn install` before trusting local tsc/jest
- [dflow delivery workflow](dflow-delivery-workflow.md) — 6 popcre repos, sandbox-albert branch, PR to develop
- [shared-db canonical repo](shared-db-canonical-repo.md) — u2giants/shared-db at C:\repos\shared-db; branch→PR→**main** (not develop); app-owned columns stay as db.js startup migration + a docs note there
- [Codex concurrency incident](codex-concurrency-incident.md) — Codex (approval:never) broke the backend tree during a concurrent sync; don't run two agents on the same repos
- [Sandbox test images](sandbox-test-images.md) — bulk-loaded 4 recycled images onto all 19,202 items; rollback via uuid prefix `e1e10000-`
