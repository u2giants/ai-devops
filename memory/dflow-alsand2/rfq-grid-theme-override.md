---
name: rfq-grid-theme-override
description: "designflow-frontend grids ignore the [theme] input because a shared service overrides it on gridReady"
metadata: 
  node_type: memory
  type: project
  originSessionId: 4be3a45f-bb9c-4e1e-8bf5-042273170f27
---

In `popcre/designflow-frontend`, binding `[theme]` on `<ag-grid-angular>` does NOT
stick by itself. `GridUISetupService.bootstrap()` (src/@vex/services/grid-ui.service.ts),
called inside every grid's `onGridReady`, runs `gridApi.setGridOption('theme', <global default>)`
(default `quartz` from `GridThemeEventsService`) and re-applies it on every theme-change
event — overwriting the per-grid `[theme]` input.

**Why:** This is why the RFQ Theming-API reskin (themePink) rendered as bare Quartz
(blue accent / IBM Plex Sans) even though the theme was bound and deployed.

**How to apply:** To give one grid a custom theme, re-assert it AFTER
`gridUISetupService.bootstrap(...)` in that component's `onGridReady`:
`this.gridApi.setGridOption('theme', this.rfqTheme)`. The app also still imports the
legacy `ag-theme-alpine` CSS globally, but there is no `provideGlobalGridOptions({theme:'legacy'})`,
so grids default to the v35 Quartz Theming API. RFQ brand theme lives in
`grid-themes.config.ts` (`themePink`). See [[rfq-reskin-spec]].
