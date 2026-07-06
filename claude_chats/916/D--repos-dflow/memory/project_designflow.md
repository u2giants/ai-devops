---
name: project-designflow
description: "Designflow PLM application — 6 repo layout, branch rules, stack, and session workflow"
metadata: 
  node_type: memory
  type: project
  originSessionId: e7dc7ba5-80be-4882-b2bb-c01db98763e6
---

# Designflow PLM — Project Context

All 6 repos cloned to `D:\repos\dflow\` on `sandbox-albert` branch.

**Why:** User works exclusively on sandbox-albert. Never merge or switch branches.

**How to apply:** Always pull latest from `develop` into `sandbox-albert` before adding new code. Push only to `sandbox-albert`.

## Repos & ports

| Repo | Path | Port | Stack |
|------|------|------|-------|
| designflow-frontend | D:\repos\dflow\designflow-frontend | 4200 | Angular 21, AG Grid Enterprise 35.2.1 |
| designflow-bff | D:\repos\dflow\designflow-bff | 5004 | Node/Express proxy to backends |
| designflow-backend | D:\repos\dflow\designflow-backend | 5000 | Node/Express + PostgreSQL + Sequelize |
| designflow-item-master | D:\repos\dflow\designflow-item-master | 5003 | Node/Express + PostgreSQL + Sequelize |
| designflow-tracking | D:\repos\dflow\designflow-tracking | 5002 | Node/Express + PostgreSQL + Sequelize |
| designflow-data-syncing | D:\repos\dflow\designflow-data-syncing | 5001 | Node/Express + PostgreSQL + Sequelize |

## Key frontend files

- `src/app/pages/rfq/rfq.component.ts` — RFQ master grid (~3600 lines)
- `src/app/pages/rfq/helpers/equation.ts` — RFQ margin/sell-price calculations
- `src/app/helpers/ag-grid/rfq-grid/rfq.grid.config.ts` — RFQ column definitions
- `src/app/helpers/services/main.service.ts` — primary API service (~120 methods)
- `AGENTS.md` — authoritative dev guide (read every session)
- `CLAUDE.md` — session guide (AG Grid MCP rules, commit style, test commands)

## Session workflow

1. Read AGENTS.md + CLAUDE.md before any code work
2. Pull develop into sandbox-albert before adding code: `git fetch origin develop && git merge origin/develop`
3. For AG Grid work: call `mcp__ag-grid__set_versions(version: "35.1.0", framework: "angular")` first, then `search_docs` before writing any AG Grid code
4. Run `yarn test` (frontend) or `npm test` (backends) before every commit
5. Commit only to `sandbox-albert`; commit style: `type(scope): description`

## Angular project quirk

Angular project name in `angular.json` is `"vex"` (from Vex template). Do not rename.

## Critical AG Grid rules (from incident log)

- NEVER add `aggFunc` to any RFQ grid column — breaks all valueSetters/valueGetters on group rows
- All new valueSetters must be wrapped in try-catch (async valueSetter rejection cancels edit)
- Set `cellDataType: false` on columns using `numericCellEditor` that store string values in backend
- Never use `params.column.userProvidedColDef` — removed in AG Grid v35; use `getColDef()`
- Never use `.toPromise()` — use `firstValueFrom()` from rxjs
- Never use `window['anything']` in new code — use Angular DI
- Never add `aggFunc` to any column without reading AGENTS.md §11
