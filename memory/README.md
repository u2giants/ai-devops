# memory/ — cross-machine Claude auto-memory

This tree is the synced home for Claude Code's **auto-memory** so a fact written
on one machine reaches all the others. Populated and read by
[`bin/ai-sync-memory`](../bin/ai-sync-memory); wired into the `sync-dotfiles`
skill.

## Layout

```
memory/
  <project>/            # canonical project key, e.g. dflow, oracle, ansible
    MEMORY.md           # the per-project index
    *.md                # individual fact files
  project-map.tsv       # optional slug -> project overrides
```

## Why canonical project keys (not raw slugs)

On each machine memory lives at `~/.claude/projects/<slug>/memory/`, where
`<slug>` encodes the working-copy path — e.g. `C--repos-dflow` on one box,
`D--repos-dflow` on another. Those are the **same project**, so `ai-sync-memory`
canonicalizes the slug (drop everything through the last `repos-`) to a single
key like `dflow`. Pin exceptions in `project-map.tsv`:

```
# slug<TAB>project
C--repos-temp-1Password-MCP	1password-mcp
```

## Rules

- **Secret-free.** Memory holds facts, not credentials. Never let a token, key,
  or password into a memory file — this tree is committed to git.
- **Pull only updates projects that already exist locally.** If a machine has
  never opened a given repo, `ai-sync-memory pull` skips it (there's no local
  path to write into); it syncs once that project dir exists.
- Conflicts between machines are ordinary git merge conflicts in the `.md`
  files — resolve them like any other doc.

See [`../docs/config-inventory.md`](../docs/config-inventory.md) and
[`../docs/config-consolidation-proposal.md`](../docs/config-consolidation-proposal.md).
