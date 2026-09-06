# Gemini re-qualification, 2026-09-06 — PASSED

Third and successful attempt. Both halves of the standing objection recorded in
`2026-09-05-gemini-requalification-attempt.md` are now answered with evidence.

## 1. Live safety qualification

`ai-review-preflight qualify gemini` returned zero and recorded a hash-bound
qualification:

```
ai-review-preflight: Gemini live qualification recorded for wrapper
dac5862e5f12b75ff3f8b00075c339e404b62db8b55441012d2fcde6f3ca1f9e,
agy 1.1.27, and model gemini-3.8-flash-high.
```

The record binds the wrapper sha256, the runtime version and sha, and the exact
model. Any drift in those re-quarantines the provider without anyone deciding to.

The two earlier failures were real and are not being explained away: the first
attempt returned `model verification request failed or timed out`, and that
failure revoked the local qualification, so the second attempt was refused
before it started. Nothing in the gate was relaxed between then and now.

## 2. Live review with a well-formed verdict and a substantive report

Target: merged commit `99fbefcb4cf3388a3d46e77a2fdddb1f06bd25a1` (a small,
already-merged change to the Muse OpenCode configuration). The prompt demanded a
verdict line carrying the head SHA followed by real analysis.

Result: `PASS`, with a durable report saved by the wrapper. The report opens with

```
VERDICT APPROVE 99fbefcb4cf3388a3d46e77a2fdddb1f06bd25a1
```

and carries 3,137 substantive characters as measured by `report_substance` in
`bin/ai-review-lifecycle` — more than fifteen times the 200-character floor. The
analysis cites specific lines (the provider package switch, the compaction
settings, the preserved `{env:MODEL_API_KEY}` reference) and ties the safety
claim to the contract test that enforces it. It is a review, not a decision
token.

The full report is kept alongside this note as
`2026-09-06-gemini-live-review-report.md`.

## 3. The empty-report failure mode is now caught, not trusted

Independently of this provider, `bin/ai-review-lifecycle` converts any APPROVE or
REJECT whose report carries no substantive analysis into `BLOCKED` with failure
class `empty-report`. Headings, horizontal rules and bare decision words do not
count as analysis. So the exact 2026-08 failure — a bare `PASS` with an empty
report satisfying a gate — can no longer reach a merge decision from any
provider, including this one.

## Outcome

Gemini was added to the allocating registry in `u2giants/shared-db` as
`gemini-3.8-flash-high` (PR #2438), appended so no existing rotation slot moves,
and `config/reviewer-registry.json` here was updated to mirror that membership.
`ai-review-preflight usable gemini` now exits zero.

This is membership earned by evidence. It is not an edit made to unblock an
allocation, and no verdict parsing was relaxed to reach it.
