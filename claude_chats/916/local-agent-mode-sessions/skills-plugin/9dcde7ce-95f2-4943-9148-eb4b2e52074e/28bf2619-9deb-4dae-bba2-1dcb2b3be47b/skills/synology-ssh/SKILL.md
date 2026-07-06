---
name: synology-ssh
description: >
  Connects to the user's Synology NAS units (edgesynology1/edge1 and edgesynology2/edge2)
  over SSH via plink and runs bash commands including privileged sudo commands.
  Use this skill whenever the user wants to investigate, diagnose, or administer
  anything on their Synology NAS: checking backup status, stuck processes, disk health,
  logs, running services, file permissions, storage usage, Docker containers, or any
  other server-side task. Also trigger when the user says check edge1, run this on
  edge2, SSH into the NAS, or asks about anything happening on their NAS even without
  explicitly mentioning SSH. Trigger proactively - if a question could be answered by
  looking at the NAS, use this skill rather than asking the user to do it manually.
---

## Overview

Run commands on either Synology NAS by sending them through plink via the
mcp__Windows-MCP__PowerShell tool on the user's Windows machine. Plink executes
commands non-interactively and returns output - no interactive terminal needed.

## Connection Details

| Alias | Full name      | IP            | SSH Port | User   |
|-------|----------------|---------------|----------|--------|
| edge1 | edgesynology1  | 192.168.3.100 | 22       | ahazan |
| edge2 | edgesynology2  | 192.168.3.101 | 1904     | ahazan |

IMPORTANT: edgesynology2 uses port 1904, NOT 22. Port 22 accepts auth but
silently blocks all command execution. Always use -P 1904 for edge2.

Password: Tzvi19972#  (same for both NAS units, also works for sudo -S)

Host key fingerprints (pass to plink with -hostkey to skip interactive prompt):
- edgesynology1: SHA256:JPqadQuh+QWEAt5oUT0OF4hY/LdmWXOtTs2FGXGo5QI
- edgesynology2: SHA256:BQ1mg15Up9ypS9KqQjsQzygTp9OpgQ67s1GM4KpRf+E

## Running a Single-Line Command

For edge1:

    & "C:\Program Files\PoTTY\plink.exe" -batch -hostkey "SHA256:JPqadQuh+QWEAr5oUT0OF4hY/LdmWXOtTs2FGXGo5QI" -pw "Tzvi19972#" ahazan@192.168.3.100 "whoami; uptime" 2>&1

For edge2 (note -P 1904):

    & "C:\Program Files\PoTTY\plink.exe" -batch -hostkey "SHA256:BQ1mg15Up9ypS9KqQjsQzygTp9OpgQ67s1GM4KpRf+E" -pw "Tzvi19972#" -P 1904 ahazan@192.168.3.101 "whoami; uptime" 2>&1

## Running Multi-Line Scripts (Base64 Pattern)

Use base64 encoding to safely pass multi-line bash scripts through plink
without quoting conflicts between PowerShell and bash:

    $script = @'
    echo "=== Disk Usage ==="
    df -h
    echo "=== Top Processes ==="
    ps aux --sort=-%cpu | head -10
    '@
    $b64 = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($script))
    & "C:\Program Files\PoTTY\plink.exe" -batch -hostkey "SHA256:JPqadQuh+QWEAr5oUT0OF4hY/LdmWXOtTs2FGXGo5QI" -pw "Tzvi19972#" ahazan@192.168.3.100 "echo $b64 | base64 -d | bash" 2>&1

## Using sudo

ahazan is admin on both units. Pipe the password into sudo -S for non-interactive use:

    PW='Tzvi19972#'
    printf '%s\n' "$PW" | sudo -S your-command-here

## Quick Reference: Common Tasks

- CPU/memory hogs:      ps aux --sort=-%cpu | head -20
- Disk space:           df -h | grep -v tmpfs
- HyperBackup status:   ps aux | grep -i img_backup | grep -v grep
- Recent errors:        tail -50 /var/log/messages | grep -iE 'error|warn<fail'
- Network throughput:   cat /proc/net/dev, sleep 2, cat again, compare TX bytes on eth0
- Docker containers:    printf 'Tzvi19972#\n' | sudo -S docker ps
- Package logs:         find /var/packages/PackageName -name "*.log" 2>/dev/null | xargs tail -20

## Choosing the Right NAS

- edge1 / edgesynology1 / 192.168.3.100  ->  port 22
- edge2 / edgesynology2 / 192.168.3.101  ->  port 1904
-&ãomment ambiguous: ask the user, or run on both and label the results

## Handling Output

Summarise results clearly - do not paste raw terminal output unless asked.
If a command fails with Permission denied, retry with sudo.
If a path or binary is missing, adapt - DSM package paths vary by version.
For investigations, run focused targeted commands rather than one giant script.
