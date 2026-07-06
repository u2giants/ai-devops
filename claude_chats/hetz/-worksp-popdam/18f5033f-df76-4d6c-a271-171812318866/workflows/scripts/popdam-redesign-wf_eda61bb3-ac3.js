export const meta = {
  name: 'popdam-redesign',
  description: 'Implement PopDAM Library redesign: light/dark theme, new header, control bar, card variants, detail panels',
  phases: [
    { title: 'Foundation', detail: 'CSS tokens, font config, types, appearance hook' },
    { title: 'Header & ControlBar', detail: 'AppHeader redesign, LibraryTopBar → ControlBar' },
    { title: 'Card components', detail: 'StyleGroupGrid variants, AssetGrid, list views' },
    { title: 'Detail panels', detail: 'StyleGroupDetailPanel and AssetDetailPanel redesign' },
    { title: 'Index & wiring', detail: 'Index.tsx + FilterSidebar wiring' },
  ],
}

// ── Phase 1: Foundation ──────────────────────────────────────────────────────
phase('Foundation')

const p1 = await parallel([
  () => agent(`
Read /worksp/popdam/src/index.css (full file).

Then REPLACE the entire file with an updated version that:
1. Keeps the Google Fonts import but ADDS Hanken Grotesk:
   @import url('https://fonts.googleapis.com/css2?family=Hanken+Grotesk:wght@400;500;600;700;800&family=Inter:wght@300;400;500;600;700&family=JetBrains+Mono:wght@400;500;600&display=swap');

2. Keeps all existing @tailwind directives and @layer base rules (the existing HSL variables for Tailwind compatibility).

3. ADDS a new section BEFORE the @tailwind base block with the PopDAM design token system:
   /* ── PopDAM design tokens (light/dark + accent) ─────────────── */
   :root {
     --pd-radius: 10px;
     --pd-radius-sm: 7px;
     --pd-radius-lg: 14px;
     --pd-shadow-sm: 0 1px 3px rgba(0,0,0,.06), 0 1px 2px rgba(0,0,0,.04);
     --pd-shadow-md: 0 4px 12px rgba(0,0,0,.08), 0 2px 4px rgba(0,0,0,.05);
     --pd-shadow-lg: 0 8px 24px rgba(0,0,0,.12), 0 4px 8px rgba(0,0,0,.06);
     --acc-h: 264; --acc-c: .17;
   }
   :root[data-accent="indigo"] { --acc-h: 264; --acc-c: .17; }
   :root[data-accent="teal"]   { --acc-h: 192; --acc-c: .12; }
   :root[data-accent="amber"]  { --acc-h: 64;  --acc-c: .15; }
   :root[data-accent="rose"]   { --acc-h: 12;  --acc-c: .17; }

   :root[data-theme="light"] {
     --pd-bg: oklch(0.984 0.004 255);
     --pd-surface: oklch(1 0 0);
     --pd-surface-2: oklch(0.975 0.004 255);
     --pd-surface-3: oklch(0.955 0.005 255);
     --pd-border: oklch(0.912 0.005 255);
     --pd-border-2: oklch(0.86 0.006 255);
     --pd-fg: oklch(0.265 0.02 265);
     --pd-fg-muted: oklch(0.52 0.016 265);
     --pd-fg-subtle: oklch(0.64 0.013 265);
     --pd-accent: oklch(0.55 var(--acc-c) var(--acc-h));
     --pd-accent-hov: oklch(0.49 var(--acc-c) var(--acc-h));
     --pd-accent-fg: oklch(0.99 0.005 var(--acc-h));
     --pd-accent-soft: oklch(0.955 0.035 var(--acc-h));
     --pd-accent-soft-fg: oklch(0.45 var(--acc-c) var(--acc-h));
     --pd-accent-ring: oklch(0.55 var(--acc-c) var(--acc-h) / .35);
     --pd-licensed: oklch(0.62 0.15 28);
     --pd-licensed-soft: oklch(0.95 0.03 32);
     --pd-success: oklch(0.6 0.13 150);
     --pd-success-soft: oklch(0.94 0.05 150);
     --pd-warning: oklch(0.74 0.14 70);
     --pd-warning-soft: oklch(0.95 0.05 75);
     --pd-info: oklch(0.58 0.13 244);
     --pd-info-soft: oklch(0.95 0.035 244);
     --pd-hdr-bg: color-mix(in oklab, oklch(1 0 0) 82%, transparent);
   }
   :root[data-theme="dark"] {
     --pd-bg: oklch(0.185 0.012 262);
     --pd-surface: oklch(0.225 0.014 262);
     --pd-surface-2: oklch(0.21 0.013 262);
     --pd-surface-3: oklch(0.255 0.015 262);
     --pd-border: oklch(0.305 0.013 262);
     --pd-border-2: oklch(0.37 0.014 262);
     --pd-fg: oklch(0.945 0.005 262);
     --pd-fg-muted: oklch(0.69 0.012 262);
     --pd-fg-subtle: oklch(0.56 0.012 262);
     --pd-accent: oklch(0.72 calc(var(--acc-c) * 0.92) var(--acc-h));
     --pd-accent-hov: oklch(0.78 calc(var(--acc-c) * 0.92) var(--acc-h));
     --pd-accent-fg: oklch(0.18 0.03 var(--acc-h));
     --pd-accent-soft: oklch(0.3 0.06 var(--acc-h));
     --pd-accent-soft-fg: oklch(0.84 0.1 var(--acc-h));
     --pd-accent-ring: oklch(0.72 var(--acc-c) var(--acc-h) / .4);
     --pd-licensed: oklch(0.78 0.13 38);
     --pd-licensed-soft: oklch(0.36 0.08 35);
     --pd-success: oklch(0.74 0.14 152);
     --pd-success-soft: oklch(0.34 0.07 152);
     --pd-warning: oklch(0.8 0.13 72);
     --pd-warning-soft: oklch(0.36 0.07 72);
     --pd-info: oklch(0.72 0.12 244);
     --pd-info-soft: oklch(0.33 0.07 244);
     --pd-hdr-bg: color-mix(in oklab, oklch(0.225 0.014 262) 82%, transparent);
   }

   /* Workflow status tag classes */
   .pd-wf-tag { display: inline-flex; align-items: center; padding: 2px 8px; border-radius: 999px; font-size: 11.5px; font-weight: 600; }
   .pd-wf-in_progress { background: var(--pd-info-soft); color: var(--pd-info); }
   .pd-wf-in_review   { background: var(--pd-warning-soft); color: var(--pd-warning); }
   .pd-wf-approved    { background: var(--pd-success-soft); color: var(--pd-success); }
   .pd-wf-on_hold     { background: var(--pd-surface-3); color: var(--pd-fg-muted); }
   .pd-wf-archived    { background: var(--pd-surface-3); color: var(--pd-fg-muted); }

   /* File type badge colors */
   .pd-ftype-psd { background: oklch(0.42 0.18 260); color: #fff; }
   .pd-ftype-ai  { background: oklch(0.62 0.18 42); color: #fff; }
   .pd-ftype-png { background: oklch(0.5 0.15 155); color: #fff; }
   .pd-ftype-pdf { background: oklch(0.55 0.2 20); color: #fff; }
   .pd-ftype-jpg { background: oklch(0.5 0.13 210); color: #fff; }
   .pd-ftype-tif { background: oklch(0.5 0.16 295); color: #fff; }
   .pd-ftype-default { background: oklch(0.55 0.08 250); color: #fff; }

4. ALSO add a keyframe for pd-pulse and pd-spin:
   @keyframes pd-pulse { 0%,100%{opacity:1} 50%{opacity:.4} }
   @keyframes pd-spin { to{transform:rotate(360deg)} }

Keep all existing content. Just prepend the new token section before @tailwind base.

Write the updated file. This file is at /worksp/popdam/src/index.css.
`, { label: 'css-tokens', phase: 'Foundation' }),

  () => agent(`
Read /worksp/popdam/src/types/assets.ts.

Then EDIT the file to ADD the following new type after the existing LibraryMode type:

export type CardStyle = "gallery" | "editorial" | "compact";

Also update the EXISTING SortField type to add the groups-specific sorts. Currently it is:
  export type SortField = "modified_at" | "file_created_at" | "filename" | "file_size";

Change it to:
  export type SortField = "modified_at" | "file_created_at" | "filename" | "file_size" | "sku" | "asset_count";

These new sort fields are for style groups mode (sku A-Z, file count).

Write the minimal targeted edit using the Edit tool.
`, { label: 'types', phase: 'Foundation' }),

  () => agent(`
Create a new file at /worksp/popdam/src/hooks/useAppearance.ts with this exact content:

import { useState, useEffect } from "react";

export type Theme = "light" | "dark";
export type Accent = "indigo" | "teal" | "amber" | "rose";

function getStored<T extends string>(key: string, fallback: T): T {
  try {
    const v = localStorage.getItem(key);
    return (v as T) || fallback;
  } catch {
    return fallback;
  }
}

export function useAppearance() {
  const [theme, setTheme] = useState<Theme>(() => getStored<Theme>("pd-theme", "light"));
  const [accent, setAccent] = useState<Accent>(() => getStored<Accent>("pd-accent", "indigo"));

  useEffect(() => {
    document.documentElement.setAttribute("data-theme", theme);
    try { localStorage.setItem("pd-theme", theme); } catch {}
  }, [theme]);

  useEffect(() => {
    document.documentElement.setAttribute("data-accent", accent);
    try { localStorage.setItem("pd-accent", accent); } catch {}
  }, [accent]);

  return { theme, setTheme, accent, setAccent };
}

Write this file using the Write tool.
`, { label: 'appearance-hook', phase: 'Foundation' }),

  () => agent(`
Read /worksp/popdam/tailwind.config.ts.

EDIT the fontFamily section (which currently has only "Inter" for sans) to also include "Hanken Grotesk" as the first font:

Find this:
      fontFamily: {
        sans: ["Inter", "system-ui", "sans-serif"],

Replace with:
      fontFamily: {
        sans: ["Hanken Grotesk", "Inter", "system-ui", "sans-serif"],

Use the Edit tool for this targeted change.
`, { label: 'tailwind-font', phase: 'Foundation' }),

  () => agent(`
Read /worksp/popdam/index.html.

EDIT the <head> section to:
1. Add data-theme="light" and data-accent="indigo" to the <html> tag (change \`<html lang="en">\` to \`<html lang="en" data-theme="light" data-accent="indigo">\`)
2. Keep everything else the same.

Use the Edit tool for this targeted change to /worksp/popdam/index.html.
`, { label: 'html-attrs', phase: 'Foundation' }),
])

log('Foundation done. Starting Header & ControlBar...')

// ── Phase 2: Header & ControlBar ────────────────────────────────────────────
phase('Header & ControlBar')

const p2 = await parallel([
  () => agent(`
You are implementing a new AppHeader component for PopDAM, a React+TypeScript+Tailwind app.

Read these files first:
- /worksp/popdam/src/components/AppHeader.tsx (current implementation)
- /worksp/popdam/src/hooks/useAppearance.ts (the new hook you'll use)

Then write the COMPLETE replacement for /worksp/popdam/src/components/AppHeader.tsx with these requirements:

## Design spec
The new header (56px height, sticky, backdrop-blur) has:

**Left side:** brand lockup + nav
- Brand mark: 26×26 rounded square with gradient background (from --pd-accent to --pd-accent-hov), containing a Layers icon, followed by wordmark "Pop" + bold "DAM" (DAM in --pd-accent color)
- Nav links (hidden < 720px): Library (active), Files, Setup, Settings, Downloads
- Active nav: --pd-accent-soft background, --pd-accent-soft-fg text, font-weight 600
- Inactive nav: --pd-fg-muted text, hover shows --pd-surface-2 background

**Right side (gap: 8px):**
1. Sync status pill (rounded-full pill, border, --pd-surface bg): green dot + "Synced" + time ago text. When scanning: amber pulsing dot + "Scanning…". Clicking opens a sync popover.
2. Appearance button (icon-only bordered button): sun icon in light theme, moon in dark theme. Clicking opens appearance menu with Light/Dark theme toggle and 4 accent color swatches (Indigo, Teal, Amber, Rose).
3. Notifications bell button (icon-only)
4. Avatar (30px circle, --pd-accent-soft bg, user initials)

## Props to ADD (appearance):
The component should call useAppearance() internally to get theme/accent/setTheme/setAccent.

## Sync status:
The component currently receives props for agent status (scanRunning, lastScanTime, etc.) via useAgentStatus() and useScanLifecycle() hooks, but those are in Index.tsx. For the header redesign, keep the existing header props interface but MOVE the bridge/agent status display into the new sync pill format.

Actually: the AppHeader should NOT take scan props. The scan state is managed in Index.tsx and passed via the LibraryTopBar. The AppHeader header should:
- Use useAgentStatus() to get bridge status (as the sync status pill content)
- Show "Syncing…" with pulsing dot when bridge is scanning OR bridge is offline show "Offline" with red dot
- When bridge is online and not scanning: show "Synced" with green dot + last sync time
- The popover shows bridge details (same as current popover but styled as per design)

## Key implementation notes:
- Use lucide-react for icons: Layers, Sun, Moon, Bell, X, RefreshCw, CheckCircle2
- Use CSS custom properties (var(--pd-accent), var(--pd-surface), etc.) for colors in inline styles or cn() classes
- Keep the impersonation banner (if impersonatedRole exists, show banner at top)
- Keep the mobile hamburger + Sheet for nav
- Keep the user dropdown (avatar button → DropdownMenu with sign out, impersonation)
- Keep useAgentStatus(), useUserProfile(), useIsAdmin(), useImpersonation() hooks
- The appearance popover: Light/Dark segmented control + 4 color swatch buttons
- The sync popover: bridge status, stats (last sync, files checked, new ingested, errors), sync now button, link to diagnostics
- Keep the build stamp (hidden, lg:inline)

## Style approach:
Since we're mixing Tailwind with new CSS vars, use inline styles for color values from the new token system (var(--pd-accent), etc.) and Tailwind for layout/spacing. The header itself uses:
  style={{ background: 'var(--pd-hdr-bg)', backdropFilter: 'blur(14px)', borderBottom: '1px solid var(--pd-border)' }}

The brand mark gradient:
  style={{ background: 'linear-gradient(140deg, var(--pd-accent), var(--pd-accent-hov))' }}

Nav link active:
  style={{ background: 'var(--pd-accent-soft)', color: 'var(--pd-accent-soft-fg)' }}

Avatar:
  style={{ background: 'var(--pd-accent-soft)', color: 'var(--pd-accent-soft-fg)' }}

Sync pill:
  style={{ background: 'var(--pd-surface)', border: '1px solid var(--pd-border)' }}

Write the COMPLETE new file at /worksp/popdam/src/components/AppHeader.tsx.
Keep all existing functionality (impersonation, user dropdown, mobile nav) — this is only a visual redesign.
The file should TypeScript-compile cleanly (no unused imports, all props typed).
`, { label: 'app-header', phase: 'Header & ControlBar' }),

  () => agent(`
You are implementing a redesigned LibraryTopBar (ControlBar) for PopDAM, a React+TypeScript+Tailwind app.

Read these files first:
- /worksp/popdam/src/components/library/LibraryTopBar.tsx (current implementation, read it fully)
- /worksp/popdam/src/types/assets.ts (for types)

The new design consolidates the library controls into ONE unified horizontal bar.

## New interface requirements

The LibraryTopBar component should keep its existing props interface but ADD:
- cardStyle: CardStyle (from @/types/assets — "gallery" | "editorial" | "compact")
- onCardStyleChange: (v: CardStyle) => void
- Also add: groupCount: number (total style groups count)
- fileCount: number (total files count across all groups)

The existing props to KEEP unchanged:
- search, onSearchChange, viewMode, onViewModeChange, libraryMode, onLibraryModeChange
- sortField, onSortFieldChange, sortDirection, onSortDirectionChange
- filtersOpen, onToggleFilters, activeFilterCount, totalCount, totalAssets
- scanRunning, scanStale, scanQueued, scanPending, onSync, onStopScan, onRefresh
- scanCurrentPath, lastScanStatus, lastScanTime, lastScanSummary
- scanBlocked, scanBlockedReason

## New layout (left → right, wrapping):
1. Filters button: SlidersHorizontal icon + "Filters" text + count badge if active. Active/open = accent-soft background
2. Mode segmented control: "Style groups" (Layers icon) / "All files" (File icon)
3. Search input (flex: 1 1 220px, min 150px, max 340px): leading search icon, grows to fill space, clear × when non-empty
4. Result count: "**N** groups · **M** files" in groups mode; "**N** files" in all-files mode (tabular nums, flex none, margin-left auto)
5. ──── divider ────
6. Card-layout dropdown: ONLY shown when libraryMode=groups AND viewMode=grid. Button shows current style icon + label + chevron. Dropdown: Gallery / Editorial / Compact with check on active.
7. Sort dropdown button + sort-direction icon button (joined, no gap between)
8. View segmented control: Grid icon / List icon

## Sort options:
Groups mode: "Last modified" (modified_at), "Date created" (file_created_at), "SKU (A–Z)" (sku), "File count" (asset_count)
Files mode: "Last modified" (modified_at), "Date added" (file_created_at), "Name (A–Z)" (filename), "File size" (file_size)

When switching modes, if current sort is not in the new valid list, reset to modified_at.

## Styling:
Bar itself: 12px top/bottom padding, 18px left/right padding, border-bottom with pd-border.
Use var(--pd-surface), var(--pd-border), var(--pd-accent), var(--pd-accent-soft), var(--pd-fg), var(--pd-fg-muted) for colors.
Use inline styles for pd-token colors.
Use lucide-react icons: SlidersHorizontal, Layers, File, Search, X, LayoutGrid, List, ChevronDown, ArrowUp, ArrowDown, Check.
Use shadcn Popover for sort dropdown and card-layout dropdown (or simple controlled div with onOutsideClick logic).

Keep the scan status display from the existing toolbar (the ScanMonitorBanner in index.tsx handles the banner, but the toolbar still shows minimal scan state info in the filters button area or not at all — just remove the separate scan section of the old toolbar, that now lives in the header's sync pill).

The sync button in the old toolbar (Trigger Scan) — KEEP it as a small icon-only button on the right side of the toolbar, before the view controls. Icon: RefreshCw, disabled when syncDisabled.

Write the COMPLETE new file at /worksp/popdam/src/components/library/LibraryTopBar.tsx.
All TypeScript should be clean with no unused imports.
Import CardStyle from "@/types/assets".
`, { label: 'control-bar', phase: 'Header & ControlBar' }),
])

log('Header & ControlBar done. Starting card components...')

// ── Phase 3: Card Components ─────────────────────────────────────────────────
phase('Card components')

const p3 = await parallel([
  () => agent(`
You are implementing the redesigned StyleGroupGrid component for PopDAM (React+TypeScript+Tailwind).

Read these files:
- /worksp/popdam/src/components/library/StyleGroupGrid.tsx (current, read fully)
- /worksp/popdam/src/hooks/useStyleGroups.ts (StyleGroup interface, first 50 lines)
- /worksp/popdam/src/types/assets.ts (CardStyle type)

Implement the complete new /worksp/popdam/src/components/library/StyleGroupGrid.tsx with THREE card variants.

## StyleGroup data mapping
- sku → g.sku
- is_licensed → g.is_licensed
- licensor_name → g.licensor_name
- property_name → g.property_name
- product_category → g.product_category
- workflow_status → g.workflow_status
- asset_count → g.asset_count
- thumbnail_url → g.thumbnail_url
- cover_description → g.cover_description
- updated_at → g.updated_at (for relative time)

For the hue/color of placeholder thumbnails: derive from SKU hash (use charCodeAt sum mod 360).
For initials: first 2 uppercase chars of (property_name or sku).

## WfTag component (define inside the file)
Maps workflow_status to colored badge:
- in_progress → pd-info-soft/pd-info
- in_review → pd-warning-soft/pd-warning  
- approved → pd-success-soft/pd-success
- on_hold → pd-surface-3/pd-fg-muted
- archived → pd-surface-3/pd-fg-muted
Display labels: "In progress", "In review", "Approved", "On hold", "Archived"

## LicensedBadge component
Shows "🔒 Licensed" with --pd-licensed-soft bg + --pd-licensed text when is_licensed=true
Shows "Generic" with --pd-surface-3 bg + --pd-fg-muted text when false

## Thumbnail placeholder (when no thumbnail_url)
A div with aspect ratio matching the card style, background gradient based on hue, with a large initials monogram in the center (muted color, large font). Use:
  background: \`linear-gradient(135deg, oklch(0.75 0.06 \${hue}), oklch(0.65 0.09 \${hue}))\`
  color: \`oklch(0.45 0.08 \${hue})\`

## Three card variants:

### Gallery (default, 4:3 thumbnail):
\`\`\`
[4:3 thumbnail or placeholder]
  top-left: LicensedBadge
  bottom-right: glass badge "N files" (semi-transparent bg, text)
[Meta section, p-3 flex col gap-1.5]
  mono SKU (13.5px/700, pd-fg)
  sub line "Licensor · Property" (13px, pd-fg-muted)
  description (13px, pd-fg-subtle, 1 line clamp)
  row: WfTag + "3mo ago" (auto margin left)
\`\`\`

### Editorial (1:1 thumbnail with dark gradient overlay):
\`\`\`
[1:1 thumbnail/placeholder]
  dark gradient overlay (bottom → transparent at top)
  top-left: LicensedBadge  
  top-right: glass badge "N files"
  bottom: mono SKU (white, 12px/600) + property name (white, 15px/700, truncate)
[Meta row, p-2.5 flex row between]
  left: "Category · Customer" (pd-fg-muted, 12.5px)
  right: WfTag
\`\`\`

### Compact (horizontal layout):
\`\`\`
[78px-wide thumbnail strip, left side]
[Meta, right side, p-2.5 flex col gap-1]
  mono SKU (13px/700)
  sub line (12.5px, pd-fg-muted)
  row: WfTag + "N files" (auto margin left, 12px mono)
\`\`\`

## Card shell for all variants:
- bg: var(--pd-surface)
- border: 1px solid var(--pd-border)
- border-radius: var(--pd-radius-lg) = 14px
- hover: translateY(-2px), shadow-md (var(--pd-shadow-md)), border-color: var(--pd-border-2)
- selected: border-color: var(--pd-accent), box-shadow: 0 0 0 3px var(--pd-accent-ring)
- transition: all 0.14s

## Grid
\`\`\`
display: grid;
grid-template-columns: repeat(auto-fill, minmax(var(--card-min, 232px), 1fr));
gap: 12px;
padding: 18px;
\`\`\`
card-min: 232px (gallery), 208px (editorial), 280px (compact)

## StyleGroupGrid component props:
- groups: StyleGroup[]
- selectedIds: Set<string>
- onSelect: (id: string, event: React.MouseEvent) => void
- isLoading: boolean
- cardStyle: CardStyle (import from @/types/assets)
- rebuildHint?: boolean

## Helper: relative time
function timeAgo(iso: string | null): string — converts ISO date to "3mo ago", "2d ago", etc.

## Loading state
Show skeleton cards (animated pulse) while isLoading and no groups.

Write the complete new file at /worksp/popdam/src/components/library/StyleGroupGrid.tsx.
Use TypeScript, import CardStyle from "@/types/assets", import StyleGroup from "@/hooks/useStyleGroups".
Use cn() from @/lib/utils for class merging.
Use inline styles for pd-token colors.
`, { label: 'style-group-grid', phase: 'Card components' }),

  () => agent(`
You are implementing the redesigned AssetGrid component for PopDAM (React+TypeScript+Tailwind).

Read these files:
- /worksp/popdam/src/components/library/AssetGrid.tsx (current, read fully)
- /worksp/popdam/src/types/assets.ts (Asset type)

Implement the complete new /worksp/popdam/src/components/library/AssetGrid.tsx.

## Design: File cards with type-tinted thumbnails

Each file card:
\`\`\`
[4:3 type-tinted thumbnail or real preview]
  top-left: colored file-type badge (squared, e.g. "PSD" in purple, "AI" in orange, etc.)
  top-right: "superseded" glass badge (if file is superseded / not the current version)
  bottom-right: "no preview" glass badge (if no preview available)
[Meta section, p-2.5 flex col gap-1]
  mono filename (13px/600, pd-fg, truncate)
  "Licensor · Property" (12.5px, pd-fg-muted, truncate) — if no licensor: just property
  row: mono SKU (11px, pd-fg-subtle) + file size (auto margin left, 12px, pd-fg-muted)
\`\`\`

## File type colors (for the tile background and badge):
- psd: oklch(0.42 0.18 260) — dark purple
- ai:  oklch(0.62 0.18 42)  — orange
- png: oklch(0.5 0.15 155)  — teal green
- pdf: oklch(0.55 0.2 20)   — red-orange
- jpg: oklch(0.5 0.13 210)  — blue
- tif: oklch(0.5 0.16 295)  — violet
- default: oklch(0.55 0.08 250) — slate blue

## Thumbnail placeholder (when no preview)
A div with aspect-ratio 4/3 and the file-type tint color as background (lighter version):
  background: \`linear-gradient(135deg, oklch(0.78 0.08 \${h}), oklch(0.68 0.12 \${h}))\`
where h is the hue for the file type. Show large file type text in center (muted, light color).

## Card shell: same as style group cards (pd-surface, pd-border, pd-radius-lg, hover lift, selected border+ring)

## Grid: same pattern, card-min: 208px

## Asset data mapping (from Asset type / Tables["assets"]):
- filename → a.filename
- file_size → a.file_size (number, format as "42 MB", "1.2 GB", etc.)
- mime_type → derive type from mime_type (e.g. "image/x-photoshop" → "psd", "application/pdf" → "pdf", "image/jpeg" → "jpg", "image/png" → "png", "image/tiff" → "tif", "application/postscript" or "application/illustrator" → "ai")
- preview_url → a.preview_url (if exists, use as thumbnail src)
- is_current_version → a.is_current_version (or null → treat as true)

For licensor/property info: the Asset type may not have licensor_name directly. Use whatever fields ARE in the Asset type from the current AssetGrid.tsx implementation.

## Component props:
- assets: Asset[]
- selectedIds: Set<string>
- onSelect: (id: string, event: React.MouseEvent) => void
- onOpenDetail: (id: string) => void
- isLoading: boolean

## Loading state: skeleton cards with animated pulse

Write the complete new file at /worksp/popdam/src/components/library/AssetGrid.tsx.
TypeScript only, use cn() from @/lib/utils, inline styles for pd-token colors.
`, { label: 'asset-grid', phase: 'Card components' }),

  () => agent(`
You are implementing the redesigned StyleGroupListView for PopDAM (React+TypeScript+Tailwind).

Read:
- /worksp/popdam/src/components/library/StyleGroupListView.tsx (current, read fully)
- /worksp/popdam/src/hooks/useStyleGroups.ts (first 45 lines for StyleGroup type)

Implement the complete new /worksp/popdam/src/components/library/StyleGroupListView.tsx.

## List view design (CSS grid rows):

Header row columns: Art | SKU / Property | Category | Workflow | Files

Each data row:
- Art: 52×40px thumbnail (real image or placeholder with initials), border-radius 6px
- SKU / Property: SKU in mono 700 weight 13px + property_name in 12px pd-fg-muted below (licensor · property if licensed)
- Category: product_category with a small "Lic" or "Gen" badge (pill, colored)
  - "Lic": --pd-licensed-soft bg, --pd-licensed text, 10px/700
  - "Gen": --pd-surface-3 bg, --pd-fg-muted text, 10px/700
- Workflow: WfTag (same as grid — in_progress/in_review/approved/on_hold/archived with colored pills)
- Files: number, right-aligned, mono, pd-fg-muted

## Row styling:
- bg: transparent (hover → var(--pd-surface) + border-radius)
- selected: var(--pd-accent-soft) bg
- height: ~52px
- columns: "52px 1fr minmax(140px,220px) minmax(100px,150px) 50px"
- gap: 12px, padding: 8px 18px
- border-bottom: 1px solid var(--pd-border) (or use rows with gap)

## Header row:
- sticky at top
- bg: var(--pd-surface-2) / border-bottom: var(--pd-border)
- text: 11px/700 uppercase letter-spacing .06em, pd-fg-subtle
- same column grid

## Thumbnail placeholder:
Same hue-based gradient as grid view (from sku hash), with initials overlaid

## Props:
- groups: StyleGroup[]
- selectedIds: Set<string>
- onSelect: (id: string, event: React.MouseEvent) => void
- isLoading: boolean
- rebuildHint?: boolean

Include WfTag helper inside the file (same logic as StyleGroupGrid).

Write the complete new file at /worksp/popdam/src/components/library/StyleGroupListView.tsx.
Use TypeScript, cn() from @/lib/utils, inline styles for pd-token colors.
`, { label: 'group-list', phase: 'Card components' }),

  () => agent(`
You are implementing the redesigned AssetListView for PopDAM (React+TypeScript+Tailwind).

Read:
- /worksp/popdam/src/components/library/AssetListView.tsx (current, read fully)

Implement the complete new /worksp/popdam/src/components/library/AssetListView.tsx.

## List view design:

Header columns: Type | Filename | Style group | Size | Modified

Each row:
- Type: colored file-type badge (36×28px, rounded 6px) — same colors as AssetGrid
  PSD=purple, AI=orange, PNG=teal, PDF=red, JPG=blue, TIF=violet
- Filename: mono filename (600/12.5px, truncate) + "current version" or "superseded" below (11px pd-fg-subtle)
- Style group: SKU in mono 11.5px on top + property/licensor below in pd-fg-muted (both truncate)
- Size: mono 12px pd-fg-muted
- Modified: right-aligned 12px pd-fg-muted, relative time

## Column grid: "40px 1.8fr 1.2fr .7fr .7fr"
## Row height: ~48px
## Same row hover/selected styling as group list view

## File type classification from mime_type:
Same logic as AssetGrid — derive extension from mime_type.

## File size formatting:
Bytes → KB/MB/GB readable string.

## Props: same as current (assets, selectedIds, onSelect, isLoading)

Write the complete new file at /worksp/popdam/src/components/library/AssetListView.tsx.
`, { label: 'asset-list', phase: 'Card components' }),
])

log('Card components done. Starting detail panels...')

// ── Phase 4: Detail Panels ───────────────────────────────────────────────────
phase('Detail panels')

const p4 = await parallel([
  () => agent(`
You are implementing the redesigned StyleGroupDetailPanel for PopDAM (React+TypeScript+Tailwind).

Read these files COMPLETELY:
- /worksp/popdam/src/components/library/StyleGroupDetailPanel.tsx (current, read FULLY — it's ~1273 lines)

Then implement the complete new /worksp/popdam/src/components/library/StyleGroupDetailPanel.tsx.

## Design spec (from README):

**Panel: 408px wide, right border, slides in (0.26s cubic-bezier(.22,.61,.36,1) transform)**

### Hero (16:10 aspect ratio)
- Full-width thumbnail (or placeholder with hue-based gradient + initials)
- top-left: licensed/generic badge
- top-right: glass close button (×)
- bottom-left (over image): show category label in small glass badge

### Title block (below hero, p-4)
- Mono SKU (13px/600, pd-fg-muted)
- Property name (19px/800, pd-fg)
- Row: WfTag + "Category · Stage" text (pd-fg-muted, 12.5px)

### Sticky tabs (position sticky, backdrop blur):
- Overview | Files · N | Activity
- Active tab: underline in pd-accent color, 600 weight

### Overview tab content:
- "DETAILS" section label (11px/700 uppercase, pd-fg-subtle)
- Definition list (dl/dt/dd): Licensor, Property, Customer, Program, Modified, Created
  dt: pd-fg-muted 12.5px; dd: pd-fg 13px, right-aligned
- "LOCATION" section label + mono path block (pd-surface-2 bg, pd-border border, rounded-lg, 11.5px mono, word-break: break-all)
- Workflow status (if not already shown in title)

### Files tab (each file row):
- Colored file-type tile (same colors as AssetGrid) 36×36 rounded
- Filename (mono 13px/600) + size + "preview ready"/"no preview" + "superseded" badge if applicable
- Download icon button on right

### Activity tab:
- Vertical timeline (avatar circle + connector line)
- Show: stage moves, auto-sync events, approvals, creation

### Footer (sticky at bottom):
- "Download all" accent button (flex-1)
- Share icon button
- Open-folder icon button

## Key behaviors to KEEP from existing implementation:
- useQuery for loading style group assets
- Download functionality (existing useAdminApi + download logic)
- Copy path buttons
- Open folder URI logic
- Existing workflow status display
- Tag management
- All the real data (not mock data)

## Styling:
- Panel: width 408px, height 100%, overflow hidden, display flex flex-col
- Border-left: 1px solid var(--pd-border)
- bg: var(--pd-surface)
- Slide-in animation: transform translateX, transition 0.26s cubic-bezier(.22,.61,.36,1)
- Use @media prefers-reduced-motion to disable animation

## IMPORTANT: Keep all existing functional logic. Only redesign the visual presentation.
- The existing panel has complex functionality (download, copy, open folder, tags, activity, workflow management)
- Preserve ALL of that — just re-skin the visual layout to match the new design

Write the complete new file at /worksp/popdam/src/components/library/StyleGroupDetailPanel.tsx.
TypeScript only. No unused imports. Preserve all existing hooks and functionality.
`, { label: 'group-detail', phase: 'Detail panels' }),

  () => agent(`
You are implementing the redesigned AssetDetailPanel for PopDAM (React+TypeScript+Tailwind).

Read these files COMPLETELY:
- /worksp/popdam/src/components/library/AssetDetailPanel.tsx (current, read FULLY — ~677 lines)

Then implement the complete new /worksp/popdam/src/components/library/AssetDetailPanel.tsx.

## Design spec:

**Panel: 408px wide, same shell as StyleGroupDetailPanel**

### Hero (16:10)
- Type-tinted placeholder thumbnail (large file type text centered, lighter hue gradient)
- OR real preview image if available
- top-left: large file-type badge (38×38 rounded-9px)
- top-right: glass close button

### Title block (p-4)
- Mono filename (16px/700, word-break: break-all)
- Row: "Current version" (success-soft pill) or "Superseded" (surface-3 pill) + "TYPE · size" (12.5px pd-fg-muted)

### "BELONGS TO STYLE GROUP" card (clickable, inside the scrollable content):
- Tinted monogram thumbnail (46×46, rounded-9px)
- "BELONGS TO STYLE GROUP" label (10.5px/700 uppercase, pd-fg-subtle)
- SKU in mono 700/13px
- "Licensor · Property" (12px, pd-fg-muted, truncate)
- ChevronRight icon on right
- Click → navigates to parent style group (calls onOpenGroup(groupId))
- Background: var(--pd-surface-2), border: var(--pd-border), rounded-lg, hover lifts slightly

### File details (dl):
Type, Size, Dimensions (if available), Resolution (if available), Workflow, Stage, Customer, Program, Modified, Added

### Location path block (same as group detail)

### Footer:
- "Download" accent button (flex-1)  
- Copy path icon button
- Open folder icon button

## IMPORTANT: Keep all existing functional logic:
- Download functionality
- Open folder URI
- Copy path
- Any other existing functionality from AssetDetailPanel.tsx

The new prop to ADD:
- onOpenGroup: (groupId: string) => void — called when user clicks "Belongs to style group" card

Write the complete new file at /worksp/popdam/src/components/library/AssetDetailPanel.tsx.
TypeScript only. No unused imports. Keep all existing hooks and real data logic.
`, { label: 'asset-detail', phase: 'Detail panels' }),
])

log('Detail panels done. Starting Index + FilterSidebar wiring...')

// ── Phase 5: Index & FilterSidebar ──────────────────────────────────────────
phase('Index & wiring')

const p5 = await parallel([
  () => agent(`
You are updating the main Index.tsx for PopDAM's Library page to wire in the new cardStyle state and the new prop interfaces.

Read the current /worksp/popdam/src/pages/Index.tsx COMPLETELY.

Then make these targeted edits:

1. ADD import: import type { CardStyle } from "@/types/assets"; at the top with other type imports.

2. ADD state: const [cardStyle, setCardStyle] = useState<CardStyle>("gallery"); — add it after the viewMode state line.

3. UPDATE the LibraryTopBar props to include:
   - cardStyle={cardStyle}
   - onCardStyleChange={setCardStyle}
   - groupCount={totalGroupCount ?? 0}
   - fileCount={isGroupsMode ? (totalGroupCount ? groups.reduce((s, g) => s + (g.asset_count || 0), 0) : 0) : (assetData?.totalCount ?? 0)}
   
   Note: the fileCount prop name in LibraryTopBar may be different from totalAssets. The totalAssets prop (already passed) represents total files across all groups. Keep passing totalAssets as-is, just ADD the new props.

4. UPDATE StyleGroupGrid usage to pass cardStyle={cardStyle}.

5. UPDATE AssetDetailPanel usage: it now needs onOpenGroup prop. Add:
   onOpenGroup={(groupId) => {
     handleLibraryModeChange("groups");
     setDetailGroupId(groupId);
   }}

6. UPDATE the sort field handling: the new LibraryTopBar supports "sku" and "asset_count" sort fields. The existing sort fields are already typed in types/assets.ts (you updated that in another task). The sortField state should use the updated SortField type. Just make sure the sortField state and handlers still work.

Write only the targeted edits using the Edit tool (not a full file rewrite). Read the file first, then apply 5-6 targeted edits.
`, { label: 'index-wiring', phase: 'Index & wiring' }),

  () => agent(`
You are implementing a visual refresh of the FilterSidebar for PopDAM (React+TypeScript+Tailwind).

Read /worksp/popdam/src/components/library/FilterSidebar.tsx COMPLETELY.

The sidebar needs a visual refresh to match the new design token system, but its LOGIC must remain identical.

Changes to make:
1. Sidebar container: change to use var(--pd-surface) bg, var(--pd-border) border-right, 214px width
2. Header: "Filters" title with filter icon (filled accent), active count subtext, "Clear" ghost button + close ×
3. Facet sections: collapsible (keep existing collapse logic), with:
   - Section header: icon + title + selected count pill (accent) + chevron that rotates when collapsed
   - Section content: facet rows
4. Facet rows: 16px rounded checkbox (filled accent when on), color swatch (for workflow), label (truncate), right count
5. Overall: use var(--pd-fg), var(--pd-fg-muted), var(--pd-border), var(--pd-accent), var(--pd-accent-soft), etc.
6. The Licensed/Generic toggle buttons in the Licensing section should use the accent-soft style when active

The logic (filter state, toggles, clear, counts) stays EXACTLY the same — only styling changes.

Key style targets using inline styles:
- Sidebar: style={{ width: 214, borderRight: "1px solid var(--pd-border)", background: "var(--pd-surface)" }}
- Section headers: style={{ color: "var(--pd-fg)", fontWeight: 600, fontSize: 13.5 }}
- Facet row checkbox: style={{ width: 16, height: 16, borderRadius: 4, border: "1.5px solid var(--pd-border)", background: checked ? "var(--pd-accent)" : "transparent" }}
- Count pill: style={{ color: "var(--pd-fg-subtle)", fontSize: 12 }}
- Active filter count badge: style={{ background: "var(--pd-accent-soft)", color: "var(--pd-accent-soft-fg)" }}

Keep ALL the existing imports, hooks, and data-fetching logic.
Keep the existing component structure (FilterSidebarProps interface, etc.).
Only update the visual rendering (JSX classes and styles).

Write targeted edits to /worksp/popdam/src/components/library/FilterSidebar.tsx using the Edit tool.
Focus on the JSX structure and classes — the component logic stays the same.
If the changes are too pervasive (every className changes), rewrite the full file but preserve all logic.
`, { label: 'filter-sidebar', phase: 'Index & wiring' }),
])

log('All phases complete.')
return { done: true, phases: ['Foundation', 'Header & ControlBar', 'Card components', 'Detail panels', 'Index & wiring'] }
