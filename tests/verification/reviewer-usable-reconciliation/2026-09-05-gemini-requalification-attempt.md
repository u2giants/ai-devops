# Gemini re-qualification attempt, 2026-09-05

Issue: `popcre/ai-devops#285`.

## Why this run happened

Issue #285 asks for Gemini to be re-qualified with a live run against a small,
already-merged change, returning a well-formed verdict line carrying the head
SHA, before any reviewer-registry re-entry is considered.

## What was run

A read-only review of merged commit
`2609b6d7443e8e7337aa0d37c134d4433b3acd0b` (three files, ten insertions), with
an explicit output contract: a substantive report, and a final line of exactly
`VERDICT: <APPROVE|REVISE> 2609b6d7443e8e7337aa0d37c134d4433b3acd0b`.

```bash
AI_GEMINI_CALLER=claude ai-gemini new requal-285 --prompt-file <prompt>
```

## Result: failed, twice

1. First attempt exited 1 with `ai-gemini: error: model verification request
   failed or timed out`. No review was produced, so no verdict and no report.
2. The failure revoked the local live qualification, as designed. The second
   attempt exited 1 with `ai-gemini: error: Gemini reviews are quarantined
   until live safety qualification is complete`.

Before the first attempt this host reported Gemini as `installed-healthy` — the
exact trap #285 describes. Health said yes; the provider could not produce a
review.

## Conclusion

Gemini stays `registry_state: absent` in `config/reviewer-registry.json`. This
is now the third recorded failed attempt, after one run that produced no
parseable verdict and one that produced a bare `PASS` with an empty report.
Re-entry still requires a live run that returns a well-formed verdict carrying
the head SHA plus a substantive report, recorded in a reviewed `u2giants/shared-db`
pull request. It is never an edit made to unblock an allocation.

## Reconciled state after this run

```
$ ai-review-preflight status gemini
{"status":"quarantined","registry_state":"absent","usable":false}
```
