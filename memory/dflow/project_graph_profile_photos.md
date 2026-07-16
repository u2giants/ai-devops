---
name: project_graph_profile_photos
description: "M365/Teams profile photos via Microsoft Graph (app-only) in designflow-backend — built 2026-06-21; User.Read.All already consented + AZURE_CLIENT_SECRET provisioned; activates on next backend deploy"
metadata: 
  node_type: memory
  type: project
  originSessionId: dca4a837-f0a9-4e15-8bc1-b36cec545e10
---

Pulls staff users' Microsoft 365 (Teams/Outlook) profile photos as avatars app-wide. Built 2026-06-21 in **designflow-backend** (commit 4e73bae, branch sandbox-albert). App-only (client-credentials) Graph, keyed by **email** (no oid in this app's model/JWT). Reuses the SSO Azure App Registration (see [[project_azure_sso]]).

Files: `config/graph.config.js` (creds + `isConfigured` gate), `helpers/graph.js` (cached client_credentials token + `fetchUserPhoto(email)` → `GET /users/{email}/photo/$value`, 404→null, never throws), `services/graph-photo.service.js` (fetch+cache to DO Spaces, persist `users.graph_photo`, 7-day throttle via `graph_photo_synced_at`, `effectivePhoto` = upload||graph, `backfillStale`). Wired into `services/user.service.js` getProfile (current user, /api/user/me) and `services/notification.service.js` getMentionableUsers (returns EFFECTIVE photo in the existing `profile_photo` field + bounded background backfill). DB columns `users.graph_photo TEXT` + `graph_photo_synced_at TIMESTAMPTZ` (model + db.js migration + db.migration.test). Uploaded photos always win; vendors skipped (external, not in tenant).

**Prereqs DONE 2026-06-21** (activates on next backend Cloud Build deploy):
1. The app registration is **"dflow alerts"** (appId 8a8695bd-…, SP objectId 7512704e-…). It ALREADY had Graph **application** `User.Read.All` (df021288-bdef-4463-88db-98f22de89214) **admin-consented** (alongside its TeamsActivity roles) — no consent change was needed.
2. Minted a new client secret on that app (displayName `designflow-backend-graph`, `--append` so the existing `TeamsActivity` secret stays valid) and stored it as Secret Manager secret **AZURE_CLIENT_SECRET** v1 in GCP project **lithe-breaker-323913** (the backend's project; also holds DO_ACCESS_KEY/JWT_PRIVATE_KEY). No per-secret IAM needed: `roles/secretmanager.secretAccessor` is granted PROJECT-level to the Cloud Run runtime SA (677598988032-compute@…), deployer@…, and cloudbuild — covers all secrets.

Azure CLI was installed via winget for this (`az` 2.87 at `C:\Program Files\Microsoft SDKs\Azure\CLI2\wbin\az.cmd`); `az login` is interactive so the user runs it (account Albert@popcre.com, tenant 1caeb1c0-…). gcloud authed as u2giants@gmail.com.

If `AZURE_CLIENT_SECRET` is ever blank, `isConfigured` is false and the whole feature no-ops (falls back to uploaded photos / initials) — no errors.

**Why:** the user (u2giants) asked to show "everyone's" M365 photos (comments, mentions, user lists). App-only chosen so the backend can read any user's photo without per-user delegated tokens.
**How to apply / follow-up:** frontend needs NO change for the covered surfaces (current-user avatar via /me, @mention autocomplete) because effective photo is returned in existing fields. NOT yet covered: comment-author avatars and any other UI that shows other users' photos WITHOUT going through getProfile/mentionable-users — those need their payloads to include the user's effective photo (reuse `effectivePhoto`/`graph_photo`). See [[project_notification_system]] for the mention/comment plumbing.
