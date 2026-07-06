# ============================================================
# Codex-Only MCP Setup Script - Albert's Codex MCP Stack
# Run this on any Windows PC after installing Codex for Windows
#
# FUTURE AI SESSIONS: THIS FILE IS CODEX-ONLY.
# - It may update only $env:USERPROFILE\.codex\config.toml.
# - It must NOT read, write, create, or modify any Claude Desktop or Claude Code config files.
# ============================================================

# Step 1: Install Node.js if missing
if (-not (Get-Command npx -ErrorAction SilentlyContinue)) {
    Write-Host "Node.js not found. Downloading installer..."
    $installerUrl = "https://nodejs.org/dist/v20.19.0/node-v20.19.0-x64.msi"
    $installerPath = "$env:TEMP\nodejs-installer.msi"
    Invoke-WebRequest -Uri $installerUrl -OutFile $installerPath
    Start-Process msiexec.exe -ArgumentList "/i `"$installerPath`" /quiet /norestart" -Wait
    Write-Host "Node.js installed."
} else {
    Write-Host "Node.js already installed: $(node --version)"
}

# ============================================================
# Configure Codex global MCP settings
# ============================================================
Write-Host ""
Write-Host "Configuring Codex global MCP settings..."

$codexConfigPath = "$env:USERPROFILE\.codex\config.toml"
New-Item -ItemType Directory -Force -Path (Split-Path $codexConfigPath) | Out-Null

if (Test-Path $codexConfigPath) {
    $codexConfig = Get-Content -LiteralPath $codexConfigPath -Raw
    Write-Host "Found existing Codex config, merging..."
} else {
    $codexConfig = ""
    Write-Host "No existing Codex config found, creating new one..."
}

function Test-CodexMcpServerExists {
    param(
        [Parameter(Mandatory = $true)]
        [string]$ConfigText,

        [Parameter(Mandatory = $true)]
        [string]$Name
    )

    $escapedName = [Regex]::Escape($Name)
    # Match both bare and quoted table headers, e.g. [mcp_servers.foo] and [mcp_servers."1password"],
    # so re-running the script never appends a duplicate key (TOML rejects duplicate tables).
    return [Regex]::IsMatch($ConfigText, "(?m)^\[mcp_servers\.`"?$escapedName`"?\]\s*$")
}

function Add-CodexMcpServer {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Name,

        [Parameter(Mandatory = $true)]
        [string]$TomlBlock
    )

    if (Test-CodexMcpServerExists -ConfigText $script:codexConfig -Name $Name) {
        Write-Host "$Name MCP already exists in Codex config, skipping."
        return
    }

    if ($script:codexConfig.Length -gt 0 -and -not $script:codexConfig.EndsWith("`n")) {
        $script:codexConfig += "`r`n"
    }

    $script:codexConfig += "`r`n$TomlBlock`r`n"
    Write-Host "$Name MCP added to Codex config."
}

Add-CodexMcpServer -Name "playwright" -TomlBlock @'
[mcp_servers.playwright]
command = 'C:\PROGRA~1\nodejs\npx.cmd'
args = ["-y", "@playwright/mcp@latest"]
'@

Add-CodexMcpServer -Name "synology-monitor" -TomlBlock @'
[mcp_servers.synology-monitor]
command = 'C:\PROGRA~1\nodejs\npx.cmd'
args = ["-y", "mcp-remote@latest", "https://nas-mcp.designflow.app/mcp", "--transport", "http-first", "--header", "Authorization: Bearer e014bedde42998fdd6967a2e8de612a788288413dc3313bec0cdce286e7416e6"]
enabled = true
'@

Add-CodexMcpServer -Name "devops-mcp" -TomlBlock @'
[mcp_servers.devops-mcp]
command = 'C:\PROGRA~1\nodejs\npx.cmd'
args = ["-y", "mcp-remote@latest", "https://mcp.designflow.app/mcp", "--transport", "http-first", "--header", "Authorization: Bearer dafd7ba23fbfa9889879e372f947dfaf25bc4491e1f45198936da3ebef39ee7f"]
'@

Add-CodexMcpServer -Name "vercel" -TomlBlock @'
[mcp_servers.vercel]
command = 'C:\PROGRA~1\nodejs\npx.cmd'
args = ["-y", "mcp-remote@latest", "https://mcp.vercel.com"]
'@

Add-CodexMcpServer -Name "ag-grid" -TomlBlock @'
[mcp_servers.ag-grid]
command = "npx"
args = ["-y", "ag-mcp"]

[mcp_servers.ag-grid.tools.search_docs]
approval_mode = "approve"
'@

Add-CodexMcpServer -Name "trigger" -TomlBlock @'
[mcp_servers.trigger]
command = 'C:\PROGRA~1\nodejs\npx.cmd'
args = ["-y", "trigger.dev@latest", "mcp"]

[mcp_servers.trigger.env]
TRIGGER_ACCESS_TOKEN = "tr_pat_yep2ozuh7z9vp9iy4rca38ysmbqmogcka4sajy1p"
'@

Add-CodexMcpServer -Name "recall-ai" -TomlBlock @'
[mcp_servers.recall-ai]
command = 'C:\PROGRA~1\nodejs\npx.cmd'
args = ["-y", "mcp-remote@latest", "https://us-east-1.recall.ai/mcp", "--transport", "http-first", "--header", "Authorization: Bearer 89b3636a5f204fa9e7ec4c723c4e63f01a753378"]
'@

Add-CodexMcpServer -Name "1password" -TomlBlock @'
[mcp_servers."1password"]
command = 'C:\PROGRA~1\nodejs\npx.cmd'
args = ["-y", "@u2giants/1password-mcp"]

[mcp_servers."1password".env]
OP_SERVICE_ACCOUNT_TOKEN = "ops_eyJzaWduSW5BZGRyZXNzIjoibXkuMXBhc3N3b3JkLmNvbSIsInVzZXJBdXRoIjp7Im1ldGhvZCI6IlNSUGctNDA5NiIsImFsZyI6IlBCRVMyZy1IUzI1NiIsIml0ZXJhdGlvbnMiOjY1MDAwMCwic2FsdCI6Im1McHhQWlExbHhFazcwY1Y1WXdkZUEifSwiZW1haWwiOiJkNndheTU3eHJjdmUyQDFwYXNzd29yZHNlcnZpY2VhY2NvdW50cy5jb20iLCJzcnBYIjoiYTYzMDRiMGJkMmYzNWMzZTlhZmE3OWU3NmQ2MzY5YzNjMDNkMzM4ZjliMmE1MzdhY2ExMDM3ZDg0MDkxMjBiZSIsIm11ayI6eyJhbGciOiJBMjU2R0NNIiwiZXh0Ijp0cnVlLCJrIjoiZFc4TmUzWWxBNVA3TUJJclNYMFBlaWtQcUVLQnpnb0pzYkVDU0dVbV9RMCIsImtleV9vcHMiOlsiZW5jcnlwdCIsImRlY3J5cHQiXSwia3R5Ijoib2N0Iiwia2lkIjoibXAifSwic2VjcmV0S2V5IjoiQTMtSlg0RzhKLTVCTU5GNy1HUEZDVi1OQjg0TC1RNDU3QS1NNEdENiIsInRocm90dGxlU2VjcmV0Ijp7InNlZWQiOiIyN2JiY2JjNTk1ODllOGFlMjZkMGNiZDNkOGY4YzAxZjYwOTk5Mjc1YTE2YWMxYTAzMDg1NTllZTU5OGY5Nzc5IiwidXVpZCI6IjJHV0tOU0xUUkpFNEJQM1pHVFBBVEw1NUhFIn0sImRldmljZVV1aWQiOiJoZ3ViNGd6NGFpajRjMnF5dmZwNXZmb2ZtaSJ9"
'@

$codexConfig | Set-Content -LiteralPath $codexConfigPath -Encoding UTF8
Write-Host "Codex config updated."

Write-Host ""
Write-Host "Done. Codex MCP config updated only at: $codexConfigPath"