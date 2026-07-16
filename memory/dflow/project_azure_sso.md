---
name: project-azure-sso
description: "Azure SSO setup for Designflow — MSAL 5.x popup fix, env vars set on all Cloud Run services, Azure AD redirect URIs"
metadata: 
  node_type: memory
  type: project
  originSessionId: 8d1a043c-37b7-4685-8947-4d70b4a49bb7
---

## Azure SSO is fully configured as of 2026-05-21

**Azure AD App Registration values (same across all environments):**
- `AZURE_CLIENT_ID`: `8a8695bd-e701-4d30-a5fe-96a2d2cc962b`
- `AZURE_TENANT_ID`: `1caeb1c0-a087-4cb9-b046-a5e22404f971`

**Frontend fix (committed ~2026-05-21, branch `sandbox-albert`):**
- MSAL Browser 5.x requires a dedicated redirect bridge page for popup flow
- Created `src/assets/auth-redirect.html` that loads `msal-redirect-bridge.min.js` and calls `broadcastResponseToMainFrame()`
- `angular.json` copies `msal-redirect-bridge.min.js` from `node_modules/@azure/msal-browser/lib/redirect-bridge` → build output `assets/`
- `azure-sso.service.ts` sets `PopupRequest.redirectUri` to `window.location.origin + '/assets/auth-redirect.html'`

**Backend env vars — set on ALL Cloud Run services in project `lithe-breaker-323913` (us-central1):**
`AZURE_CLIENT_ID` and `AZURE_TENANT_ID` were set on all 15 backend services:
- `popcre-albert-backend-sandbox`, `popcre-albert-bff-sandbox`, `popcre-albert-item-sandbox`, `popcre-albert-sync-sandbox`, `popcre-albert-tracking-sandbox`
- `popcre-bff-prod`, `popcre-bff-sandbox`, `popcre-core-prod`, `popcre-core-sandbox`
- `popcre-item-prod`, `popcre-item-sandbox`, `popcre-sync-prod`, `popcre-sync-sandbox`
- `popcre-tracking-prod`, `popcre-tracking-sandbox`

**Azure AD redirect URIs that need to be registered** (add `/assets/auth-redirect.html` for each env):
- `https://alsand.designflow.app/assets/auth-redirect.html` ✅ (already added)
- `https://app.designflow.app/assets/auth-redirect.html`
- `https://sandbox.designflow.app/assets/auth-redirect.html`
- `http://localhost:4200/assets/auth-redirect.html`

**Why:** MSAL 5.x changed popup flow to use a BroadcastChannel bridge. The old `/login` redirect URI loaded the full Angular app which never called `broadcastResponseToMainFrame()`, so the auth code was never relayed back to the parent window.

**How to apply:** When troubleshooting SSO in other environments, check (1) redirect URI is registered in Azure AD, (2) backend service has `AZURE_CLIENT_ID` + `AZURE_TENANT_ID` env vars, (3) `auth-redirect.html` is present in the build output.
