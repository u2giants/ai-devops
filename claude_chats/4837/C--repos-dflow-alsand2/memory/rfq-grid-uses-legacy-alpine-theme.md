---
name: rfq-grid-uses-legacy-alpine-theme
description: "The RFQ grid renders with the legacy ag-theme-alpine CSS theme, NOT the AG Grid Theming API"
metadata: 
  node_type: memory
  type: project
  originSessionId: 4f2eb02f-16f7-47ed-be89-b9507eb68d4e
---

The designflow-frontend RFQ grid (`src/app/pages/rfq/`) renders with the **legacy `ag-theme-alpine` CSS theme**, not the v35 Theming API — despite the repo containing `themePink`/`GRID_THEME_CONFIG`/`GridThemeEventsService`.

- `rfq.component.html` `<ag-grid-angular>` uses `class="ag-theme-alpine"` + `[class]="gridClass"`; `gridClass` toggles `ag-theme-alpine` / `ag-theme-alpine-dark` for dark mode (`rfq.component.ts` ~line 381-383).
- `gridOptions` (rfq.component.ts ~line 218) has **no `theme` property**. `GRID_THEME_CONFIG` and `GridThemeEventsService` are imported but unused in the RFQ component.
- AG Grid is 35.3.0 (Theming API is the package default; the legacy class without `theme:'legacy'` is effectively a no-op / error #239).

**Why:** matters for the RFQ polish work (June 2026). The handoff SPEC_V2 §4 assumed the grid uses `themeQuartz.withParams` — it does NOT.

**How to apply:** to restyle the RFQ grid, set CSS variables on `::ng-deep .ag-theme-alpine { --ag-*: ... }` in `rfq.component.scss` plus `::ng-deep` rules on real AG Grid classes. Do NOT edit `grid-themes.config.ts` or write `withParams` expecting visible effect. The detail sub-grid is also on `ag-theme-alpine`. Related: [[rfq-detail-grid-is-server-driven]].
