---
name: merch-group-taxonomy
description: "How Coldlion/DesignFlow/Supabase licensor+property taxonomy works, and the three rules that corrupt data if ignored"
metadata: 
  node_type: memory
  type: reference
  originSessionId: 16e0d2eb-5d8b-4c58-87ac-951ccf1b9cbf
  modified: 2026-07-24T17:08:13.703Z
---

The authoritative account of how licensors, properties, themes, style guides and
artists flow Coldlion ERP → DesignFlow PLM → Supabase `core.*` lives in
`shared-db/docs/merch-group-taxonomy-architecture.md` (shipped 2026-07-19, PR #103).
Read it before touching anything named licensor, property, big/little theme, style
guide, art type/source, artist, age group, or `mgTypeCode`.

Coldlion owns the *vocabulary*, DesignFlow owns the *relationships*, Supabase mirrors
both. Three rules that cause real data corruption when ignored:

1. `mgTypeCode` has NO fixed meaning. `05`=Licensor in CW001/SP001 but "Big Theme" in
   EH001 and "Product Line" in EP001. Resolve via `(divisionCode, mgTypeCode) → mgTypeDesc`.
2. Coldlion has no licensor→property relationship AND no active/inactive flag. Both are
   DesignFlow-owned (`merchGroup.is_active`). A direct Coldlion sync reproduces neither and
   would resurrect dead licenses (NASA/ZAG/FRIDA KAHLO).
3. Merch-group codes are unique only within `(division, mgTypeCode)`. `FR` is a licensor in
   our DB (FRIENDS TV) but a *property* in Coldlion (1ST ORDER TROOPER). Never key on
   `mg_code` alone.

Correcting my own earlier wrong answer: Coldlion DOES have explicit licensors/properties
(22 and 258 in CW001). The "37 PLM vs 20 core" gap is NOT a partial import — 37 staging rows
hold 20 distinct codes; `core.licensor`'s `unique(code)` collapses the division dimension.

Windows traps that cost time: never route Coldlion calls through `bash` (=WSL, drops injected
env → 400 missing X-API-Key); use `op_run shell:powershell`. `cmd.exe` can't expand `%%VAR%%`
loops. `/merchGroupDetails` returns a bare array, not the paged `{content:[...]}` envelope.
The six designflow-* repos are at `C:\repos\dflow\designflow-*` on branch sandbox-albert.

Note (2026-07-24): intervening sessions took over this workstream — see PR #213/#214/#216/#217,
`docs/coldlion-multiphase-fresh-session-spec`, and AGENTS §6.2 ("guarded sync DONE"). The two
outages my HANDOFF flagged 2026-07-19 (PLM sync 502; Coldlion /items 500) are likely resolved
there. Related: [[op-run-mcp-wsl-env-trap]].
