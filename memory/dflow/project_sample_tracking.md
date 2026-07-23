---
name: project-sample-tracking
description: "Sample tracking module — a third tracking \"flavor\" added to designflow-tracking + designflow-frontend"
metadata: 
  node_type: memory
  type: project
  originSessionId: b7424fcb-c3bf-4d5b-a132-c1247ee072c2
  modified: 2026-07-23T01:23:49.595Z
---

Sample tracking lets the team track physical samples through a bidirectional pipeline:
factory→Ningbo→NYC (inbound) and USA-bought NYC→Ningbo→factory (outbound), with per-office
check-in/out, photo, quantity, retail price, FOB cost, notes, comments, and factory-group/box grouping.

**Architecture (decided with Albert):** samples are their OWN thin tables (production-style),
NOT itemHeader rows — `itemHeader` is owned by the item-master sync ([[project_designflow]]) so
injecting samples there would pollute the item master. The module reuses the shared **skin
framework** (grid config + cloned `prod_tracking` Angular module) the same way production tracking does.

**Integration goal:** licensing & production should eventually USE this module as the shared
sample service. The `sample` table has nullable link columns `item_id_fk` (→ itemHeader) and
`prod_order_no_fk` (→ ProdOrderHeader). Photos/comments are sample-specific tables (no id collisions).

**Where:** backend `designflow-tracking` — `models/db/sample*.js`, `models/sample*.model.js`,
`helpers/sampleStatus.js` (status state machine), `routes/sample.router.js` (mounted `/sample`,
public path `/api/tracking/sample/*`, BFF forwards it generically). Frontend
`designflow-frontend/src/app/pages/sample_tracking/` (grid + check-in/out + detail dialog with
photos/comments/timeline + box/group dialog), config `helpers/ag-grid/sample.tracking.config.ts`.

**Status:** backend + frontend built, committed AND pushed to `sandbox-albert` in both repos,
**deployed and live on the sandbox site** (sandbox is wired to the `sandbox-albert` branch, not
`develop`). 66 backend jest tests + frontend specs pass, `ng build` clean. PRs open:
designflow-tracking#17 (created), designflow-frontend#104 (existing, updated). Status moves are
derived server-side with an optimistic-concurrency 409 guard.

**Quantity/movement redesign (2026-07-22):** shared-db plan `fix_sample_tracking_schema.md`
(one sample row = a batch; immutable positive movements between normalized typed locations are the
sole quantity authority; conservation 4→4→3→1). Schema landed in `u2giants/shared-db` on `main`
(PR #168, merge `5d20dad`): tables `dflow.sample_movement` (+ BEFORE-INSERT balance-guard trigger
using `pg_advisory_xact_lock(21450,sample_id)`, immutability trigger, `post_sample_movement()`
idempotent RPC), `sample_shipment_line`, `sample_stop_closeout`, `sample_import_job/_row`, box
`owner_factory_id_fk`+`ownership_state`, `sample.quantity_migration_state`, and read views
(`sample_balance_by_location` etc.). Migrations `20260722221000`–`221600`. Behaviorally proven on
preview (conservation, over-allocation reject, idempotency) inside a rolled-back tx.

**CRITICAL landmine fixed:** the block originally used timestamp `20260722220000`, COLLIDING with
the PopSG trigram-index migration. Supabase keys its ledger on the timestamp alone, so production
recorded 220000 as the PopSG migration and SILENTLY SKIPPED the `sample_shipment_item` restore —
so on production `dflow.sample_shipment_item` still does NOT exist and the whole quantity schema
never applied. Fix = re-timestamp to 221000+. **Production was NOT promoted** (needs approved
window); preview has it. Next: production promotion, then the tracking API layer wrapping
`post_sample_movement` (receipts/repack/imports/dashboard), then the web UI (planned for Kimi).

**Photo upload:** DigitalOcean Spaces (`dflowbucket` on sfo3) is wired in tracking
`cloudbuild.yaml` — `DO_ACCESS_KEY`/`DO_SECRET_KEY` via Secret Manager (`deployer@` SA has
project-level secretAccessor), and `DO_ENDPOINT_URL`/`DO_BUCKET_NAME`/`DO_PUBLIC_URL` defaulted
in cloudbuild (same bucket sandbox + prod, so no trigger substitutions needed). Verified live on
`popcre-albert-tracking-sandbox`. NOTE: the auto-mode classifier blocks the agent from editing
shared Cloud Build *triggers*; prefer cloudbuild.yaml repo edits for non-secret deploy config.
