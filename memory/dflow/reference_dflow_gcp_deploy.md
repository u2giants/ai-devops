---
name: reference-dflow-gcp-deploy
description: "dflow deploys — correct GCP project, region, and gcloud flags for verifying Cloud Build/Cloud Run (avoids the global-vs-regional trap)"
metadata: 
  node_type: memory
  type: reference
  originSessionId: 0aae37df-4f92-41a9-96ad-2cc806c63d5e
---

DesignFlow (dflow) frontend + services deploy via **Cloud Build → Docker → Cloud Run** in GCP.

- **Project:** `lithe-breaker-323913` — this is the ONLY dflow GCP project. (An old `dflow-plm` name is bogus/empty and not in use; if you see it anywhere it's stale — ignore/remove it.)
- **Region:** `us-east4`. Cloud Build triggers/builds are **2nd-gen regional**, and Cloud Run services live here too.
- **Always pass both flags** to gcloud: `--project=lithe-breaker-323913 --region=us-east4`. Without `--region`, `gcloud builds triggers list` returns `[]` and `gcloud builds list` shows only stale global/1st-gen builds — this misleads you into concluding "no triggers / not deployed via Cloud Build," which is WRONG.
- **`sandbox-albert` IS auto-deployed via Cloud Build** on push. Triggers include `popcre-albert-frontend-sandbox` (+ bff/core/item/sync/tracking, and `*-sandbox2`). Cloud Run service `popcre-albert-frontend-sandbox` serves the sandbox frontend; deploys done by SA `deployer@lithe-breaker-323913.iam.gserviceaccount.com`.

Verify a deploy:
- Recent builds for a branch: `gcloud builds list --project=lithe-breaker-323913 --region=us-east4 --limit=5 --format="value(id,status,createTime,substitutions.BRANCH_NAME,substitutions.SHORT_SHA)"`
- Live revision + deploy time: `gcloud run services list --project=lithe-breaker-323913 --filter="metadata.name=popcre-albert-frontend-sandbox" --format="value(metadata.name,region,status.latestReadyRevisionName,status.conditions[0].lastTransitionTime)"`
- CI builds the **PR-merge commit** (head merged onto develop), so the image tag's SHA won't equal your commit SHA. Confirm inclusion with `git merge-base --is-ancestor <yourSHA> <mergeSHA>`.

Tooling: **yarn is not on PATH** on this machine — use `corepack yarn …` (e.g. `corepack yarn test --testPathPatterns="itemDetail"`).

Related: [[project_repos]], [[project_dflow_local_frontend_testing]].
