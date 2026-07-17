---
name: prove-nas-tools-by-running-not-reading
description: "In this repo, verify tools/config by executing against the real NAS or a real test — reading the code passes things that are dead on arrival."
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 02913776-8d59-48dc-ac7f-cfb46f678c1f
---

On synology-monitor, "the code looks correct" has repeatedly hidden tools that are
**dead on arrival**. Verify by running, not by reading. Cases from 2026-07-17:

- `hdparm_device_info` / `strace_process` are enabled but their binaries aren't in the
  image — only found by invoking them (`command not found`). Same class as the old
  `setfacl` tool.
- A write tool's own error PROSE tripped a permanent validator block (`\bpasswd\s+\S`,
  `strings.Contains "docker compose"`) — found only by running the generated command
  through `IsHardBlocked`/`ClassifyTier`, not by reading `buildCommand`.
- `privileged: true` was masking that `volumes:`-mounted block devices grant no
  device-cgroup access — SMART was silently broken on edge2 and nobody knew until
  `check_smart_detail` was actually invoked.
- My own generated `repair_drive_db_permissions` had an `rc=1`-in-a-pipe-subshell bug
  that would report success while failing — caught by running the built command, not
  reading it.

**Why:** the tier gates, `write: true`, "enabled", and a passing type-check check none
of: binary present, mount writable/accessible, identifiers resolvable in the container,
command not hard-blocked. Only a real run does.

**How to apply:** before trusting any NAS tool or compose change, run it — via the
`synology-monitor` MCP (`check_smart_detail`, `strace_process`, etc.), a Go test against
the real validator, or a zero-restart disposable `docker run --rm … smartctl/strace` on
the NAS (`ssh` + the `sudo -n /usr/bin/python3` root path). Prove the outcome, don't
infer it. Also don't trust a documented "fact": edge2 "down since 2026-07-08" was false
(hetz reaching a LAN IP it isn't on). Related: [[albert-is-not-a-programmer-give-runnable-commands]].
