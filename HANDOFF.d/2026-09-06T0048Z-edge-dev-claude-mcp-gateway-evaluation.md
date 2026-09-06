---
issue: none yet — file one if this proceeds
status: OPEN — awaiting a single owner decision
owner: claude/token-waste-analysis-72cedc (session closed 2026-09-06)
---

# MCP gateway / dynamic tool selection — evaluation handoff

Albert proposed replacing most directly-connected MCP servers with a single
**MCP gateway (meta-server)** and asked whether it would help. The analysis
below is complete. **One measurement is outstanding, and Albert has not yet
said go.** Everything else in the parent token-waste workstream
([issue #269](https://github.com/popcre/ai-devops/issues/269)) is finished and
that issue is closed.

## 0. ⚠️ DECISIONS ONLY THE OWNER CAN MAKE

- **Nothing is broken and nothing is blocking.** Do not "fix" anything on the
  strength of this file. This is an evaluation of a change that has **not** been
  made.
- **The one open decision:** Albert was asked to approve a measurement — how many
  tokens the current tool list actually costs on Claude Desktop, and whether a
  gateway can sit in front of Claude Desktop at all. He had not answered when the
  session closed. **Do not build, install, or configure any gateway before that
  measurement exists and Albert has seen the number.**
- **Do not remove any MCP server to make a gateway look better.** The standing
  rule from the parent workstream holds: `1password`, `supabase`, `devops-mcp`
  and `synology-monitor` are the *constrained* interfaces — approval gates,
  read-only pins, launcher-injected bearer tokens. Removing one does not remove
  the work; it pushes that work onto unrestricted shell. That is a security
  regression, not a saving.

## 1. What this application is

`popcre/ai-devops` holds the machine setup, the global instruction templates
synced to `~/.claude/CLAUDE.md` and `~/.codex/AGENTS.md`, and the shared skills.
Nothing here is a running service. A change here changes how every AI session on
every machine behaves, which is why changes are measured before they ship.

Relevant machinery already in the repo:

- `bin/setup-machine.ps1` — the Windows installer. As of PR #282 it uses **one
  definition catalog with explicit per-client membership**, so Claude Code,
  Claude Desktop and Codex each get their own server set and a rerun *removes*
  entries excluded from a client. Any gateway work must go through this catalog,
  not through hand-editing a config file.
- `config/mcp-runtime/` — a lockfile-pinned local npm runtime. All npm-backed MCP
  commands resolve from here with stable local paths instead of `npx -y` at
  startup.
- `bin/mcp-secret-launch.ps1` + `~/.config/ai-devops/mcp.env` — the launcher that
  injects secrets into remote MCP servers so tokens never appear in a config
  file or a command line.

## 2. What we set out to do, and why

Albert asked, twice and with increasing precision:

1. First loosely — "would MCP routers or gateways for dynamic tool selection
   help?"
2. Then concretely — connect one gateway (he named **DCL Wrapper, MCPX, Obot
   Gateway** as examples) in front of every MCP server except the two most-used
   ones, exposing only `search_tools` and `invoke_tool` / `enable_tool`. His
   estimate: ~60 tool definitions and ~40k tokens of context collapse to ~500
   tokens of meta-tools.

The motive is the parent workstream's central finding: **every token entering a
conversation is re-sent on every later turn — measured mean amplification 36.8x
on Claude, 40.0x on Codex.** The prompt prefix is the most expensive text on the
machine, and MCP tool definitions are a large part of that prefix.

## 3. Current state — what is true right now

**Nothing has been built, installed, or configured for this proposal.** No files
were changed for it. The output of this session on the gateway question is
analysis only, recorded here.

Surrounding facts that are true and verified on `main`:

- The parent workstream is **complete**. Issue #269 is CLOSED. PR #282 ("Make MCP
  spend controls durable") landed the installer freeze, the pinned runtime, and
  the per-client server membership, and retired the parent handoff file.
- The three questions Albert asked at the previous wrap-up were **all answered**
  by another session and are recorded in
  [`docs/ai-spend-waste-analysis-2026-09-04.md`](../docs/ai-spend-waste-analysis-2026-09-04.md),
  sections 9 and 10. Do not re-answer them. In summary:
  - **Claude Desktop cannot be routed through Headroom.** Its MSIX config has no
    model-endpoint field and its embedded Claude Code process is launched without
    an endpoint override. Anthropic documents custom gateways for Claude Code,
    not for Claude Desktop. Headroom saves nothing on that surface.
  - **Codex named profiles do not apply to Albert's workflow.** Profiles are
    selected when starting the *command-line* client; Codex on Windows has no
    profile selector. The `-p work` concern was moot.
  - **Mid-session tool changes do invalidate the cache**, which is why the
    guidance became: use Claude Desktop's **On demand** tool-access mode, and
    avoid changing the connector set after a long conversation has accumulated.
- Claude Desktop currently carries a seven-server set: `1password`, `ag-grid`,
  `codex-cli`, `playwright`, `recall-ai`, `synology-monitor`, `trigger`.
- Codex carries its own independent set with Chrome DevTools parked
  (`enabled = false`) but recoverable.

## 4. Everything we tried that did NOT work, or was rejected

This section exists so nobody re-proposes a dead idea.

- **A router that swaps tools in and out mid-conversation — rejected.** This is
  the `enable_tool` variant, where the gateway injects the real tool definition
  into the live session. It is precisely the behaviour that costs 13.5% of Claude
  spend: 2,766 cache busts, 224.4M tokens re-billed, about 81k tokens per bust,
  from 1,399 mid-session tool-list mutations. A gateway built this way buys the
  disease it claims to cure.
- **leanCTX and ponytail — rejected.** They compress tool *output*, which is
  about 2% of spend. They do not touch cache invalidation, which is the 13.5%.
- **Wiring Codex to Headroom — rejected for now.** Its OpenAI pipeline has
  carried zero traffic lifetime, sign-in is fussier, and the spend is on the
  desktop surfaces anyway.
- **Removing Codex MCP servers on zero call counts — rejected on evidence.** The
  Codex prefix census (PR #282) measured a fresh first turn at 31,412 input
  tokens with 11 core tools and **no** configured MCP tools present. Disabling
  `ag-grid` through a temporary profile changed neither the tool list nor the
  input count. Ambient MCP schemas do not explain the Codex floor. The removable
  portion is plugin/configuration context — ignoring user configuration cut the
  same turn by 3,942 tokens.
- **Two hypotheses measured and abandoned earlier:** session compounding (median
  9 turns Claude, 1 Codex) and output verbosity (assistant prose is 0.3% of
  spend). Neither is a lever. Do not re-propose them.

## 5. Root causes and key findings on the gateway question

**Finding 1 — the two gateway shapes are not equivalent, and only one is safe.**

| Shape | What it does | Cache cost |
|---|---|---|
| `invoke_tool` (passthrough) | Gateway runs the backend call itself and returns the result. The model's tool list never changes. | **None.** Prefix stays stable, cache holds. |
| `enable_tool` (injection) | Gateway injects the real tool definition into the live session. | **Full re-bill** of the conversation from the start — the measured ~81k-token bust. |

Albert's own description contained both (`invoke_tool` *or* `enable_tool`) and
the phrase "dynamically injects them into the session context". That injection
step is the expensive half. **If this proceeds, insist on the passthrough form.**

**Finding 2 — we already run this pattern, successfully, twice.**

`devops-mcp` and `synology-monitor` both expose a small always-on surface
(`list_capabilities`, `get_capability_details`, `tool_search`, `invoke_tool`)
and hide the rest behind search-then-invoke. Their own server instructions say
this is deliberate "to keep the AI session context small". They are the existence
proof that the pattern works, and they use the safe passthrough shape. They are
also single-domain, which is easier than a cross-domain router.

**Finding 3 — the prize is probably smaller than the ~40k estimate, and unmeasured.**

Albert's ~40k figure predates this workstream's trims. Claude Desktop is already
down to seven servers, and the Codex census showed ambient MCP schemas explaining
*none* of that client's floor. **Nobody has measured what the Claude Desktop tool
prefix currently costs.** That number decides whether this is worth building, and
producing it is the outstanding task.

**Finding 4 — the surface question may kill it outright.**

Almost all spend is on the desktop applications, not the command line. Anthropic
documents custom gateways for Claude Code, not Claude Desktop — the same
asymmetry that made Headroom useless on Desktop. If a gateway can only sit in
front of the CLI, it would optimise the surface that is not costing money.

**Finding 5 — Claude Desktop already ships a native version of this idea.**

Its **On demand** tool-access mode is dynamic tool selection built into the
client. It should be evaluated *before* any third-party gateway, because it costs
nothing to try and adds no moving parts.

**Finding 6 — the real cost is discovery, not tokens.**

A model cannot want a tool it cannot see. Behind a gateway, a model that fails to
search well will reach for the shell instead of the safe, approval-gated path.
That is the same argument that kept the database and NAS tools alive in the
parent workstream, and it is the strongest reason to prefer a short *static*
menu over a dynamic one.

## 6. Exact next steps

Do these in order. **Step 1 requires Albert's go-ahead; it had not been given
when this session closed.**

1. **Measure the Claude Desktop tool prefix.** Capture a no-op Desktop
   conversation's first turn and record the billed input tokens and the tool list
   it carried. Then repeat with the connector set reduced to `1password` plus one
   other. The difference is the entire prize. Method: the same
   `~/.claude/projects/**/*.jsonl` parsing used throughout this workstream — the
   schema notes are in section 8 of the findings document.
2. **Establish whether any gateway can front Claude Desktop at all.** Check
   whether Desktop's connector configuration accepts an arbitrary stdio MCP
   server that itself proxies others. PR #282's per-client catalog is where such
   an entry would have to be declared. If Desktop cannot host one, stop here and
   tell Albert the answer is no for the surface that matters.
3. **Try Claude Desktop's native On demand tool-access mode first** and measure
   it the same way as step 1. If it delivers most of the saving, the third-party
   gateway is unnecessary.
4. **Only if steps 1–3 justify it:** pilot ONE gateway in front of two or three
   low-risk servers, passthrough shape only, declared through the installer's
   definition catalog. Never in front of `1password`.
5. **Re-measure after the pilot** and compare against step 1. Report the real
   number, not the projection.

## 7. Constraints and gotchas in force

- **A Claude session must never edit Codex configuration, and vice versa.**
- **Do not edit `C:\repos\ai-devops` directly.** Work from a fresh worktree on
  `origin/main`. Another session had 17 uncommitted files and a checkout 162
  commits behind sitting in that folder during this session.
- **Never hand-edit an MCP config that the installer manages.** PR #282 made
  `bin/setup-machine.ps1` authoritative: a rerun removes entries excluded from a
  client. A hand-added gateway entry would be silently deleted on the next run.
- **Do not remove a constrained server to shorten the list.** See section 0.
- **Codex `total_token_usage.input_tokens` includes `cached_input_tokens`.**
  Failing to subtract overstates fresh input roughly fivefold.
- **Codex accepts `enabled = false` at server level** (proven empirically) but
  has **no per-directory MCP scoping**; `[projects.'...']` entries are trust
  settings. A partial `-c` override such as `mcp_servers."x".enabled=false`
  replaces the whole table and yields "invalid transport". `--strict-config` is
  rejected by `codex mcp`.
- **There are three separate Claude MCP surfaces**, and any work must name which
  it touches: `~/.claude.json` (CLI user scope),
  `%APPDATA%\Claude\claude_desktop_config.json` (Desktop — where the spend is),
  and committed repo-root `.mcp.json` (project scope). An earlier trim in this
  workstream touched only the first and therefore bought nothing.
- **Narrow every reviewer brief.** A broad Grok brief in this workstream burned
  1,592,118 tokens and $0.185 and returned no answer, cancelled at the 20-turn
  ceiling. A narrowly scoped rerun answered the same question for 31,775 tokens
  and $0.014 — a 13x difference. Never widen the turn limit to compensate.

## 8. Access and environment

- Machine `edge-dev`, Windows 11, Git Bash and PowerShell both available.
- Measurement source: `~/.claude/projects/**/*.jsonl` for Claude, and
  `~/.codex/sessions/**` plus `~/.codex/archived_sessions/**` for Codex. The
  parsing scripts used in this workstream were throwaway and are not committed;
  the schema notes needed to rewrite them are in section 8 of
  `docs/ai-spend-waste-analysis-2026-09-04.md`.
- Reviewer wrappers (`ai-grok-review`, `ai-muse`) must be run **from a dedicated
  worktree**, never from `C:\repos\ai-devops`. Their reports land in `.ai/reviews/`,
  which is git-ignored.
- No credentials were handled in this session and none are needed for the next
  steps. If one appears, it goes to 1Password vault `vibe_coding` through the
  `secrets-to-1password` skill, never through chat or a command line.

## 9. Open questions and risks

- **The single open question:** what does the Claude Desktop tool prefix actually
  cost today? Everything else is gated on it. It is unmeasured.
- **Unknown:** whether Claude Desktop can host a gateway MCP server at all.
  Precedent is discouraging — Headroom could not be attached to Desktop for the
  analogous reason.
- **Risk — discovery loss.** A gateway that hides tools makes the assistant reach
  for the shell when its search fails. This degrades safety, not just
  convenience, and it will not show up in a token measurement. Any pilot must
  watch for it explicitly.
- **Risk — the wrong shape.** If a gateway injects tools rather than proxying
  them, it *increases* spend by causing exactly the cache busts this workstream
  measured. Verify the shape before installing anything.
- **Risk — installer conflict.** A gateway added outside the PR #282 definition
  catalog will be removed on the next `setup-machine.ps1` run, producing a
  confusing intermittent failure.
- **Accepted, carried forward:** the terminal-output-discipline rules added
  earlier in this workstream trade some verbosity for tokens. If a session starts
  mis-diagnosing from truncated output, suspect those rules first.
