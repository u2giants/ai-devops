# claude_chats

Archived **Claude Code CLI session transcripts**, backed up from the machines they were generated on.

Each machine gets its own subfolder (e.g. `hetz/`). Within a machine folder, the layout mirrors
`~/.claude/projects/` exactly: one folder per working directory, with slashes in the path replaced by
dashes (so `/worksp/popdam` → `-worksp-popdam`). Each `.jsonl` file is one full session — a turn-by-turn
log of user messages, assistant replies, and every tool call and result.

> ⚠️ **Sensitive data.** These transcripts include full tool outputs and may contain live secrets
> (API tokens, credentials, private business data). Keep this repository **private**. If any exposed
> secret matters, rotate it.

## Machines

### `hetz/`

121 transcripts, ~128 MB, covering sessions from 2026-06-08 onward.

| Project folder | Transcripts |
|---|---:|
| `-` | 4 |
| `-home-ai` | 3 |
| `-worksp` | 1 |
| `-worksp-ai-devops` | 1 |
| `-worksp-directus` | 4 |
| `-worksp-hiclaw` | 2 |
| `-worksp-monitor` | 17 |
| `-worksp-plane` | 9 |
| `-worksp-popcrm-web` | 18 |
| `-worksp-popdam` | 43 |
| `-worksp-popdam3` | 4 |
| `-worksp-poppim` | 0 (metadata only) |
| `-worksp-poppim-web` | 13 |
| `-worksp-twenty` | 2 |

### `compshop/`

5 transcripts (+1 subagent), covering sessions from 2026-06-13 onward. Merged from both
`/root/.claude/projects/` and `/home/ai/.claude/projects/` on this machine.

| Project folder | Transcripts |
|---|---:|
| `-` | 1 |
| `-home-ai` | 4 |

### `4837/`

Windows machine. 23 CLI sessions across 8 project folders, covering sessions from
2026-06-09 onward (49 `.jsonl` files total including subagent logs and metadata). Mirrors
`C:\Users\ahazan2\.claude\projects\` (folders use the Windows-encoded form, e.g.
`C:\repos\temp` → `C--repos-temp`).

| Project folder | Transcripts |
|---|---:|
| `C--repos-dflow-alsand2` | 1 |
| `C--repos-dflow-plm` | 14 |
| `C--repos-oracle` | 3 |
| `C--repos-shared-db` | 1 |
| `C--repos-temp` | 1 |
| `ssh-000301de-281a-4556-adf2-74cefdb36b1d` | 1 |
| `ssh-ddd00acc-97b5-4111-84b5-cecdc9411e3e` | 1 |
| `ssh-e23aede2-147b-471e-9312-421d1d570c51` | 1 |

Additionally, `local-agent-mode-sessions/` holds 3 Claude Desktop embedded-Code sessions
(each with an `audit.jsonl` plus a nested `.claude/projects/` transcript), backed up from
`%APPDATA%\Claude\local-agent-mode-sessions\`.

## Keeping it synced

Run [`sync.sh`](./sync.sh) on the machine whose transcripts you want to back up. It copies the local
`~/.claude/projects/` tree into `claude_chats/<machine>/`, then commits and pushes any new or changed
sessions:

```bash
./claude_chats/sync.sh          # machine name defaults to $(hostname -s)
./claude_chats/sync.sh hetz     # or pass an explicit machine name
```
