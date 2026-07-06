# Memory Index

- [Project: CI/CD deploy architecture](project_cicd.md) — Coolify API trigger, no SSH; Coolify app UUID; sg.designflow.app file provider
- [Project: pending work](project_pending.md) — Auto-update cert blockers, PopSG render pass
- [Project: Helper storage by region](project_helper_storage_regions.md) — Brazil=Seafile, USA=SMB edgesynology1, no fallback; region via geolocation+admin panel
- [Feedback: terse responses](feedback_terse.md) — User wants concise output; no trailing summaries
- [Project: DB backfill batching](project_db_backfill_batching.md) — Big single-statement backfills on assets time out/crash compute; batch ~20k
- [Project: git/dist root ownership](project_git_root_ownership.md) — .git & dist revert to root; fix with sudo chown -R ai:ai
- [Project: check-in receipt verification](project_checkin_verification.md) — Seafile verify-on-Synology, deployed DARK behind CHECKIN_VERIFICATION_ENABLED; activation steps
- [Project: bridge self-updater fragility](project_bridge_self_updater.md) — DON'T modify the agent self-updater; invariants + why; detect drift via build_sha instead; KNOWN false-positive "Build mismatch" (env-clone freezes build_sha)
- [Project: Supabase Virginia cutover](project_supabase_virginia_cutover.md) — LIVE project = qsllyeztdwjgirsysgai (Virginia); default mcp__supabase__* still points at OLD Ohio .old (stale-data trap)
- [Project: VPS 1Password/MCP secrets](project_vps_1password_mcp_secrets.md) — vibe_coding vault via vault-scoped op SA in /root/.bashrc; .mcp.json placeholders + op run; MCP→Coolify token mapping; held-docker fix for proxy socket failure
- [Project: PDF backfill processor](project_pdf_backfill_processor.md) — full-library text extraction runs on an on-prem agent (Windows render agent, bridge fallback), not cloud; trigger/total/handover gotchas
- [Project: Style Guide Sources scope](project_style_guide_sources_scope.md) — sku_files_used now only from licensing/tech-pack PDFs; source column; 863 legacy_ungated rows to purge after review
