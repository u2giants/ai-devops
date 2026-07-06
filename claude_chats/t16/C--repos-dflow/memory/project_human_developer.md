---
name: project_human_developer
description: "Uma is the user's human developer who reviews/merges PRs; reach him via GitHub"
metadata: 
  node_type: memory
  type: project
  originSessionId: fe4718b9-1f1a-407e-adfa-e559a98fd35e
---

The user's human developer is **Uma**, GitHub handle **`devopswithkube`** (org `popcre`). He
reviews and merges the `sandbox-albert → develop` PRs; merging into `develop` is HIS decision —
Claude only commits/pushes to `sandbox-albert` and opens/updates PRs, never merges to `develop`.

**How to reach Uma:** GitHub only. There is **no Teams/Slack/email send connector** wired up — the
sole Microsoft/Outlook MCP present exposes calendar availability + identity only (`find_available_time`,
`get_me`), not mail; the connector registry returned nothing for Teams/email/Slack. To ask Uma a
question without making the user a go-between, post a **PR comment / `@devopswithkube` mention / GitHub
issue** via the `gh` CLI. (If the user later connects a Graph `Mail.Send` or Teams MCP, email/Teams
becomes possible.)

Related: [[project_repos]].
