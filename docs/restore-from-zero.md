# Restore From Zero

How to rebuild this entire AI coding workflow on a brand-new Ubuntu server if the
current one dies. Everything needed is in this repo; only the interactive logins
(gh / claude / codex) are redone by hand.

> Target path is always `/worksp/ai-devops`. Never `/opt/ai-devops`.

## Exact steps

### 1. Create an Ubuntu server

Provision a fresh Ubuntu box (any recent LTS). Log in as a sudo-capable user.

### 2. Install git

```bash
sudo apt-get update
sudo apt-get install -y git
```

### 3. Clone this repo to /worksp/ai-devops

```bash
sudo mkdir -p /worksp
sudo chown "$USER":"$USER" /worksp
git clone https://github.com/u2giants/ai-devops.git /worksp/ai-devops
cd /worksp/ai-devops
```

### 4. Run install.sh

```bash
./install.sh
```

This installs base dependencies, creates `/etc/ai-devops` and
`/var/log/ai-devops`, seeds `models.env` / `server.env` (without overwriting any
existing real config), symlinks the `bin/` tools into `/usr/local/bin`, and runs
`ai-devops doctor`.

### 5. Authenticate GitHub CLI

```bash
gh auth login
```

### 6. Log in to Claude

```bash
claude login        # or run `claude` and follow the login prompt
```

### 7. Log in to Codex

```bash
codex login         # or run `codex` and follow the login prompt
```

### 8. Verify with doctor

```bash
ai-devops doctor
```

All **required** checks should pass. Warnings about optional tools are fine.

## After restore

- Review `/etc/ai-devops/models.env` and adjust the model CLI flags to match
  what your installed `claude` / `codex` accept (see `docs/model-setup.md`).
- Onboard your application repos separately (see `docs/repo-onboarding.md`).
  This toolkit does **not** modify application repos automatically.

## What is NOT restored (by design)

- Secrets, tokens, `.env` files, SSH keys — none of these live in this repo.
- Claude/Codex/gh login state — recreated by the `login` steps above.
- Application source code — cloned separately per project.
