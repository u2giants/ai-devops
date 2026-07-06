---
name: project_vex_toolbar_layout
description: Vex toolbar/layout gotchas in designflow-frontend — Ikaros navigation-height:0 drops in-toolbar nav to a 2nd line; phantom footer reserves bottom space
metadata: 
  node_type: memory
  type: project
  originSessionId: dca4a837-f0a9-4e15-8bc1-b36cec545e10
---

designflow-frontend uses the Vex theme. Active layout is **Ikaros** (`ConfigService.defaultConfig = ConfigName.ikaros`): `vertical`, `boxed`, `navbar.position: 'in-toolbar'`. The nav menu renders inside the 64px `.toolbar` row via `.vex-toolbar-nav` > `<vex-navigation [inToolbar]="true">` > PrimeNG `p-menubar.vex-menubar`. Files: `src/@vex/layout/{toolbar,navigation,layout}/`, config in `src/@vex/services/{config.service.ts,configs.ts}`, app overrides in `src/app/app.component.ts`.

Two non-obvious layout bugs fixed 2026-06-21 (commit 15946727), both diagnosed via live DOM inspection through the Claude-in-Chrome connector (the app is at https://alsand.designflow.app, Azure SSO):

1. **In-toolbar nav rendered as a phantom 2nd line.** Ikaros sets `--navigation-height: 0px` (`_layout-ikaros.scss`), collapsing the nav wrapper to height 0. The menubar (block child) anchored at the wrapper center line and flowed DOWNWARD (top:32→bottom:69), spilling below the 64px toolbar. Fix: `.vex-menubar-in-toolbar { display:flex; align-items:center }` in `navigation.component.scss` to vertically center it. Also tightened item padding/gap so 6 nav items + right-side icons fit one row down to ~1280px.

2. **56px dead space at the bottom of scroll-disabled pages.** The footer is commented out in `custom-layout.component.html`, but `footer.visible` was still true → `has-footer` class on `.page-container` → `scroll-disabled.has-footer .content` subtracts `--footer-height` (56px). Fix: `updateConfig({ footer: { visible: false } })` in app.component.ts.

**Why:** these stem from Vex CSS-variable math + a config flag, not from the page components themselves, so they affect every page, not just Item Library.
**How to apply:** for full-height grid pages, the route needs `data.scrollDisabled: true` (see [[project_repos]]); then the content height = `100% - toolbar - navigation - footer`, so any of those variables being wrong (or a phantom footer) shows as a gap. Inspect computed `top/bottom` rects live before guessing.
