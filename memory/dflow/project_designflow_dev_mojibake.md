---
name: project_designflow_dev_mojibake
description: designflow_dev schema GridLayout headers were CP437-mojibake corrupted; how to diagnose & re-seed safely
metadata: 
  node_type: memory
  type: project
  originSessionId: 5a54ae0d-6382-4d7b-ae81-92eeb62de3cc
---

The `designflow_dev` Postgres schema (used by `popcre-albert-backend-sandbox`, SCHEMA=designflow_dev) had **CP437 double-encoded mojibake** in `GridLayout` — Chinese RFQ sub-grid headers (grid_id='rfq_detail') stored as `Σ╗╖µá╝...` instead of `价格报价` etc. Chain: UTF-8 → misread as CP437 (US Windows/cmd.exe console codepage) → re-saved as UTF-8.

**Key facts for re-diagnosis:**
- Garbled in DB-sourced AG Grid headers but FINE in hardcoded button labels = data corrupt at rest, not a frontend/connection bug. Server & client encoding are both UTF8.
- The clean source data lives in the **same DB** in schemas `designflow` and `designflow_sandbox` (NOT corrupted). Only `designflow_dev` was hit.
- The `designflow-data-syncing` Cloud Run service is NOT the cause: it runs on Linux (can't make CP437) and its GridLayout model is hardcoded to `schema: 'designflow_sandbox'`. No committed SQL seeds GridLayout.
- Cause = a one-time MANUAL schema bootstrap of designflow_dev via psql/pg_dump through a Windows cmd console at codepage 437. No scheduled job re-corrupts it.

**Scope is schema-wide, not just headers:** a full scan (`designflow-backend/scripts/scan-mojibake-everywhere.js`) found ~35,000+ corrupted rows across 23+ text columns in `designflow_dev` (AuditLog, email_logs, RFQItem, RFQVendor, Factory, vendor, externalVendor, itemHeader, itemAttachment, licensingStatus, merchGroup, users). Affects ALL non-ASCII: Chinese, accented Latin (Décor→D├⌐cor), ©→┬⌐, smart quotes '→ΓÇÖ, fullwidth punctuation, NBSP. `designflow` and `designflow_sandbox` scanned 100% clean.

**Partially fixed (2026-06-05):** Only the 12 visible GridLayout header rows (ids 742-748, 1975-1979, `field` col) were repaired via `iconv.encode(value,'cp437').toString('utf8')`. The other ~35k rows were left as-is pending a decision (full in-place reverse-transform with per-value detection+backup, OR re-seed designflow_dev server-side from clean designflow_sandbox). Also added `client_encoding:'UTF8'` to dialectOptions in both backends' models/db.js (defense-in-depth, not a data fix). Scripts + backup JSON in `designflow-backend/scripts/`. DB access via temporary Cloud SQL authorized-network add for instance `creatiflow-database` (public IP 104.198.220.200, creds in Secret Manager DB_*), restored after.

**Correct way to re-seed designflow_dev (never via Windows console):**
`INSERT INTO designflow_dev."GridLayout" SELECT * FROM designflow_sandbox."GridLayout" ON CONFLICT (id) DO NOTHING;` — pure server-side, never touches a client codepage. If dump/restore on Windows is unavoidable: `chcp 65001` + `set PGCLIENTENCODING=UTF8` + `psql -f file.sql`.

Related: [[feedback_bff_oidc]] (same Cloud Run sandbox stack), [[project_designflow]].
