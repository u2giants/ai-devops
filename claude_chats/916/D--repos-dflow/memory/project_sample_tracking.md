---
name: project-sample-tracking
description: "Sample tracking module — a third tracking \"flavor\" added to designflow-tracking + designflow-frontend"
metadata: 
  node_type: memory
  type: project
  originSessionId: b7424fcb-c3bf-4d5b-a132-c1247ee072c2
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

**Photo upload:** DigitalOcean Spaces (`dflowbucket` on sfo3) is wired in tracking
`cloudbuild.yaml` — `DO_ACCESS_KEY`/`DO_SECRET_KEY` via Secret Manager (`deployer@` SA has
project-level secretAccessor), and `DO_ENDPOINT_URL`/`DO_BUCKET_NAME`/`DO_PUBLIC_URL` defaulted
in cloudbuild (same bucket sandbox + prod, so no trigger substitutions needed). Verified live on
`popcre-albert-tracking-sandbox`. NOTE: the auto-mode classifier blocks the agent from editing
shared Cloud Build *triggers*; prefer cloudbuild.yaml repo edits for non-secret deploy config.
