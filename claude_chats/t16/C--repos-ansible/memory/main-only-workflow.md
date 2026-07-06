---
name: main-only-workflow
description: "User works only on main, never feature branches; commit and push directly to main"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: c1b93c02-75c5-4760-b6aa-f6571f8d7607
---

The user works **only on `main`** — never create feature branches. Commit directly to `main` and push to `main`.

**Why:** Stated explicitly on 2026-06-22 ("We only work on main, never branches"). Solo vibe-coder workflow; branches add friction they don't want.

**How to apply:** Skip the usual "branch first" default. Commit to `main` and push when asked. (Pushing is still an outward action — only push when the user asks.) Note this can conflict with the Ansible repo's own stated PR→merge→CI model in [[ansible-project-overview]]; for *this local repo's git workflow*, main-only wins.
