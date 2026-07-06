# ============================================================
# Claude MCP Setup Script - Albert's Claude Desktop + Code Only
# Runs on any new Windows PC after installing Claude Desktop
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

    Write-Host "Reading $Label from: $Path"
    if (-not (Test-Path -LiteralPath $Path)) {
        Write-Host "No existing $Label found at that path. Creating a new one from scratch."
        return (New-EmptyMcpConfig)
    }

    try {
        $raw = Get-Content -LiteralPath $Path -Raw -ErrorAction Stop
        if ([string]::IsNullOrWhiteSpace($raw)) {
            Write-Host "Existing $Label is present but empty. Rebuilding it as a fresh config."
            return (New-EmptyMcpConfig)
        }

        $parsed = $raw | ConvertFrom-Json -ErrorAction Stop
        Write-Host "Found valid existing $Label. Merging new MCP servers into it."
        return $parsed
    } catch {
        Write-Warning "$Label contained INVALID JSON and could not be parsed."
        Write-Warning "Parse error was: $($_.Exception.Message)"
        $brokenBackupPath = "$Path.broken.bak"
        Write-Host "Backing up the broken file to: $brokenBackupPath (overwrites any previous .broken.bak)"
        try {
            Copy-Item -LiteralPath $Path -Destination $brokenBackupPath -Force -ErrorAction Stop
            Write-Host "Backup of broken file saved successfully."
        } catch {
            Write-Warning "Could NOT save backup of the broken file: $($_.Exception.Message)"
        }
        Write-Warning "Rebuilding $Label as valid JSON so the app can launch. The old (broken) contents are in the .broken.bak file above."
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

    Write-Host "Writing config to: $Path (UTF-8 without BOM)"
    $json = $Object | ConvertTo-Json -Depth 20
    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($Path, $json + [Environment]::NewLine, $utf8NoBom)
    Write-Host "Wrote $($json.Length) characters successfully."
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
        "--header", "Authorization: Bearer e014bedde42998fdd6967a2e8de612a788288413dc3313bec0cdce286e7416e6"
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
        "--header", "Authorization: Bearer dafd7ba23fbfa9889879e372f947dfaf25bc4491e1f45198936da3ebef39ee7f"
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

# Step 6e: Add recall-ai (http transport via mcp-remote, bearer token auth)
$recallAiMcp = [PSCustomObject]@{
    command = "C:\PROGRA~1\nodejs\npx.cmd"
    args    = @(
        "-y",
        "mcp-remote@latest",
        "https://us-east-1.recall.ai/mcp",
        "--transport", "http-first",
        "--header", "Authorization: Bearer 89b3636a5f204fa9e7ec4c723c4e63f01a753378"
    )
}
$config.mcpServers | Add-Member -NotePropertyName "recall-ai" -NotePropertyValue $recallAiMcp -Force
Write-Host "recall-ai MCP added to Claude Desktop config."

# Step 6f: Add 1password (1Password MCP server)
$onePasswordMcp = [PSCustomObject]@{
    command = "C:\PROGRA~1\nodejs\npx.cmd"
    args    = @("-y", "@u2giants/1password-mcp")
    env     = [PSCustomObject]@{
        OP_SERVICE_ACCOUNT_TOKEN = "ops_eyJzaWduSW5BZGRyZXNzIjoibXkuMXBhc3N3b3JkLmNvbSIsInVzZXJBdXRoIjp7Im1ldGhvZCI6IlNSUGctNDA5NiIsImFsZyI6IlBCRVMyZy1IUzI1NiIsIml0ZXJhdGlvbnMiOjY1MDAwMCwic2FsdCI6Im1McHhQWlExbHhFazcwY1Y1WXdkZUEifSwiZW1haWwiOiJkNndheTU3eHJjdmUyQDFwYXNzd29yZHNlcnZpY2VhY2NvdW50cy5jb20iLCJzcnBYIjoiYTYzMDRiMGJkMmYzNWMzZTlhZmE3OWU3NmQ2MzY5YzNjMDNkMzM4ZjliMmE1MzdhY2ExMDM3ZDg0MDkxMjBiZSIsIm11ayI6eyJhbGciOiJBMjU2R0NNIiwiZXh0Ijp0cnVlLCJrIjoiZFc4TmUzWWxBNVA3TUJJclNYMFBlaWtQcUVLQnpnb0pzYkVDU0dVbV9RMCIsImtleV9vcHMiOlsiZW5jcnlwdCIsImRlY3J5cHQiXSwia3R5Ijoib2N0Iiwia2lkIjoibXAifSwic2VjcmV0S2V5IjoiQTMtSlg0RzhKLTVCTU5GNy1HUEZDVi1OQjg0TC1RNDU3QS1NNEdENiIsInRocm90dGxlU2VjcmV0Ijp7InNlZWQiOiIyN2JiY2JjNTk1ODllOGFlMjZkMGNiZDNkOGY4YzAxZjYwOTk5Mjc1YTE2YWMxYTAzMDg1NTllZTU5OGY5Nzc5IiwidXVpZCI6IjJHV0tOU0xUUkpFNEJQM1pHVFBBVEw1NUhFIn0sImRldmljZVV1aWQiOiJoZ3ViNGd6NGFpajRjMnF5dmZwNXZmb2ZtaSJ9"
    }
}
$config.mcpServers | Add-Member -NotePropertyName "1password" -NotePropertyValue $onePasswordMcp -Force
Write-Host "1password MCP added to Claude Desktop config."

# Step 7: Write Claude Desktop config back
Write-JsonConfigUtf8NoBom -Path $configPath -Object $config
Write-Host ""
Write-Host "Claude Desktop config updated with: playwright, synology-monitor, devops-mcp, vercel, ag-grid, trigger, recall-ai, 1password"

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
        Authorization = "Bearer dafd7ba23fbfa9889879e372f947dfaf25bc4491e1f45198936da3ebef39ee7f"
    }
}
$ccConfig.mcpServers | Add-Member -NotePropertyName "devops-mcp" -NotePropertyValue $ccDevopsMcp -Force

# synology-monitor
$ccSynologyMonitor = [PSCustomObject]@{
    url     = "https://nas-mcp.designflow.app/mcp"
    headers = [PSCustomObject]@{
        Authorization = "Bearer e014bedde42998fdd6967a2e8de612a788288413dc3313bec0cdce286e7416e6"
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

# 1password
$ccOnePassword = [PSCustomObject]@{
    command = "C:\PROGRA~1\nodejs\npx.cmd"
    args    = @("-y", "@u2giants/1password-mcp")
    env     = [PSCustomObject]@{
        OP_SERVICE_ACCOUNT_TOKEN = "ops_eyJzaWduSW5BZGRyZXNzIjoibXkuMXBhc3N3b3JkLmNvbSIsInVzZXJBdXRoIjp7Im1ldGhvZCI6IlNSUGctNDA5NiIsImFsZyI6IlBCRVMyZy1IUzI1NiIsIml0ZXJhdGlvbnMiOjY1MDAwMCwic2FsdCI6Im1McHhQWlExbHhFazcwY1Y1WXdkZUEifSwiZW1haWwiOiJkNndheTU3eHJjdmUyQDFwYXNzd29yZHNlcnZpY2VhY2NvdW50cy5jb20iLCJzcnBYIjoiYTYzMDRiMGJkMmYzNWMzZTlhZmE3OWU3NmQ2MzY5YzNjMDNkMzM4ZjliMmE1MzdhY2ExMDM3ZDg0MDkxMjBiZSIsIm11ayI6eyJhbGciOiJBMjU2R0NNIiwiZXh0Ijp0cnVlLCJrIjoiZFc4TmUzWWxBNVA3TUJJclNYMFBlaWtQcUVLQnpnb0pzYkVDU0dVbV9RMCIsImtleV9vcHMiOlsiZW5jcnlwdCIsImRlY3J5cHQiXSwia3R5Ijoib2N0Iiwia2lkIjoibXAifSwic2VjcmV0S2V5IjoiQTMtSlg0RzhKLTVCTU5GNy1HUEZDVi1OQjg0TC1RNDU3QS1NNEdENiIsInRocm90dGxlU2VjcmV0Ijp7InNlZWQiOiIyN2JiY2JjNTk1ODllOGFlMjZkMGNiZDNkOGY4YzAxZjYwOTk5Mjc1YTE2YWMxYTAzMDg1NTllZTU5OGY5Nzc5IiwidXVpZCI6IjJHV0tOU0xUUkpFNEJQM1pHVFBBVEw1NUhFIn0sImRldmljZVV1aWQiOiJoZ3ViNGd6NGFpajRjMnF5dmZwNXZmb2ZtaSJ9"
    }
}
$ccConfig.mcpServers | Add-Member -NotePropertyName "1password" -NotePropertyValue $ccOnePassword -Force
Write-Host "1password MCP added to Claude Code settings."

Write-JsonConfigUtf8NoBom -Path $claudeCodeSettingsPath -Object $ccConfig
Write-Host "Claude Code settings updated."

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