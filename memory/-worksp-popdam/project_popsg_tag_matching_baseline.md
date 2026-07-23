---
name: project_popsg_tag_matching_baseline
description: "PopSG licensor/property tag matching — baseline coverage from live prod (2026-07-23), why exact matching leaves a big unmatched tail"
metadata: 
  node_type: memory
  type: project
  originSessionId: f1d3fceb-a8d0-49d6-9506-4b7ffb2ca08b
  modified: 2026-07-23T17:01:18.519Z
---

Baseline measured 2026-07-23 against LIVE prod `qsllyeztdwjgirsysgai` (Virginia) via
Supabase CLI access token → Management API `/database/query` (supabase MCP was
unauthorized; op CLI + 1Password MCP both lacked permission on this machine — the
CLI token is the working path). See [[project_secret_access_paths]].

Context: PopSG deterministic file-tagging ([[project_popsg_search_paths]]) links
`style_guide_files.licensor_name`/`property_folder` to the `licensors`/`properties`
tables. Position in the folder tree is UNRELIABLE (varies folder to folder), so the
worker resolves by exact normalized value match, not by depth. `style_guide_tagging_state`
is NOT yet in prod — the tag pipeline is unmerged/pre-deploy work.

Scale: 216,472 active files; licensors table has only **10** rows; properties **500** rows.

Exact-match coverage baseline (normalize = lower, drop apostrophes, non-alnum→space, collapse):
- licensor present 216,472 / **unmatched 106,516 (49%)**
- property present 216,256 / **unmatched 179,976 (83%)**

Licensor unmatched is a SHORT head — only 16 distinct values. Mostly real licensors
under a different label: `WB`(40k)→Warner Bros (alias), `NBC UNIVERSAL`(26k)→NBCUniversal
(space diff), `Marvel Style Guide`(15k)→Marvel (extra words). The rest are licensors
genuinely MISSING from the 10-row table: Star Wars, One Piece, Aardman, Sesame Workshop,
NFL, NASA, Ford, Miller Coors, Anheuser Busch, NCAA, Spirit Halloween, CAA + junk
`seafile-ignore.txt`.

Property unmatched is a LONG tail — 300 distinct. Mostly real properties missing from
the 500-row table (Mickey, Princess, DC, Harry Potter, Stitch, Looney Tunes, Spongebob,
Sonic, Tom and Jerry, PowerPuff Girls) plus structural junk that SHOULD stay unmatched
(`_HOLIDAY`, `Style Guide`, `Style Guide - Opportunity`, `_Packaging`, `Multi-Property`).

Parent-child (properties.licensor_id FK): **perfect conformance**. Of 109,913 licensor-matched
files with a property value, 22,321 resolve a property name, and 22,321/22,321 sit under the
CORRECT licensor — **0 cross-parent violations**. Property names are globally unique
(500 distinct / 500 rows), so a matched property unambiguously implies its licensor.

Implication: the reconciliation GUI must support BOTH "alias to existing row" AND
"create new licensor/property row" — aliasing alone can't fix an 83% property gap that's
mostly missing rows. Persistent alias/row storage = a shared-db migration (gatekeeper).
