---
name: project-e2e-tester-skill
description: designflow-e2e-tester skill — AI-driven hybrid E2E testing of the DesignFlow app
metadata: 
  node_type: memory
  type: project
  originSessionId: 066441db-ef01-4a07-83c6-cd5135ddb8ab
---

User-level skill `designflow-e2e-tester` created 2026-06-26 at
`C:\Users\ahazan2\.claude\skills\designflow-e2e-tester\` (SKILL.md + references/frontend-ui.md +
references/backend-api.md). Hybrid: explores the live app in a browser like a human to hunt bugs AND
writes durable Playwright regression tests into `designflow-frontend/e2e` (POM pattern). Covers the
Angular frontend (UI via browser MCP / Playwright) and the Node microservice APIs through the BFF
(`/api/<service>/<path>`, service map: core/item_master/tracking/data_sync, x-api-key auth).

**Why:** Manual regression testing of every flow was tedious and error-prone; user wanted AI to test
"as a human would" and hit every nook and cranny.

**How to apply:** Triggers on requests like "test my changes", "test the app like a human", "QA this",
"did I break anything". Login: 1Password item "designflow PLM frontend gui access credentials"
(`devopswithkube@gmail.com`, admin-level) — never hardcode. App URLs: sandbox-albert = `alsand.designflow.app`
(API `api.alsand.designflow.app`), sandbox = `sandbox.designflow.app`, prod = `designflow.app`. Drive via
Claude-in-Chrome MCP. RFQ math oracle = `designflow-frontend/docs/rfq-math.md` + read live grid data via
`window.ng.getComponent(document.querySelector('ag-grid-angular')).api`.

**Skill is mirrored across ALL 6 designflow repos** at `.claude/skills/designflow-e2e-tester/` (committed on
sandbox-albert), so Claude Code auto-discovers it in any of them — keep the copies in sync if edited.
Findings/plan archived at `designflow-frontend/docs/qa/e2e-{findings,fixing-plan}-2026-06-26.md`; an AGENTS.md
incident-log entry (2026-06-26) summarizes the audit. NOTE: designflow-frontend upgraded to **AG Grid v36.0.0**
(was 35.x) — verify installed version before asserting it; local `node_modules` drift vs package.json recurs and
breaks `ng serve` until `yarn install`. Local E2E vs the deployed API needs a dev-server proxy bridge (BFF CORS
blocks localhost origin).

**Fixes 2026-06-26:** Fixed bugs via parallel file-disjoint subagents (worktree isolation unavailable —
cwd `C:\repos\dflow` isn't a git repo; used disjoint file-ownership instead). 11 commits on `sandbox-albert`
in designflow-frontend (blockers S1+I1, groups C/E/F/B/D/H, backlog S2+A5+I4-fe) + designflow-backend
(comment 503 → clean 500, `035c254`) + designflow-item-master (licensing backend, `313e9da`). ALL PUSHED
2026-06-26 → Cloud Build deploys to alsand. Live-verified S1, I1, S3, S4, S5, RFQ Gen FOB calc (22/22, no
regression); rest covered by green Jest suite (670/670) + tsc. Local-verify needs a temporary dev-server proxy bridge because the
deployed BFF CORS blocks a localhost origin (serve with `--configuration sandbox --proxy-config`, env URLs
set relative, reverted after). Backlog: A/S2 sample auto-refresh, comment-503 backend, AG Grid license key,
non-admin login for role testing, L1 transition rules (product input).

**Audit 2026-06-26:** First full hybrid audit done. Findings → `C:\repos\dflow\E2E-FINDINGS.md`; remediation
→ `C:\repos\dflow\E2E-FIXING-PLAN.md`. ~9 live-confirmed bugs (2 blockers: Sample grid 0px [S1], Request
Quote empty-dialog soft-lock [I1]); Gen FOB sell-price math verified correct (R1). Dominant theme = silent
HTTP-failure (action looks OK, data lost). R3 (RFQ cell accepts letters) was a FALSE POSITIVE — grid uses
numericCellEditor. OPEN: role testing needs a NON-admin test login (none exists in vault yet); R1b GenMDDP
outlier (13.88 vs 1.81) to investigate; test row `E2E-TEST-RENDER-CHECK delete me` left in Sample Tracking.
See [[project-repos]] and [[feedback-1password-access]].
