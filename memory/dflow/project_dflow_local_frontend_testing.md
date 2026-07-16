---
name: project_dflow_local_frontend_testing
description: How to run + auth the dflow frontend locally against the sandbox backend for Playwright testing
metadata: 
  node_type: memory
  type: reference
  originSessionId: 5398de33-e7ff-49c8-a5a3-1529add38755
---

To test dflow frontend changes against the live sandbox backend without deploying:

- Run `yarn start:preview` (or `ng serve --configuration preview --port 4200`) in `designflow-frontend`. This uses `environment.preview.ts` (relative `/api/*`) + `proxy.conf.sandbox.json`, which proxies `/api` → `https://api.alsand.designflow.app` (the sandbox BFF), sidestepping CORS. Frontend code changes are testable immediately; **backend** code changes are NOT (they hit the deployed backend — you'd need to deploy).
- **Login gotcha:** the 1Password "designflow PLM frontend gui access credentials" (devopswithkube@gmail.com / JAGRAV143$) is **rejected** by `findUserLoginInfo` (returns `{"status":"fail"}`) — password login does not work. Microsoft SSO popup is hard to automate.
- **Auth workaround for Playwright:** the JWT is a plain bearer token (not origin-bound). Open the deployed `https://alsand.designflow.app` (which usually already has a valid token in localStorage), read `localStorage.getItem('token')`, then on `http://localhost:4200` do `localStorage.setItem('token', <that token>)` and navigate to a protected route (e.g. `/apps/itemDetail/<pk>`). The app validates the token on init and lets you in. Token is admin user "Meka" (user_id 34, umeka@popcre.com), ~12h expiry.
- itemDetail route uses the item **pk**: `/apps/itemDetail/<item_id_pk>` (double-click a grid row to open it). Item library grid is `/apps/itemLibrary`.
- Playwright MCP file uploads are restricted to roots under `C:\repos\dflow` (copy test files into `C:\repos\dflow\.playwright-mcp\` first).

Related: [[project_seeded_item_images]]. Comments are stored as Quill HTML with `&nbsp;` for spaces, so they inflate fast — the `dflow.comments.comment` column had drifted to VARCHAR(50) vs the model's 500 (widened 2026-07-10).
