# design_handoff_rfq_polish — RFQ page visual reskin

Design package from Claude Design (project "dflow RFQ", file "RFQ Prototype").
Target branch: **albert-2sandbox** (note: repo CLAUDE.md says `sandbox-albert`; per Albert,
the live verification URL https://alsand2.designflow.app/ is tied to `albert-2sandbox`).

## Files
- `SPEC_V2.md` — full corrected reskin spec (legacy `ag-theme-alpine` + `::ng-deep --ag-*`
  block; confirmed sub-grid colIds `quote_price` / `vendor_note`). ✅ Present.
- `STEP4_CORRECTED.md` — factory-quote sub-grid → quote-card spec. ⏳ PENDING export from
  Claude Design (code-dense; must be exported cleanly, not transcribed).
- `RFQ Prototype.html` — visual target. ⏳ PENDING export from Claude Design.

## Hard constraints (from Design)
1. Master grid is legacy `ag-theme-alpine`. Do NOT edit `grid-themes.config.ts`; do NOT use
   `themeQuartz.withParams()`. All grid color/type → `::ng-deep .ag-theme-alpine { --ag-*: … }`
   in `rfq.component.scss`.
2. Frozen identity pins (price_code/pic/desc) via `gridApi.applyColumnState()` on
   `firstDataRendered` — saved Views override `colDef.pinned`.
3. Sub-grid keeps `ag-grid-angular` (factories edit inline) — do NOT replace with HTML.
   Real colIds `quote_price` / `vendor_note`. Never `sizeColumnsToFit()` where a col has `flex`.
4. Do not touch calc logic, fill handle, undo stack, or `getMasterFiledName()`.
5. STEP4 §4.3 `getRowClass`: the placeholder snippet references undefined `ID` and
   `p.data?.isChosen` — wire those predicates to the real live row fields
   (e.g. `p.data?.['Status'] === 'declined'` + the real chosen-vendor flag). CSS class names
   `fq-row--chosen` / `fq-row--declined` are correct.

## Implementation sequence (one commit per step, run specs after each, NO push until Albert says)
1. Alpine theming block in `rfq.component.scss` (SPEC_V2 §4 + §5 cheap items)
2. Density toggle (`rfq.component.ts/.html`)
3. Status & Step pill cell renderers
4. Factory-quote sub-grid as quote card (needs STEP4_CORRECTED.md — pending export)
5. Collapsible column groups (24 flat scenario cols → 8 ColGroupDef)

## Do NOT disturb
Uncommitted "factory bulk offer upload" feature on this branch (see repo HANDOFF.md).
