---
name: VibeFlow critical rules and gotchas
description: Must-know rules before touching any VibeFlow code — prevents common crashes and data loss
type: feedback
originSessionId: ae2513cf-1ba3-4085-9ae4-216faa490782
---
Rules that MUST be followed when working on VibeFlow:

1. **No workspace:* deps** — repo is on exFAT, symlinks don't work. Use Vite resolveId plugin + TS paths instead.
2. **Config file must be `electron.vite.config.ts`** — electron-vite requires this exact name.
3. **No `//` in SQL strings** — sql.js parses them as division operators. Always use `--` for SQL comments.
4. **Always pass real userId to listProjects()** — empty string returns zero rows silently.
5. **No duplicate ipcMain.handle() registrations** — Electron crashes at boot with "Attempted to register a second handler".
6. **No `require('./state')` inside function bodies** — Rollup bundles to single file; dynamic local requires crash at runtime. Use static imports + container pattern from `handlers/state.ts`.
7. **Don't remove `removeAllListeners()` from preload** — prevents streaming token duplication bug.
8. **Don't remove `pushConversation()` guard in `acquireLease()`** — load-bearing race-condition fix for FK constraint.
9. **SyncEngine constructor takes authenticated SupabaseClient** — not raw URL+key; RLS requires user session context.
10. **OpenRouter model list must use `/api/v1/models/user`** — `/api/v1/models` returns 349+ models.
11. **Always `git fetch && git merge origin/main --no-edit` before push** — CI auto-bumps version; push will be rejected otherwise. Never use --rebase.
12. **`apps/desktop/src/lib/` is authoritative** — not `packages/` (except shared-types, storage, build-metadata).
13. **ELECTRON_RUN_AS_NODE must NOT be set** — crashes Electron at startup.
14. **OAuth port is 54321** — changing it requires updating Supabase Dashboard redirect URLs.

**Why:** Each of these has caused real production crashes or data loss bugs documented in idiosyncrasies.md and handoff.md.
**How to apply:** Check before any change that touches IPC handlers, SQL, git operations, or sync code.
