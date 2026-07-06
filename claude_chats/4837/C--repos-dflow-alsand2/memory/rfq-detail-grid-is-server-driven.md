---
name: rfq-detail-grid-is-server-driven
description: "The RFQ detail (factory-quote) sub-grid loads its columns from the backend, not from rfq.detail.grid.config.ts"
metadata: 
  node_type: memory
  type: project
  originSessionId: 4f2eb02f-16f7-47ed-be89-b9507eb68d4e
---

The RFQ factory-quote **detail sub-grid columns come from the backend** via `getGridHeader({ grid_id: 'rfq_detail' })` (`detail-cell-renderer.component.ts:166`), NOT from the in-repo `rfq.detail.grid.config.ts`. Editing that config file has no live effect (AGENTS.md §11; migrating the load path is an open TODO). The live price colId is `price` (legacy), while the config says `quote_price`. `sizeColumnsToFit()` in that renderer is already commented out (~line 748).

By contrast, the **master RFQ grid DOES build from the static `rfq.grid.config.ts`** (`rfq.component.ts:942` spreads `RFQ_COLUMN_HEADERS_CONFIG.columnDefs`), so colDef edits there (cellClass, headerGroupClass, pinned) take effect — modulo saved Views overriding order/pinned.

**Why:** matters for the RFQ polish work (June 2026). Agreed hybrid model for the detail grid: backend owns column order/colIds/visibility; frontend applies a colId-keyed override map (flex, minWidth, type, pinned, cellClass) after the backend load, removes sizeColumnsToFit, and does SCSS polish.

**How to apply:** confirm live `rfq_detail` colIds before any backend reorder. Do detail-grid flex/min-width as a frontend override map keyed by the real colIds, not by rewriting the config file. Related: [[rfq-grid-uses-legacy-alpine-theme]].
