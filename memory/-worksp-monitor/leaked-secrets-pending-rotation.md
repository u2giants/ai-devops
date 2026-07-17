---
name: leaked-secrets-pending-rotation
description: Secrets leaked to public repo 2026-05-29; verified 2026-07-17 — Supabase key rotated (safe), 5 NAS/relay creds STILL LIVE, popdam SSH pw unknown
metadata: 
  node_type: memory
  type: project
  originSessionId: 1d41f339-3928-435c-80ce-4fb67ca9ee35
---

On 2026-05-29 we found live production secrets committed in plaintext to the
public GitHub repo `u2giants/synology-monitor` and redacted them in-repo. Leaked locations found (all redacted):
`apps/relay/RECOVERY_PROMPT.md`, `apps/relay/.env.runtime` (now gitignored),
`scripts/backfill-synobackup.mjs` (hardcoded Supabase service-role key), and —
found during the 2026-05-29 docs pass, missed by the first audit because the
`*.env` grep glob didn't match `*.env.example` — `apps/web/.env.example` and
`deploy/synology/nas-{1,2}.env.example` (real NAS API secrets + signing keys).

**Why:** Redacting the working files does NOT un-leak them — the real values are
still in git history on GitHub and must be treated as compromised.

**Verification (2026-07-17, via Codex on hetz + independent hash re-check):** each
leaked value was compared (by hash, never printed) against the live production
value.

- ✅ **Supabase service-role key — ROTATED.** None of the leaked historical keys
  match production; Coolify web + both NASes carry the current Virginia project
  key (`aaxtrlfpnoutziwhshlt`). No longer exposed. Nothing to do.
- 🔴 **STILL LIVE — never rotated** (leaked value == production value today):
  `NAS_EDGE1/2_API_SECRET`, `NAS_EDGE1/2_API_SIGNING_KEY` (each NAS `.env` +
  Coolify `NAS_EDGE*`), `RELAY_BEARER_TOKEN`, `RELAY_ADMIN_SECRET` (Coolify +
  running relay container). The leaked bearer was confirmed accepted by the live
  NAS 1 API.
- ⚪ **`popdam` NAS SSH password — UNKNOWN.** Not in 1Password; shadow hash not
  readable without sudo; not probed (lockout risk). Assume compromised.

**How to apply:** rotate the 5 STILL-LIVE credentials (owner-driven; separate
rotation plan). Until then, anyone with the old public git history has full NAS +
relay access. Note this leak is COMPOUNDED: the same class of secrets also
appeared in session transcripts committed to the (then public) `u2giants/ai-devops`
repo — purged 2026-07-17, but assume scraped.
