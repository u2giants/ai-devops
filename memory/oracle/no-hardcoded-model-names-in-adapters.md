---
name: no-hardcoded-model-names-in-adapters
description: "Oracle rule — model-specific facts live in the catalog/capability layer, never hardcoded in provider adapters"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 62bdea8a-34e4-40d1-aeef-c5bc91c4e5c0
---

Albert is explicit and repeatedly insistent: **no model-specific values may be hard-coded in provider adapters** (e.g. no `if (modelId === 'gemini-2.5-flash')`). Model facts (capabilities, how a model expresses thinking, vision support, etc.) live in the catalog/capability layer (`packages/ai/src/routes/catalog.ts`, `candidates.ts`, `model-capabilities/`) and flow through the resolved `OracleModelRoute`.

**Why:** keeps adapters generic and correct as the model roster changes; capability drift is fixed in one metadata place, not scattered across adapters.

**How to apply:** when an adapter must behave differently per model (e.g. `thinkingLevel` enum vs numeric `thinkingBudget`), add a capability field to the route/catalog and branch on that field — not on the model id string.

Also a standing demand: "Proper, long-term fix. Never a band-aid." Don't `.catch()` away validation errors or weaken validation to make something pass. See [[oracle-mandate-adapter-bugs]].
