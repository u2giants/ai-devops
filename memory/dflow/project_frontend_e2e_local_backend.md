---
name: project_frontend_e2e_local_backend
description: How to run designflow-frontend E2E/live browser tests locally against the deployed sandbox backend (CORS proxy workaround + credentials)
metadata: 
  node_type: memory
  type: project
  originSessionId: 294695cb-8090-4f57-a06f-1c460336d9df
---

To E2E-test **local** designflow-frontend changes you need a reachable backend. Options and gotchas (learned 2026-07-03):

- **No local backend by default.** The default `environment.ts` points at `localhost:5000/5001/5002/5003` (core/data_sync/tracking/item_master) — nothing listens there unless you run the whole microservice stack.
- **Deployed sandbox backend** = `https://api.alsand.designflow.app/api/{core,tracking,item_master,data_sync}` ("alsand" = albert sandbox, matches branch `sandbox-albert`). `environment.sandbox.ts` points at it. But serving the local frontend with `--configuration sandbox` fails: the sandbox backend **rejects CORS** from `http://127.0.0.1:4200` (no `Access-Control-Allow-Origin`).
- **Workaround that works:** serve the frontend with the **default** config (localhost ports) and run a tiny Node CORS proxy on 5000–5003 that forwards to `api.alsand.designflow.app/api/*` and injects permissive CORS headers + handles OPTIONS. Auth is a **Bearer token in `localStorage`** (`user-auth.interceptor.ts`), not httpOnly cookies, so a transparent forwarding proxy just works. (Reusable proxy script lived in the session scratchpad as `cors-proxy.mjs`.)
- **Cold starts:** the sandbox core service scales to zero and returns **503** on first hit (e.g. `POST /api/core/findUserLoginInfo`); retry a few times to warm it before logging in.
- **Login creds** for the UI: 1Password (vibe_coding vault) item **"designflow PLM frontend gui access credentials"** (`devopswithkube@gmail.com`) — same human, [[project_human_developer]]. Read via the scoped 1Password MCP, [[feedback_1password_access]]. E2E specs read `E2E_EMAIL`/`E2E_PASSWORD` from env (git-ignored `e2e/.env.e2e` or inline); never commit them.
- **Item detail route** = `/apps/itemDetail/:item` where `:item` is the internal item id (read a `.ag-row[row-id]` from the Item Library grid to get a real one).

**Why:** live browser verification of frontend-only changes is otherwise blocked by CORS/backends.
**How to apply:** default-config `ng serve` + CORS proxy → warm the backend → log in with the 1Password creds. Relates to [[project_e2e_tester_skill]].
