# RFQ Page — Corrected Visual Design Spec
## Environment-aware. Mechanism-tagged. Full reskin.

> NOTE: This is the corrected, internally-consistent copy. §2/§4/§5k reflect the confirmed
> environment: the master RFQ grid uses **legacy `ag-theme-alpine`** (all color/typography via a
> `::ng-deep .ag-theme-alpine { --ag-*: … }` block in `rfq.component.scss` — NOT
> `themeQuartz.withParams()`, do NOT edit `grid-themes.config.ts`), and the factory-quote
> sub-grid's confirmed live colIds are **`quote_price`** and **`vendor_note`** (not `price`/`note`).
> `STEP4_CORRECTED.md` is authoritative for the sub-grid.

---

## 1 · Scope

Full visual reskin of the RFQ grid and its chrome to match the approved renderings in
`RFQ Prototype.html`. Every surface, not four targeted features.

---

## 2 · Environment constraints (read before touching anything)

| Constraint | What it means |
|---|---|
| Master grid uses **legacy `ag-theme-alpine`** | All color/typography goes in a `::ng-deep .ag-theme-alpine { --ag-*: … }` block in `rfq.component.scss`. Do NOT edit `grid-themes.config.ts`; do NOT use `themeQuartz.withParams()`. |
| `::ng-deep` works for structural CSS | Heights, borders, seam shadow, cell-class tints — all fine in `rfq.component.scss`. |
| Saved Views override `pinned` defaults | `colDef.pinned='left'` does nothing for users with a saved View. Fix: `gridApi.applyColumnState()` on `firstDataRendered` for identity columns only. |
| `flex` and `sizeColumnsToFit()` conflict | Sub-grid uses `flex:1` on Note column — do NOT also call `sizeColumnsToFit()`. |
| Group-band row is `headerClass` on leaf columns, not a `ColGroupDef` | True collapsible groups require migrating to `ColGroupDef` + `columnGroupShow` (Step 5). |
| Role-based column visibility | `admin` sees all 24 pricing columns; `sales`/`designer` see only "Price for Sales" leaves. Tints must look right in both. |
| Confirmed sub-grid colIds | **`quote_price`**, **`vendor_note`** (NOT `price`/`note`). See `STEP4_CORRECTED.md`. |

---

## 3 · Type system

| Usage | Family | Weights |
|---|---|---|
| UI text, labels, headers, cells | **Hanken Grotesk** | 400/500/600/700 |
| Price codes, numeric figures | **IBM Plex Mono** | 400/500/600 |

Apply Hanken Grotesk via `--ag-font-family`; IBM Plex Mono to code/number cells via `::ng-deep`.

---

## 4 · Replacement block — `::ng-deep .ag-theme-alpine` --ag-* vars

```scss
// rfq.component.scss
::ng-deep .ag-theme-alpine {
  --ag-alpine-active-color: #D81B60;
  --ag-selected-row-background-color: #fff5f8;
  --ag-range-selection-background-color: rgba(216,27,96,0.07);
  --ag-range-selection-border-color: #D81B60;

  --ag-background-color: #ffffff;
  --ag-odd-row-background-color: #fbfcfd;
  --ag-row-hover-color: #fff5f8;

  --ag-foreground-color: #1a202e;
  --ag-data-color: #475569;

  --ag-border-color: #e7e9ee;
  --ag-row-border-color: #eef1f5;
  --ag-border-radius: 0;
  --ag-wrapper-border-radius: 8px;

  --ag-header-background-color: #f7f9fc;
  --ag-header-foreground-color: #475569;
  --ag-header-column-separator-color: #e7e9ee;

  --ag-font-family: "Hanken Grotesk", -apple-system, BlinkMacSystemFont, "Segoe UI", system-ui, sans-serif;
  --ag-font-size: 13px;

  --ag-grid-size: 4px;
  --ag-cell-horizontal-padding: 10px;
}
```

> Density (`rowHeight`) is set via `gridApi.setGridOption('rowHeight', n)` + `resetRowHeights()`, not CSS. See §5i.

---

## 5 · Per-surface spec

Tags: **[--ag-* var]**, **[::ng-deep CSS]**, **[cell renderer]**, **[colDef]**, **[component SCSS]**.

### 5a · 3-row header (group band 36 · column header 48 · floating filter 44 = 128px)

```scss
::ng-deep .grid-wrapper .ag-header-row:first-child { height: 36px !important; }
::ng-deep .grid-wrapper .ag-header-row:nth-child(2) { height: 48px !important; }
::ng-deep .grid-wrapper .ag-header-row-floating-filter { height: 44px !important; }
::ng-deep .grid-wrapper .ag-header-cell-text {
  text-transform: uppercase; letter-spacing: 0.04em; white-space: normal !important;
  line-height: 1.2; -webkit-line-clamp: 2 !important; max-height: 2.4em !important;
}
```

Group-band tints — two families (replaces the 8-color rainbow):

| Family | Band bg | Band text |
|---|---|---|
| General (Gen) | `#dbe7fb` | `#2456b8` |
| Licensed (Lic) | `#e9ddf7` | `#7a3bb8` |

```scss
::ng-deep .ag-header-group-cell.group-band-gen { background:#dbe7fb !important; color:#2456b8 !important; font-weight:600; font-size:11px; letter-spacing:.02em; }
::ng-deep .ag-header-group-cell.group-band-lic { background:#e9ddf7 !important; color:#7a3bb8 !important; font-weight:600; font-size:11px; letter-spacing:.02em; }
::ng-deep .ag-header-cell[class*="group-header-gen"] { background:#eaf1fd !important; .ag-header-cell-text,.ag-header-cell-label{ color:#2456b8 !important; } }
::ng-deep .ag-header-cell[class*="group-header-lic"] { background:#f3ecfb !important; .ag-header-cell-text,.ag-header-cell-label{ color:#7a3bb8 !important; } }
```

### 5b · Data rows

```scss
::ng-deep .grid-wrapper .ag-cell-focus { border:1.5px solid #D81B60 !important; }
::ng-deep .grid-wrapper .ag-row-focus { background:rgba(216,27,96,.06) !important; }
::ng-deep .grid-wrapper .ag-cell.cell-numeric { font-variant-numeric:tabular-nums; font-family:'IBM Plex Mono',ui-monospace,Menlo,monospace; font-size:12.5px; text-align:right; }
::ng-deep .grid-wrapper .ag-cell.cell-strong { color:#1a202e !important; font-weight:600; }
::ng-deep .grid-wrapper .ag-cell.cell-price-code { font-family:'IBM Plex Mono',ui-monospace,Menlo,monospace; font-size:12px; color:#475569; font-weight:500; }
```

### 5c · Row group rows (RFQ Group band) — was `#7f97a1`

```scss
::ng-deep .grid-wrapper .ag-full-width-row, ::ng-deep .grid-wrapper .ag-row-group { background:#eef2f7 !important; border-bottom:1px solid #d4dae3 !important; }
::ng-deep .grid-wrapper .ag-row-group .ag-group-value, ::ng-deep .grid-wrapper .ag-row-group-leaf-indent { color:#1a202e !important; font-weight:700 !important; font-size:12px !important; letter-spacing:.01em; }
```

### 5d · Frozen identity pane — pins + seam

```typescript
// on firstDataRendered
this.gridApi.applyColumnState({
  state: [{colId:'price_code',pinned:'left'},{colId:'pic',pinned:'left'},{colId:'desc',pinned:'left'}],
  defaultState: { pinned: null }, applyOrder: false,
});
```
```scss
::ng-deep .grid-wrapper .ag-pinned-left-header .ag-header-cell:last-child,
::ng-deep .grid-wrapper .ag-header-cell.ag-cell-last-left-pinned { border-right:1.5px solid #d4dae3 !important; box-shadow:4px 0 8px -4px rgba(20,30,50,.18); }
::ng-deep .grid-wrapper .ag-cell.ag-cell-last-left-pinned { border-right:1.5px solid #d4dae3 !important; box-shadow:4px 0 8px -4px rgba(20,30,50,.18); }
::ng-deep .grid-wrapper .ag-row-selected .ag-cell { background:transparent !important; }
```

### 5e · Scenario pricing cells

```scss
::ng-deep .grid-wrapper .ag-cell.scenario-gen { background:#eaf1fd; }
::ng-deep .grid-wrapper .ag-cell.scenario-lic { background:#f3ecfb; }
::ng-deep .grid-wrapper .ag-cell.scenario-gen--sales { background:#e0ecfd !important; font-weight:600; color:#1a202e !important; font-family:'IBM Plex Mono',ui-monospace,Menlo,monospace; font-size:12.5px; text-align:right; }
::ng-deep .grid-wrapper .ag-cell.scenario-lic--sales { background:#ead9f7 !important; font-weight:600; color:#1a202e !important; font-family:'IBM Plex Mono',ui-monospace,Menlo,monospace; font-size:12.5px; text-align:right; }
::ng-deep .grid-wrapper .ag-cell.margin-good { color:#1f9d6b !important; }
::ng-deep .grid-wrapper .ag-cell.margin-warn { color:#c98a08 !important; }
```

### 5f · Status pill   **[cell renderer]** `StatusPillCellRenderer`

```scss
.status-pill { display:inline-flex; align-items:center; gap:5px; padding:2px 8px; border-radius:20px; font-size:11px; font-weight:600; line-height:1.4;
  &__dot{ width:5px; height:5px; border-radius:50%; }
  &--active{ background:#e8f6ef; color:#1f9d6b; .status-pill__dot{ background:#1f9d6b; } }
  &--draft{ background:#fbf2dd; color:#c98a08; .status-pill__dot{ background:#c98a08; } }
  &--inactive{ background:#eef1f5; color:#7b8a9a; .status-pill__dot{ background:#7b8a9a; } } }
```

### 5g · Step indicator   **[cell renderer]** `StepIndicatorCellRenderer`

| Step | Label | Dot |
|---|---|---|
| @sales for details | Sales detail | #6366f1 |
| @sourcing | Sourcing | #0ea5e9 |
| @factories | Factories | #f59e0b |
| px sent to sales | Px → Sales | #10b981 |
| px sent to cust | Px → Customer | #22c55e |
| else | as-is | #7b8a9a |

```scss
.step-indicator { display:inline-flex; align-items:center; gap:6px; font-size:12px; font-weight:500; color:#475569; &__dot{ width:7px; height:7px; border-radius:50%; flex:none; } }
```

### 5h · Re-quote cell
```scss
::ng-deep .price-requested-cell { background:#fdeede !important; color:#e8833a !important; }
```

### 5i · Toolbar + density toggle
```scss
.create-btn { background:#D81B60 !important; border-radius:8px !important; height:36px !important; box-shadow:0 1px 2px rgba(216,27,96,.3) !important; font-weight:600 !important; }
.secondary-btn { border:1px solid #e7e9ee !important; border-radius:8px !important; height:36px !important; color:#475569 !important; mat-icon{ color:#7b8a9a !important; } }
.toolbar-divider { width:1px; height:22px; background:#e7e9ee; align-self:center; }
.density-toggle { display:inline-flex; background:#eef1f5; border-radius:8px; padding:2px; gap:2px;
  button{ height:28px; padding:0 11px; border-radius:6px; border:none; cursor:pointer; background:transparent; color:#7b8a9a; font-size:12.5px; font-weight:500; font-family:inherit;
    &.active{ background:#fff; color:#1a202e; font-weight:600; box-shadow:0 1px 2px rgba(0,0,0,.12); } } }
```
```typescript
density:'compact'|'standard'|'comfortable'='standard';
readonly DENSITY_MAP={ compact:{rowHeight:30}, standard:{rowHeight:36}, comfortable:{rowHeight:44} } as const;
setDensity(d){ this.density=d; this.gridApi.setGridOption('rowHeight',this.DENSITY_MAP[d].rowHeight); this.gridApi.resetRowHeights(); localStorage.setItem('rfq:density',d); }
ngOnInit(){ this.density=(localStorage.getItem('rfq:density') as any)??'standard'; }
// gridReady: this.gridApi.setGridOption('rowHeight', this.DENSITY_MAP[this.density].rowHeight);
```

### 5j · Status bar (custom-status-bar.component.scss)
```scss
:host { display:flex; align-items:center; gap:16px; padding:0 20px; height:40px; font-family:'Hanken Grotesk',system-ui,sans-serif; font-size:12.5px; color:#475569; font-variant-numeric:tabular-nums; background:#fff; border-top:1px solid #e7e9ee; }
.stat-divider { width:1px; height:14px; background:#e7e9ee; flex:none; }
.stat-label { color:#7b8a9a; } .stat-value { color:#1a202e; font-weight:600; }
.pager-btn { width:28px; height:28px; border-radius:7px; border:1px solid #e7e9ee; background:#fff; color:#475569; display:flex; align-items:center; justify-content:center; cursor:pointer; font-size:14px; &:disabled{ opacity:.4; cursor:default; } }
.page-size-select { height:28px; padding:0 8px 0 10px; border-radius:7px; border:1px solid #e7e9ee; background:#fff; font-size:12.5px; color:#1a202e; font-weight:600; cursor:pointer; }
```

### 5k · Factory-quote sub-grid   → SUPERSEDED by STEP4_CORRECTED.md (colIds quote_price/vendor_note)
Container/card SCSS still valid:
```scss
:host { display:block; background:#eef3f9; border-left:3px solid #D81B60; padding:14px 16px 16px; }
.subgrid-header { display:flex; align-items:center; gap:10px; margin-bottom:10px;
  .title{ font-size:12.5px; font-weight:700; color:#1a202e; }
  .count-badge{ font-size:11px; font-weight:600; color:#7b8a9a; background:#fff; border-radius:10px; padding:1px 8px; }
  .summary{ font-size:11.5px; color:#7b8a9a; } }
.action-bar { display:flex; align-items:center; justify-content:space-between; margin-top:12px; .action-left,.action-right{ display:flex; gap:8px; } }
.action-btn { display:inline-flex; align-items:center; gap:6px; height:32px; padding:0 12px; border-radius:8px; border:1px solid #e7e9ee; background:#fff; color:#475569; font-size:12.5px; font-weight:500; cursor:pointer; font-family:inherit;
  &--danger{ border-color:#fbeaea; color:#d64545; } &--primary{ border:none; background:#D81B60; color:#fff; box-shadow:0 1px 2px rgba(216,27,96,.3); font-weight:600; } }
```

---

## 6 · Persistence
- Frozen identity: `applyColumnState` on `firstDataRendered` (§5d).
- Density: `localStorage 'rfq:density'`.
- Scenario group open/closed: saved in GridLayout column state (existing `onSaveLayout`).

---

## 7 · Tokens
```
Brand pink #D81B60 · pink soft #fff5f8 · pink bg #fce4ec
Ink #1a202e · ink-2 #475569 · ink-3 #7b8a9a
Surface #ffffff · canvas #f6f7f9 · zebra #fbfcfd · header #f7f9fc
Border #e7e9ee · border soft #eef1f5 · seam #d4dae3 · seam shadow 4px 0 8px -4px rgba(20,30,50,.18)
Good #1f9d6b/#e8f6ef · warn #c98a08/#fbf2dd · danger #d64545/#fbeaea · re-quote #e8833a/#fdeede
Gen blue: band #eaf1fd / header #dbe7fb / text #2456b8 / dot #3b6fd4 / sales #e0ecfd
Lic violet: band #f3ecfb / header #e9ddf7 / text #7a3bb8 / dot #9d5fd4 / sales #ead9f7
Step dots: details #6366f1 · sourcing #0ea5e9 · factories #f59e0b · px→sales #10b981 · px→cust #22c55e
Density: compact 30 · standard 36 · comfortable 44
Header rows: band 36 · col 48 · filter 44 · Radius 8px
Fonts: Hanken Grotesk 400/500/600/700 · IBM Plex Mono 400/500/600
```

---

## 8 · Recommended sequence
1. Theme vars + ::ng-deep (all cheap items) — one PR
2. Density toggle — one PR
3. Status + Step cell renderers — one PR each
4. Sub-grid flex + detail renderer SCSS (per STEP4_CORRECTED.md) — one PR
5. Collapsible column groups (24 flat cols → 8 ColGroupDef) — last, with role-matrix testing
