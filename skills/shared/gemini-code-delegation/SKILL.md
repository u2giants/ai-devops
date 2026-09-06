---
name: gemini-code-delegation
description: Use Gemini 3.8 Flash through the ai-gemini wrapper for an independent read-only repository review. Trigger when the user says ask Gemini, use Gemini, Gemini review, run this by Gemini, or Gemini 3.8 Flash.
---

# Gemini code review

Gemini 3.8 Flash is a governed reviewer again as of 2026-09-06, and may also be
used for an ad-hoc advisory read-only review. It was held out after two live
attempts produced no parseable verdict and a bare `PASS` with an empty report;
it returned only after a recorded live safety qualification and a live review
that produced a well-formed verdict above a substantive report. It is drawable
only while `ai-review-preflight usable gemini` exits zero — the hash-bound
qualification re-quarantines it on any wrapper, runtime, or model drift. Never
add a provider to the registry to make an allocation succeed.

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
