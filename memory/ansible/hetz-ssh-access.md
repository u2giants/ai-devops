---
name: hetz-ssh-access
description: How to SSH into the hetz server from this Windows PC
metadata: 
  node_type: memory
  type: reference
  originSessionId: c1b93c02-75c5-4760-b6aa-f6571f8d7607
---

This PC (`albt16`) is already on the Tailscale tailnet and can reach `hetz`. The user's
`~/.ssh/config` has a working alias: **`ssh vps`** (also `hetzner` / `coolify`) → connects as
**root** to `100.66.37.58` (Tailscale) using key `~/.ssh/916-alien`, with a Cloudflare-tunnel
fallback (`ssh-coolify.designflow.app`) if Tailscale is down.

`ssh ai@100.66.37.58` does NOT work (the `ai` user doesn't trust the 916-alien key, and public
SSH/port 22 is firewalled to Tailscale-only). Use the `vps` alias (root) for discovery/ops.

Ansible from WSL: the repo is at `/mnt/c/repos/ansible/ansible`; run with
`export ANSIBLE_CONFIG=$PWD/ansible.cfg` (the /mnt/c mount is world-writable so the cfg is
otherwise ignored). To connect as root, the private key must be copied into WSL `~/.ssh` with
chmod 600 (ssh rejects 0777 keys on /mnt/c). See [[ansible-project-overview]].
