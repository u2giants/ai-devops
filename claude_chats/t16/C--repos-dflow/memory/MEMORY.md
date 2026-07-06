# Memory Index

- [Project Repos](project_repos.md) — 6 designflow repos cloned to C:\repos\dflow, all on branch sandbox-albert
- [Azure SSO Setup](project_azure_sso.md) — MSAL 5.x popup fix, Azure env vars on all Cloud Run services, redirect URI config
- [Notification System](project_notification_system.md) — Backend endpoints, mention parser, frontend polling service, badge, and notifications page tabs (built 2026-05-21)
- [Vex Toolbar Layout](project_vex_toolbar_layout.md) — Ikaros navigation-height:0 drops in-toolbar nav to a 2nd line; phantom footer reserves 56px at bottom (fixed 2026-06-21)
- [Graph Profile Photos](project_graph_profile_photos.md) — M365/Teams avatars via Microsoft Graph (app-only) in backend; User.Read.All consented + AZURE_CLIENT_SECRET provisioned 2026-06-21; activates on next backend deploy
- [1Password Access](feedback_1password_access.md) — use the scoped MCP (vibe_coding only), NOT the op CLI (full-account, all vaults)
- [E2E Tester Skill](project_e2e_tester_skill.md) — designflow-e2e-tester skill: AI-driven hybrid E2E testing (explore live app + write Playwright regression tests), created 2026-06-26
- [Human Developer](project_human_developer.md) — Uma (GitHub `devopswithkube`) reviews/merges PRs to develop; reach him via GitHub (no Teams/email connector wired)
- [Frontend E2E vs Local Backend](project_frontend_e2e_local_backend.md) — test local frontend against deployed sandbox backend via a localhost CORS proxy (default env); GUI creds in 1Password; sandbox core cold-starts 503
- [Codex Windows Sandbox Fix](reference_codex_windows_sandbox_fix.md) — "codex-windows-sandbox-setup.exe program not found": stage the helper from codex-resources into ~/.codex/.sandbox-bin + current/bin
