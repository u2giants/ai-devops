---
name: project_popsg_search_paths
description: "PopSG library search uses a DIFFERENT code path than PopDAM (style_guide_file_groups raw ILIKE, not the dam_search_documents RPCs)"
metadata: 
  node_type: memory
  type: project
  originSessionId: 19eecc5d-4fd8-4df8-b1da-1513b95eb129
  modified: 2026-07-22T23:06:26.015Z
---

PopDAM and PopSG have TWO separate, unrelated library-search implementations. Don't assume a search bug lives in the full-text pipeline.

- **PopDAM library** (assets / style groups): `src/hooks/useAssets.ts` + `src/hooks/useStyleGroups.ts` → RPCs `search_assets_full_text` / `search_style_groups_full_text` over `dam_search_documents` (synonym-aware, `dam_search_synonyms`), with an ILIKE fallback on timeout.
- **PopSG library** (`sg.designflow.app/library`, the "Style Guides" and "Files" tabs): `src/pages/popsg/PopSGLibraryPage.tsx` queries `style_guide_file_groups` / `style_guide_files` with a **raw `.ilike` substring** on `style_guide_name` / `directory_path` / `filename`. It does NOT touch dam_search_documents, the RPCs, or the hooks at all.

Confirm which path a view uses via the browser network tab before editing — a PopSG "0 results" bug is in PopSGLibraryPage, not the RPC layer. (2026-07-22: "spiderman" returned 0 because `%spiderman%` can't match the stored "Marvel Style Guide/Spider-Man/…" path; fixed by reusing `expandFallbackTerms` from `src/lib/dam-search.ts` — synonyms + hyphen/space variants — to OR expanded terms across the columns. `%spiderman%`=0 rows, `%spider-man%`=113.)

Related: [[project_helper_storage_regions]] (style guide files are Seafile/SMB-synced).
