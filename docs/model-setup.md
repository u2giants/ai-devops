# Model Setup

How model commands are configured, and how to adapt them to your machine.

## Where config lives

Real config: `/etc/ai-devops/models.env` (created by `install.sh` from
`config/models.env.example`, and **never overwritten** on re-install).

The example: [`config/models.env.example`](../config/models.env.example).

## The variables

| Variable | Stage(s) | Default |
|----------|----------|---------|
| `OPUS48_HIGH_REASONING_CMD` | Plan (01), Final review (07) | `claude --model opus-4.8 --reasoning high` |
| `OPUS_REVIEW_CMD` | Plan/diff/security review (02/04/06) | `claude --model opus-4.8 --reasoning high` |
| `GPT55_CMD` | Implement (03) | `codex exec --skip-git-repo-check` |
| `CODEX_CMD` | `ai-codex-review` | `codex exec --skip-git-repo-check` |
| `TESTER_CMD` | Test (05) | `codex exec --skip-git-repo-check` |
| `AI_DEVOPS_HOME` | paths | `/worksp/ai-devops` |

## The model workflow (roles)

- **Opus 4.8 (high reasoning)** — implementation plans, architecture review,
  final product/architecture review.
- **GPT-5.5 / Codex** — coding, implementation, testing, fixing.
- **Opus** — independent review throughout (plan, diff, security, final).

## Important: the exact flags may differ on your machine

The Claude/Codex CLIs evolve, and the exact model identifiers and flags
(`--model`, `--reasoning`, etc.) may not match your installed versions. **You may
need to edit `/etc/ai-devops/models.env` after install.**

To find the right flags:

```bash
claude --help
codex --help
```

Then update the `*_CMD` variables to whatever actually works, e.g. swapping the
model id or the reasoning flag. The scripts always read the real file at
`/etc/ai-devops/models.env`, so your edits take effect immediately.

## How the scripts use these

- `ai-model-call <stage> <prompt> <out>` maps a stage name to the matching
  `*_CMD` and pipes the prompt in on stdin.
- `ai-codex-review <mode>` uses `CODEX_CMD` for read-only reviews.

## A note on Fable

Earlier drafts of this workflow referenced "Fable." **Fable is not used.**
Wherever planning/final-review would have used it, this workflow uses
**Opus 4.8 with high reasoning** instead.
