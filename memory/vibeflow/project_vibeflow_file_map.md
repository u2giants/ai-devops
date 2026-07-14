---
name: VibeFlow key file locations
description: Where to find the important code in the VibeFlow repo
type: project
originSessionId: ae2513cf-1ba3-4085-9ae4-216faa490782
---
**Entry points:**
- `apps/desktop/src/main/index.ts` — app lifecycle, window creation, register*Handlers() calls
- `apps/desktop/src/main/handlers/` — all IPC handlers (one file per domain: auth, projects, modes, sync, tooling, devops, approval, handoff, mcp, memory, verification, secrets, environments, observability, connection-test, etc.)
- `apps/desktop/src/main/handlers/state.ts` — container object with getters/setters for all mutable service refs (localDb, supabase, syncEngine, etc.)
- `apps/desktop/src/preload/index.ts` — window.vibeflow API bridge
- `apps/desktop/src/renderer/App.tsx` — React root + screen routing

**8 Screens:**
- SignInScreen, ProjectListScreen, ProjectScreen, ConversationScreen, ModesScreen, DevOpsScreen, SshScreen, McpScreen

**Key lib code (`apps/desktop/src/lib/`):**
- `storage/local-db.ts` — sql.js SQLite database
- `storage/supabase-client.ts` — Supabase client wrapper
- `sync/sync-engine.ts` — full sync engine
- `orchestrator/orchestration-engine.ts` — OrchestrationEngine with role routing
- `approval/approval-engine.ts` — 6-class risk scoring + second-model review
- `approval/audit-store.ts` — persistent audit history
- `modes/default-modes.ts` — 6 default mode definitions
- `handoff/handoff-generator.ts` — handoff document generation
- `mcp-manager/mcp-connection-manager.ts` — MCP connections
- `secrets/secrets-store.ts` + `secrets/secrets-sync.ts` — secrets + encrypted sync

**Supabase project ref:** `wnbazobqhyhncksjfxvq`

**Why:** Speeds up finding files without exploration.
**How to apply:** Use these paths directly when asked to find or modify specific features.
