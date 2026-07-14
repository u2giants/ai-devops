---
name: feedback-ag-grid-rules
description: Mandatory AG Grid and coding rules for Designflow — enforced by AGENTS.md and CLAUDE.md
metadata: 
  node_type: memory
  type: feedback
  originSessionId: e7dc7ba5-80be-4882-b2bb-c01db98763e6
---

# AG Grid & Coding Rules

## AG Grid MCP is mandatory for all AG Grid work

**Why:** Multiple production bugs caused by using deprecated/removed AG Grid APIs from memory (userProvidedColDef, columnApi, getRowNodeId — all removed in v31-v35).

**How to apply:** Before every session touching AG Grid code:
1. Call `mcp__ag-grid__set_versions(version: "35.1.0", framework: "angular")` (note: `detect_version` fails due to space in path)
2. Call `search_docs` for every API you're about to use — never write from memory alone

## Unit tests required for all new code

**Why:** Future changes must not break functionality. CI runs tests on every push.

**How to apply:** Add Jest/Jasmine unit tests for every new function in both frontend and backends. Run `yarn test` (frontend) or `npm test` (backends) before every commit. Grep `*.spec.ts` files when changing colDef shapes.

## Pull develop into sandbox-albert before adding code

**Why:** sandbox-albert is a personal branch; develop is the integration branch. Always start from the latest.

**How to apply:** `git fetch origin develop && git merge origin/develop` before writing any new code.

## Never add aggFunc to RFQ grid columns

**Why:** Activates AG Grid Enterprise aggregation pipeline → `params.data` becomes undefined on group rows → all 16 margin calculations break silently. See AGENTS.md §14.

## All async valueSetters must be wrapped in try-catch

**Why:** AG Grid v35 awaits async valueSetters. Uncaught exceptions → rejected Promise → edit silently reverted. See AGENTS.md §11.

## Set cellDataType: false on numericCellEditor columns with string backend values

**Why:** AG Grid infers column type from existing data. String-stored numbers get type 'text'; numericCellEditor returns number; type mismatch fires warning #135 and silently reverts edit before valueSetter is called.

## Never use deprecated APIs

Removed in AG Grid v31-v35:
- `params.column.userProvidedColDef` → use `params.column.getColDef()`
- `columnApi` → merged into `gridApi` in v31
- `getRowNodeId` → use `getRowId` in gridOptions
- `rowSelection: 'multiple'` → use `rowSelection: { mode: 'multiRow' }`
- `enableRangeSelection` → use `cellSelection`

## Use firstValueFrom() not .toPromise()

**Why:** `.toPromise()` is deprecated in RxJS 7+. 75 call-sites migrated in commit `97823a8`.

## No window['anything'] in new code

Use Angular DI. The existing `window['itemService']` in rfq.component.ts is legacy tech debt — do not add more.
