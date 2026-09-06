---
name: gemini-code-delegation
description: Use Gemini 3.8 Flash through the ai-gemini wrapper for an independent read-only repository review. Trigger when the user says ask Gemini, use Gemini, Gemini review, run this by Gemini, or Gemini 3.8 Flash.
---

# Gemini code review

Gemini 3.8 Flash may be used for an ad-hoc, advisory read-only review when the
local hash-bound qualification remains current. It may **not** be assigned a
governed review that satisfies a gate: Gemini is absent from the reviewer
registry, so `ai-review-preflight usable gemini` exits non-zero and the
allocator will not draw it. That absence is deliberate — two prior live
attempts produced no parseable verdict and a bare `PASS` with an empty report.
Never add it to the registry to make an allocation succeed.

Never call `agy` directly or bypass a quarantine. Check both gates before
assigning work:

```bash
ai-review-preflight usable gemini
```

```bash
AI_GEMINI_CALLER=codex ai-gemini doctor
```

Proceed only when `doctor` reports `PASS` for exact model
`gemini-3.8-flash-high`. If it reports `QUARANTINED`, stop and choose another
governed reviewer until one governed requalification succeeds. An empty answer,
wrong model or conversation, changed protected file, committed or uncommitted
source drift, interruption, or missing durable report is always a failed review.
Gemini is review-only.
