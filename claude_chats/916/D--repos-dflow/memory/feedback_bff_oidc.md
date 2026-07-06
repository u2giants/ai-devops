---
name: feedback-bff-oidc
description: "Login broken on sandbox? BFF backend URLs must be .run.app, never custom domains — OIDC audience rule"
metadata:
  node_type: memory
  type: feedback
  originSessionId: e7dc7ba5-80be-4882-b2bb-c01db98763e6
---

# Login broken on Designflow sandbox → check BFF `*_BACKEND_URL` env vars

**If you (Claude / ChatGPT / any AI session) are reading this because the user reported any of:**

- "Microsoft sign-in failed. Please try again."
- "Your session has expired. Please log in again."
- "The access token could not be verified."
- Login worked an hour ago but is broken now, including in incognito and after clearing cookies
- 401 from any backend through the BFF proxy

**…check the BFF env vars before anything else. This has now happened 3+ times (2026-05-26 morning, 2026-05-26 afternoon, …). It is almost certainly the cause again.**

---

## Root cause

The BFF (`designflow-bff`, Cloud Run service `popcre-*-bff-*`) uses `src/backendProxy.js`, which takes the backend URL as **both** the proxy target **and** the OIDC token audience. Cloud Run verifies that audience against the backend service's **`.run.app` URL**. Custom-domain mappings (`api.core.alsand.designflow.app`, etc.) do **not** work as OIDC audiences, even though they route HTTP requests correctly.

So if the BFF's `CORE_BACKEND_URL`, `ITEM_MASTER_BACKEND_URL`, `TRACKING_BACKEND_URL`, or `DATA_SYNC_BACKEND_URL` are set to custom domains, every backend call fails OIDC verification → frontend sees session expired / sign-in failed.

---

## Triage commands (read-only)

Replace `popcre-albert-bff-sandbox` with the right BFF service name for the environment:
- Albert sandbox: `popcre-albert-bff-sandbox`
- Shared sandbox: `popcre-bff-sandbox`
- Production: `popcre-bff-prod`

```bash
# 1. Check the live BFF env vars. All 4 must be .run.app URLs.
gcloud --project=lithe-breaker-323913 run services describe popcre-albert-bff-sandbox \
  --region=us-central1 \
  --format="value(spec.template.spec.containers[0].env)" \
  | tr ';' '\n' | grep _BACKEND_URL

# 2. Also check the Cloud Build trigger substitutions (separate source of drift).
gcloud --project=lithe-breaker-323913 builds triggers describe popcre-albert-bff-sandbox \
  --region=us-central1 --format=yaml | grep _BACKEND_URL
```

If any URL looks like `https://api.*.designflow.app`, that is the bug. They must look like `https://popcre-*-mi7si7t62a-uc.a.run.app`.

---

## Canonical URLs (Albert sandbox)

| Env var | Correct value |
|---|---|
| `CORE_BACKEND_URL` | `https://popcre-albert-backend-sandbox-mi7si7t62a-uc.a.run.app` |
| `ITEM_MASTER_BACKEND_URL` | `https://popcre-albert-item-sandbox-mi7si7t62a-uc.a.run.app` |
| `TRACKING_BACKEND_URL` | `https://popcre-albert-tracking-sandbox-mi7si7t62a-uc.a.run.app` |
| `DATA_SYNC_BACKEND_URL` | `https://popcre-albert-sync-sandbox-mi7si7t62a-uc.a.run.app` |

For shared/prod BFFs, get the canonical URLs by running:
```bash
gcloud --project=lithe-breaker-323913 run services describe <backend-service> \
  --region=us-central1 --format="value(status.url)"
```

---

## Fix (immediate, ~2 min)

Updates the running revision so login works *right now*. Does **not** prevent future drift — see "Permanent fix" below.

```bash
gcloud --project=lithe-breaker-323913 run services update popcre-albert-bff-sandbox \
  --region=us-central1 \
  --update-env-vars="CORE_BACKEND_URL=https://popcre-albert-backend-sandbox-mi7si7t62a-uc.a.run.app,ITEM_MASTER_BACKEND_URL=https://popcre-albert-item-sandbox-mi7si7t62a-uc.a.run.app,TRACKING_BACKEND_URL=https://popcre-albert-tracking-sandbox-mi7si7t62a-uc.a.run.app,DATA_SYNC_BACKEND_URL=https://popcre-albert-sync-sandbox-mi7si7t62a-uc.a.run.app"
```

User retries login → should work within seconds.

---

## Permanent fix (so it stops drifting)

The Cloud Build trigger substitutions live in GCP, **outside the repo**. Every time the BFF is rebuilt, the trigger's `_CORE_BACKEND_URL` (etc.) values overwrite the Cloud Run env vars. If the trigger has bad values, every redeploy re-breaks login.

After fixing the live revision above, also fix the trigger:

```bash
# Pull the trigger config
gcloud --project=lithe-breaker-323913 builds triggers describe popcre-albert-bff-sandbox \
  --region=us-central1 --format=yaml > /tmp/trigger.yaml

# Edit the 4 _*_BACKEND_URL lines to .run.app URLs (use sed or hand-edit)

# Push it back
gcloud --project=lithe-breaker-323913 builds triggers import \
  --region=us-central1 --source=/tmp/trigger.yaml
```

---

## Why this keeps happening

The custom-domain URLs (`api.core.alsand.designflow.app`, etc.) are **what the user sees and naturally types**, and they *do* work for routing HTTP — they only fail OIDC. So anyone manually editing the trigger or env vars in the GCP console tends to "correct" the `.run.app` URLs back to custom domains, thinking the `.run.app` versions are leftover debug values. They are not. Do not change them back.

User-facing custom domain (`https://alsand.designflow.app`) is fine — that's the frontend. The thing that must be `.run.app` is the **BFF-to-backend** URL specifically, because that's where OIDC service-to-service auth happens.

---

## See also

- `designflow-bff/AGENTS.md` §7 "Services" + §9 — full service URL table for all environments
- Incident docs in `designflow-frontend/docs/` — 2026-05-26 first incident write-up
- Albert sandbox commit `ecd279ee` (frontend) was deployed *during* the second drift; was wrongly suspected — frontend changes cannot cause this symptom
