---
name: VibeFlow project overview
description: What VibeFlow is, current state, tech stack, and key architectural decisions
type: project
originSessionId: ae2513cf-1ba3-4085-9ae4-216faa490782
---
VibeFlow is a Windows-first Electron desktop AI IDE for non-programmers. Users talk to an AI Orchestrator that delegates to specialist Modes (Architect, Coder, Debugger, DevOps, Reviewer). Five-panel layout: execution stream (left), conversation (center), code/diff (right), terminal+approval+git (bottom), top bar with build metadata.

**Tech stack:** Electron + TypeScript + React + Vite + Supabase + OpenRouter + sql.js + keytar

**Repo:** `D:\repos\vibeflow` (on exFAT drive — no workspace:* symlinks possible)

**Current version:** 0.1.36 (as of 2026-04-20). All 10 MVP milestones and brownfield rebuild (Components 10–22) complete.

**Key state (2026-04-20):**
- All core features working: OAuth, project CRUD, conversation/streaming, modes, MCP, cloud sync, wizard
- Cloud sync re-enabled 2026-04-18 (16 sync tables + encrypted secrets)
- New Project Wizard (14-step) complete
- Domain tables migrated to Supabase (missions, evidence_items, capabilities, incidents, environments)
- Two-device sync NOT yet validated in practice
- Packaged installer NOT tested on clean machine

**Outstanding tasks (critical):**
1. Test packaged build (electron-builder → NSIS installer)
2. Fix .env loading for packaged builds (app.isPackaged guard)
3. Validate two-device sync
4. Test auto-update end-to-end
5. Wire pnpm test runner (~90+ .test.cjs files exist unwired)
6. Wire domain table push methods in SyncEngine for missions/evidence/capabilities/incidents/environments

**Why:** These are the next logical steps before real-world use.
**How to apply:** When asked what to work on next, reference this list.
