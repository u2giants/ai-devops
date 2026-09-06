---
name: wrap-up
description: One-phrase end-of-session closer. Use when the user says "wrap up", "wrap it up", "dflow wrap up", "wrap up dflow", "close out this session", "we're done here", or "end of session" — ANY "wrap up" variant, including project-prefixed ones like "dflow wrap up", routes HERE, not to a ship-only skill. Chains the four closing rituals: docs update FIRST, then secrets sweep, handoff-safe state, push verification, workspace close-out (uncommitted files, branch, worktree), and a next-session prompt — then gives a single plain-English closing report. This skill OWNS "wrap up"; it delegates the ship step to the project ship skill (dflow → dflow-ship) but never the other way around.
---

# wrap-up

One word closes the session properly. Runs the four closing rituals in order
and ends with a single consolidated report. Skip nothing silently — if a step
doesn't apply, say so in the report.

## Trigger phrases

- "wrap up" / "wrap it up"
- "dflow wrap up" / "wrap up dflow" / "dflow wrap-up" (project-prefixed — still THIS skill)
- "close out this session" / "we're done here" / "end of session"

> Any message containing "wrap up" belongs to this skill, even when a project
> name is attached. Do NOT route "dflow wrap up" to `dflow-ship` — `dflow-ship`
> is only Step 4 (ship & verify) of this skill's chain, and it does not update
> the .md docs. Running it alone silently skips the docs step. This skill runs
> docs FIRST, then calls `dflow-ship` for the ship step.

> **Shared-database sessions:** if this session touched the shared Supabase
> database / `u2giants/shared-db`, or dispatched sub-agents, also run the
> **`shared-db-handover`** skill for the handoff step. That handoff has two
> halves and the second — one block per sub-agent — is mandatory; a generic
> handoff is incomplete.

## The chain

1. **Docs** — run the `session-docs-update` skill: record what this session
   learned or changed in the right .md files (AGENTS.md / docs/ / your own
   `HANDOFF.d/` file), mirror any shared-backend change to `u2giants/shared-db`.
   If nothing durable changed, state that explicitly.
2. **Secrets** — run the `secrets-to-1password` skill: sweep the session for
   any credential that appeared and store it in the `vibe_coding` vault with
   rich notes.
3. **Handoff-safe state** — every touched repo: no mystery untracked files,
   no half-done merges. If work is unfinished, write **ONE NEW file of your own**:
   `HANDOFF.d/<UTC>-<machine>-<agent>-<slug>.md` (e.g.
   `HANDOFF.d/2026-07-29T2140Z-t16-claude-supabase-mcp-scoping.md`) to the full
   `handoff-standard.md` — all 9 sections — and RUN ITS SELF-AUDIT GATE. A
   stranger who walked in off the street must be able to continue with no
   questions, as effectively as you can right now, including knowing what was
   tried and failed. A three-sentence handoff is a failure; expand until the
   audit passes (use the `handoff-writer` skill, which owns the naming rules,
   the static `HANDOFF.md` pointer, legacy migration, and retention). Once it
   passes, if asked whether the handoff is comprehensive enough, answer "Yes"
   with evidence — do not reflexively answer "No, I'll fix it."

   Concurrency rules, non-negotiable — other agents may be working the same
   checkout right now:
   - **Do NOT rewrite the root `HANDOFF.md`.** It is a static pointer to
     `HANDOFF.d/`. If it is still a legacy full document (line 1 lacks
     `handoff-pointer: v1`), migrate it per `handoff-writer`: `git mv` it verbatim
     into `HANDOFF.d/` as one open workstream, then write the pointer.
   - **Do NOT open, edit, tidy, or delete another session's `HANDOFF.d/` file.**
   - **Retention:** delete YOUR `HANDOFF.d/` file when the work it describes is
     proven done (git history keeps the text). If `HANDOFF.d/` holds **more than
     5** files, warn loudly in the closing report — list them oldest-first with
     dates and ask which are actually finished.
4. **Ship & verify** — commit and push everything per each repo's rules
   (dflow → `dflow-ship`: PR to develop; hetz apps → `deploy-and-verify`:
   Actions/GHCR/Coolify + live SHA check; everything else → main). Confirm
   working trees are clean and pushes landed. Never report "done" on
   unverified evidence.

5. **Close the workspace** — leave no orphaned branch, worktree, or file.
   Order matters; each gate must pass before the next.
   - **Uncommitted files:** every modified/untracked path gets an explicit
     decision — commit it, add it to `.gitignore`, or move it out of the repo.
     "I'll leave it" is only allowed if you name the file and the reason in the
     closing report. Never `git clean`, never `git checkout --` over unreviewed
     work, and never touch a file you did not create this session (another
     session may own it — see `concurrent-session-clobber-hazards`).
   - **Branch:** delete the local and remote branch ONLY after proving the work
     landed — `gh pr view <n> --json state,mergedAt` shows `MERGED`, or the
     commits are reachable from `origin/main`. A squash merge rewrites SHAs, so
     test with `git branch --merged origin/main` or by confirming the PR state,
     not by comparing SHAs. If it is not merged, keep the branch and say so.
   - **Worktree:** remove this session's worktree only when its tree is clean
     AND its branch is merged or intentionally preserved. Use the
     `cleanup-worktree` skill — it owns the safety audit, recovers unique work,
     and never treats age as proof that deletion is safe. If anything is
     unmerged or uncertain, LEAVE THE WORKTREE and name it in the report.
   - **Never** delete a branch, worktree, or checkout that another session is
     using, and never delete unmerged work to make the report look clean.

6. **Next-session prompt** — end with a copy-paste prompt Albert can drop into a
   fresh session to resume exactly here. Put it in its own fenced block at the
   very bottom of the closing report, and make it self-contained: a stranger
   pasting it into an empty session must be able to continue with no chat
   context. It states the repo and branch, the one-sentence goal, what is
   already done, the exact next action, how to verify success, and a pointer to
   the `HANDOFF.d/` file written in step 3. If the work is genuinely complete,
   say "No follow-up prompt — this workstream is closed" instead of inventing one.

## Closing report (plain English, one message)

```md
## Session closed
- What we accomplished: [1-3 sentences, business language]
- Docs updated: [files, or "nothing durable changed"]
- Secrets: [stored/none found]
- Handoff: [new HANDOFF.d/<file> written + why / none because work is complete;
  files deleted as done. Report STALE files — ones whose issue is already closed —
  by name with their owner. Never report the file COUNT as a problem: 20 concurrent
  workstreams means 20 files and that is correct (owner ruling 2026-08-13)]
- Shipped: [commit SHAs, PR URLs, deploy verified yes/no]
- Loose ends: [anything Albert should know, or "none"]
- Workspace: [uncommitted files decided; branch deleted/kept + why; worktree
  removed/kept + why]

Then, as the last thing in the message, the fenced next-session prompt from
step 6 (or the single line saying the workstream is closed).
```

If any step could not be completed (blocked push, failing test), say exactly
what and what the next session should do — do not end the report on "done".
