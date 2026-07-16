---
name: project_pending_popcre_ddl_guard
description: "PENDING — add the inline-DDL check to the 3 popcre repos' forbid-shared-db-bypass.yml when they're cloned locally"
metadata: 
  node_type: memory
  type: project
  originSessionId: 5398de33-e7ff-49c8-a5a3-1529add38755
---

**PENDING TASK (do this automatically when the repos are available locally).**

The 6 designflow repos have an ENHANCED `forbid-shared-db-bypass.yml` that also
blocks NEW inline SQL DDL added to `.js/.ts` source (e.g. `sequelize.query("ALTER
TABLE …")` in models/db.js). The 3 popcre shared-DB consumers — **popcrm-web,
poppim-web, popdam** — still need that same step added to their existing
`forbid-shared-db-bypass.yml`. They are NOT cloned on this machine yet (disk tight;
Albert delegated them to per-repo AI sessions with a prompt).

**When any of popcrm-web / poppim-web / popdam is cloned onto this machine, do it myself:**
1. In `.github/workflows/forbid-shared-db-bypass.yml`, insert the inline-DDL step right
   after the `scan_files` block. Copy the exact step from a designflow repo's guard
   (e.g. `designflow-backend/.github/workflows/forbid-shared-db-bypass.yml`) — it reuses
   the existing `$base`/`$changed` vars.
2. **Regex is load-bearing:** use `grep -E '^[+]' | grep -vE '^[+][+][+]'` (character
   classes). NOT `^\+`/`^\+\+\+` — in GNU grep `-E`, `\+` is the one-or-more quantifier,
   so `^\+\+\+` strips every added line and the check silently no-ops. See
   [[feedback_all_db_work_via_shared_db]].
3. Verify end-to-end in a throwaway repo before trusting: (a) adding
   `sequelize.query("ALTER TABLE t ADD COLUMN c text")` to a .js file is BLOCKED,
   (b) same commit with `[shared-db-approved]` PASSES, (c) `name: { type: DataTypes.STRING(80) }`
   PASSES (no false positive).
4. These are main-only app repos: commit to main, push, confirm the Action is green.
5. If a repo LACKS `forbid-shared-db-bypass.yml` entirely, it needs the whole guard first
   (bigger drop-in) — flag to Albert.

Goal end state: all 9 shared-DB consumers (6 designflow + 3 popcre) run the identical,
verified guard.
