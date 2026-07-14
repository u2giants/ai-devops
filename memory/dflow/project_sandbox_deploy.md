---
name: project-sandbox-deploy
description: "alsand sandbox deploys are MANUAL (no auto Cloud Build trigger); backend containers gate startup on `npm test` so a hanging/failing test 404s new routes"
metadata: 
  node_type: memory
  type: project
  originSessionId: 309a9af9-b9fa-41f5-8314-b5af13435ebd
---

The **albert sandbox** (alsand, `api.alsand.designflow.app`) runs on GCP project
`lithe-breaker-323913`, region `us-central1`. Cloud Run services:
`popcre-albert-{frontend,backend,bff,item,tracking,sync}-sandbox`.

**Deploys are MANUAL — pushing `sandbox-albert` does NOT auto-deploy.** There are no
GitHub→Cloud Build triggers (the builds that exist are manual `gcloud builds submit`
runs; trigger list is empty). To deploy a service after pushing:
1. Build+push image (Dockerfile takes `--build-arg NODE_ENV=sandbox-albert`; image path
   `us-central1-docker.pkg.dev/lithe-breaker-323913/popcre-albert-sandbox/sandbox-albert/<service>:<tag>`).
2. `gcloud run deploy <service> --image=<img> --region=us-central1` — `--image`-only keeps
   existing env/secrets/SA(`deployer@…`)/vpc-connector(`creatiflow`)/scaling, lowest risk.
   Add a `.gcloudignore` (node_modules is NOT gitignored) so the upload stays lean.

**Recurring trap — backend containers gate startup on the test suite.** Dockerfile `CMD`
is `yarn start:$NODE_ENV`, and every `start:*` script is `npm test && … nodemon index.js`
(item-master, likely tracking/backend too). If `npm test` hangs (jest open handle) or
fails, the `&&` never reaches the server, the container never listens on its PORT, the
Cloud Run startup probe fails (`HealthCheckContainerError`), and **traffic stays pinned to
the previous healthy revision** — so newly-added routes return **404** even though the code
and image are correct. Symptom seen 2026-06-15: item library toast `HTTP 404
/api/item_master/lib/getGridCellNotes` while the route existed in source.

**Triage:** `gcloud run revisions list --service=<svc> --region=us-central1` → look for the
newest revision with STATUS `False`; `gcloud run services describe … --format='value(status.traffic)'`
shows traffic stuck on an older revision; read the failed revision's logs
(`gcloud logging read 'resource.labels.revision_name="…"'`) for the jest "did not exit" line.
**Fix applied:** `test` → `jest --forceExit` in item-master `package.json`. If a future
service has the same hang, do the same (or move the test gate out of the container start).
See [[feedback_branch_pr_flow]] (ship the fix via PR sandbox-albert→develop).
