# Update Fabric patterns from upstream (PowerShell)
# Location: .claude/skills/Fabric/tools/update-patterns.ps1

$FabricPatternsSource = Join-Path $Env:USERPROFILE ".config\fabric\patterns"
$PaiPatternsDir = Join-Path $PSScriptRoot "patterns"

Write-Host "Updating Fabric patterns..." -ForegroundColor Cyan

# Check if fabric is installed
if (-not (Get-Command fabric -ErrorAction SilentlyContinue)) {
    Write-Host "Error: fabric CLI not installed" -ForegroundColor Red
    Write-Host "Install with: go install github.com/danielmiessler/fabric@latest" -ForegroundColor Yellow
    exit 1
}

# Update patterns using fabric CLI
Write-Host "Pulling latest patterns from fabric..."
fabric -U

# Then sync to PAI's local copy using robocopy (equivalent to rsync -av --delete)
Write-Host "Syncing to PAI patterns directory..."
if (-not (Test-Path $PaiPatternsDir)) {
    New-Item -ItemType Directory -Force -Path $PaiPatternsDir | Out-Null
}

# robocopy /MIR is "Mirror" which acts like rsync --delete
# /XD .git (optional, exclude git if it existed)
# /NFL /NDL /NJH /NJS (silent flags if needed, but we'll keep some output)
robocopy $FabricPatternsSource $PaiPatternsDir /MIR /Z /R:5 /W:5

# Count patterns
$PatternCount = (Get-ChildItem $PaiPatternsDir).Count

Write-Host "`nUpdated $PatternCount patterns in $PaiPatternsDir" -ForegroundColor Green
Write-Host "Patterns are now available for native Gemini CLI usage."
