# ============================================================
# Claude MCP Setup Script - Albert's Full MCP Stack
# Run this on any new Windows PC after installing Claude Desktop
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

# Step 2: Install uv (required by Windows-MCP extension)
Write-Host "Installing uv..."
powershell -ExecutionPolicy Bypass -c "irm https://astral.sh/uv/install.ps1 | iex"
Write-Host "uv installed."

# ============================================================
# Safety helpers
# ============================================================
# This script must be self-healing: if Claude JSON is malformed, this script backs up
# the broken file to a single overwritten .broken.bak file and rebuilds valid JSON.
# Do NOT create backup chains like .bak.bak or multiple timestamped backups.
function New-EmptyMcpConfig {
    return [PSCustomObject]@{ mcpServers = [PSCustomObject]@{} }
}

function Read-JsonConfigOrNew {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,

        [Parameter(Mandatory = $true)]
        [string]$Label
    )

    if (-not (Test-Path -LiteralPath $Path)) {
        Write-Host "No existing $Label found, creating new one..."
        return (New-EmptyMcpConfig)
    }

    try {
        $raw = Get-Content -LiteralPath $Path -Raw -ErrorAction Stop
        if ([string]::IsNullOrWhiteSpace($raw)) {
            Write-Host "Existing $Label is empty, rebuilding..."
            return (New-EmptyMcpConfig)
        }

        $parsed = $raw | ConvertFrom-Json -ErrorAction Stop
        Write-Host "Found existing $Label, merging..."
        return $parsed
    } catch {
        $brokenBackupPath = "$Path.broken.bak"
        Copy-Item -LiteralPath $Path -Destination $brokenBackupPath -Force -ErrorAction SilentlyContinue
        Write-Warning "$Label was invalid JSON. Saved the broken file to: $brokenBackupPath"
        Write-Warning "Rebuilding $Label as valid JSON so the app can launch."
        return (New-EmptyMcpConfig)
    }
}

function Write-JsonConfigUtf8NoBom {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,

        [Parameter(Mandatory = $true)]
        [object]$Object
    )

    $json = $Object | ConvertTo-Json -Depth 20
    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($Path, $json + [Environment]::NewLine, $utf8NoBom)
}

# Step 3: Read existing Claude Desktop config or create fresh
$configPath = "$env:LOCALAPPDATA\Packages\Claude_pzs8sxrjxfjjc\LocalCache\Roaming\Claude\claude_desktop_config.json"
New-Item -ItemType Directory -Force -Path (Split-Path $configPath) | Out-Null

$config = Read-JsonConfigOrNew -Path $configPath -Label "Claude Desktop config"

if (-not $config.mcpServers) {
    $config | Add-Member -NotePropertyName "mcpServers" -NotePropertyValue ([PSCustomObject]@{})
}

# Step 4: Add playwright (official package, full npx path)
$playwrightMcp = [PSCustomObject]@{
    command = "C:\PROGRA~1\nodejs\npx.cmd"
    args    = @("-y", "@playwright/mcp@latest")
}
$config.mcpServers | Add-Member -NotePropertyName "playwright" -NotePropertyValue $playwrightMcp -Force

# Step 5: Add synology-monitor (http-first transport)
$synologyMonitor = [PSCustomObject]@{
    command = "C:\PROGRA~1\nodejs\npx.cmd"
    args    = @(
        "-y",
        "mcp-remote@latest",
        "https://nas-mcp.designflow.app/mcp",
        "--transport", "http-first",
        "--header", "Authorization: Bearer 14cde11e584136b15306c03d160ce9536da4f87f82d74c6d728a6c8cb6dd2122"
    )
}
$config.mcpServers | Add-Member -NotePropertyName "synology-monitor" -NotePropertyValue $synologyMonitor -Force

# Step 6: Add devops-mcp (http-first transport)
$devopsMcp = [PSCustomObject]@{
    command = "C:\PROGRA~1\nodejs\npx.cmd"
    args    = @(
        "-y",
        "mcp-remote@latest",
        "https://mcp.designflow.app/mcp",
        "--transport", "http-first",
        "--header", "Authorization: Bearer xBY2IHFwVfXnVUZ3rwfs-zW0jdf4BO2oO8iB1TjRs-0"
    )
}
$config.mcpServers | Add-Member -NotePropertyName "devops-mcp" -NotePropertyValue $devopsMcp -Force

# Step 6b: Add vercel (official Vercel remote MCP, OAuth via mcp-remote)
$vercelMcp = [PSCustomObject]@{
    command = "C:\PROGRA~1\nodejs\npx.cmd"
    args    = @(
        "-y",
        "mcp-remote@latest",
        "https://mcp.vercel.com"
    )
}
$config.mcpServers | Add-Member -NotePropertyName "vercel" -NotePropertyValue $vercelMcp -Force

# Step 6c: Add ag-mcp (skip if already exists)
if (-not ($config.mcpServers.PSObject.Properties.Name -contains "ag-grid")) {
    $agMcp = [PSCustomObject]@{
        command = "C:\PROGRA~1\nodejs\npx.cmd"
        args    = @("-y", "ag-mcp")
    }
    $config.mcpServers | Add-Member -NotePropertyName "ag-grid" -NotePropertyValue $agMcp
    Write-Host "ag-grid MCP added."
} else {
    Write-Host "ag-grid MCP already exists in config, skipping."
}

# Step 6d: Add trigger (Trigger.dev official MCP — local stdio via CLI; auth via PAT)
$triggerMcp = [PSCustomObject]@{
    command = "C:\PROGRA~1\nodejs\npx.cmd"
    args    = @("-y", "trigger.dev@latest", "mcp")
    env     = [PSCustomObject]@{
        # Personal Access Token: Trigger.dev -> Account -> Personal Access Tokens (starts with tr_pat_).
        # REPLACE the placeholder. (Add "--dev-only" to args above to restrict to the dev environment.)
        TRIGGER_ACCESS_TOKEN = "tr_pat_yep2ozuh7z9vp9iy4rca38ysmbqmogcka4sajy1p"
    }
}
$config.mcpServers | Add-Member -NotePropertyName "trigger" -NotePropertyValue $triggerMcp -Force

# Step 7: Write Claude Desktop config back
Write-JsonConfigUtf8NoBom -Path $configPath -Object $config
Write-Host ""
Write-Host "Claude Desktop config updated with: playwright, synology-monitor, devops-mcp, vercel, ag-grid, trigger"

# ============================================================
# Step 8: Also configure Claude Code global settings
# ============================================================
Write-Host ""
Write-Host "Configuring Claude Code global MCP settings..."

$claudeCodeSettingsPath = "$env:USERPROFILE\.claude\settings.json"
New-Item -ItemType Directory -Force -Path "$env:USERPROFILE\.claude" | Out-Null

$ccConfig = Read-JsonConfigOrNew -Path $claudeCodeSettingsPath -Label "Claude Code settings"

if (-not $ccConfig.mcpServers) {
    $ccConfig | Add-Member -NotePropertyName "mcpServers" -NotePropertyValue ([PSCustomObject]@{})
}

# devops-mcp
$ccDevopsMcp = [PSCustomObject]@{
    url     = "https://mcp.designflow.app/mcp"
    headers = [PSCustomObject]@{
        Authorization = "Bearer xBY2IHFwVfXnVUZ3rwfs-zW0jdf4BO2oO8iB1TjRs-0"
    }
}
$ccConfig.mcpServers | Add-Member -NotePropertyName "devops-mcp" -NotePropertyValue $ccDevopsMcp -Force

# synology-monitor
$ccSynologyMonitor = [PSCustomObject]@{
    url     = "https://nas-mcp.designflow.app/mcp"
    headers = [PSCustomObject]@{
        Authorization = "Bearer 14cde11e584136b15306c03d160ce9536da4f87f82d74c6d728a6c8cb6dd2122"
    }
}
$ccConfig.mcpServers | Add-Member -NotePropertyName "synology-monitor" -NotePropertyValue $ccSynologyMonitor -Force

# playwright
$ccPlaywright = [PSCustomObject]@{
    command = "C:\PROGRA~1\nodejs\npx.cmd"
    args    = @("-y", "@playwright/mcp@latest")
}
$ccConfig.mcpServers | Add-Member -NotePropertyName "playwright" -NotePropertyValue $ccPlaywright -Force

# vercel (OAuth via mcp-remote — must use command form, not url+headers)
$ccVercel = [PSCustomObject]@{
    command = "C:\PROGRA~1\nodejs\npx.cmd"
    args    = @("-y", "mcp-remote@latest", "https://mcp.vercel.com")
}
$ccConfig.mcpServers | Add-Member -NotePropertyName "vercel" -NotePropertyValue $ccVercel -Force

# ag-mcp (skip if already exists)
if (-not ($ccConfig.mcpServers.PSObject.Properties.Name -contains "ag-grid")) {
    $ccAgMcp = [PSCustomObject]@{
        command = "C:\PROGRA~1\nodejs\npx.cmd"
        args    = @("-y", "ag-mcp")
    }
    $ccConfig.mcpServers | Add-Member -NotePropertyName "ag-grid" -NotePropertyValue $ccAgMcp
    Write-Host "ag-grid MCP added to Claude Code settings."
} else {
    Write-Host "ag-grid MCP already exists in Claude Code settings, skipping."
}

# trigger (Trigger.dev official MCP — local stdio via CLI; auth via PAT)
$ccTrigger = [PSCustomObject]@{
    command = "C:\PROGRA~1\nodejs\npx.cmd"
    args    = @("-y", "trigger.dev@latest", "mcp")
    env     = [PSCustomObject]@{
        TRIGGER_ACCESS_TOKEN = "tr_pat_yep2ozuh7z9vp9iy4rca38ysmbqmogcka4sajy1p"
    }
}
$ccConfig.mcpServers | Add-Member -NotePropertyName "trigger" -NotePropertyValue $ccTrigger -Force

Write-JsonConfigUtf8NoBom -Path $claudeCodeSettingsPath -Object $ccConfig
Write-Host "Claude Code settings updated."

# ============================================================
# Step 9: Also configure Codex global MCP settings
# Recall.ai belongs here, and ONLY here. Do not add it to Claude Desktop or Claude Code.
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
    return [Regex]::IsMatch($ConfigText, "(?m)^\[mcp_servers\.$escapedName\]\s*$")
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
args = ["-y", "mcp-remote@latest", "https://nas-mcp.designflow.app/mcp", "--transport", "http-first", "--header", "Authorization: Bearer 14cde11e584136b15306c03d160ce9536da4f87f82d74c6d728a6c8cb6dd2122"]
enabled = true
'@

Add-CodexMcpServer -Name "devops-mcp" -TomlBlock @'
[mcp_servers.devops-mcp]
command = 'C:\PROGRA~1\nodejs\npx.cmd'
args = ["-y", "mcp-remote@latest", "https://mcp.designflow.app/mcp", "--transport", "http-first", "--header", "Authorization: Bearer xBY2IHFwVfXnVUZ3rwfs-zW0jdf4BO2oO8iB1TjRs-0"]
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

$codexConfig | Set-Content -LiteralPath $codexConfigPath -Encoding UTF8
Write-Host "Codex config updated."

# ============================================================
# IMPORTANT: Windows-MCP must be installed manually
# ============================================================
Write-Host ""
Write-Host "============================================================"
Write-Host "MANUAL STEP REQUIRED: Windows-MCP Extension"
Write-Host "------------------------------------------------------------"
Write-Host "1. Open Claude Desktop"
Write-Host "2. Go to Settings -> Extensions"
Write-Host "3. Find 'Windows MCP' and click Install"
Write-Host "4. After installing, QUIT and reopen Claude Desktop"
Write-Host "============================================================"
