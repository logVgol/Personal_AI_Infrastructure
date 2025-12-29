# PAI Statusline - PowerShell Version
# Customizable status display for Gemini CLI

$ErrorActionPreference = "SilentlyContinue"

# --- Configuration ---
$paiDir = $env:PAI_DIR
if (-not $paiDir) {
    $paiDir = Join-Path $env:USERPROFILE ".claude"
}
$envFile = Join-Path $paiDir ".env"
if (Test-Path $envFile) {
    Get-Content $envFile | ForEach-Object {
        if ($_ -match '^(?<key>[^=]+)=(?<value>.*)$') {
            [System.Environment]::SetEnvironmentVariable($Matches['key'], $Matches['value'])
        }
    }
}

# --- Read Input (JSON) ---
$inputData = $input | Out-String | ConvertFrom-Json

# --- Environment Variables ---
$daName = $env:DA
if (-not $daName) { $daName = "Assistant" }

# --- Extract Data ---
$currentDir = $inputData.workspace.current_dir
if (-not $currentDir) { $currentDir = Get-Location }
$modelName = $inputData.model.display_name
if (-not $modelName) { $modelName = "Gemini" }
$ccVersion = $inputData.version
if (-not $ccVersion) { $ccVersion = "unknown" }
$dirName = Split-Path $currentDir -Leaf

# --- Colors (Using generic ANSI for compatibility) ---
$RESET = [char]27 + "[0m"
$PURPLE = [char]27 + "[35m"
$BLUE = [char]27 + "[34m"
$GREEN = [char]27 + "[32m"
$CYAN = [char]27 + "[36m"
$YELLOW = [char]27 + "[33m"
$RED = [char]27 + "[31m"

$daColor = $PURPLE # Default

# --- MCP Count & Names ---
$mcpNames = @()
$settingsFile = Join-Path $paiDir "settings.json"
if (Test-Path $settingsFile) {
    try {
        $settings = Get-Content $settingsFile -Raw | ConvertFrom-Json
        if ($settings.mcpServers) {
            $mcpNames = $settings.mcpServers.PSObject.Properties.Name
        }
    } catch {}
}
$mcpCount = $mcpNames.Count
$mcpDisplay = $mcpNames -join ", "
if (-not $mcpDisplay) { $mcpDisplay = "None" }

# --- Token Usage (Stubbed for now, hard to get without external tool) ---
$dailyTokens = "N/A"
$dailyCost = "N/A"

# --- Output ---
# Line 1: Greeting
Write-Host -NoNewline "$RESET👋 $($daColor)`"$daName here, ready to go...`"$RESET $PURPLE Running Gemini CLI $ccVersion $RESET $PURPLE 🧠 $modelName $RESET in $CYAN 📁 $dirName $RESET`n"

# Line 2: MCPs
Write-Host -NoNewline "$BLUE 🔌 MCPs$RESET: $BLUE$($mcpDisplay)$RESET`n"

# Line 3: Stats
Write-Host -NoNewline "$GREEN 💎 Total Tokens$RESET: $GREEN$($dailyTokens)$RESET  $GREEN Total Cost$RESET: $GREEN$($dailyCost)$RESET`n"
