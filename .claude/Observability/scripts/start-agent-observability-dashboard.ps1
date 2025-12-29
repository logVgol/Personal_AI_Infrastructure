# Start observability dashboard (PowerShell)
# Location: .claude/Observability/scripts/start-agent-observability-dashboard.ps1

$ScriptDir = $PSScriptRoot
$ManageScript = Join-Path $ScriptDir "..\manage.ps1"

if (Test-Path $ManageScript) {
    & $ManageScript -Action start
} else {
    Write-Error "Could not find manage.ps1"
}
