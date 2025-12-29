# Stop observability dashboard - silent operation (PowerShell)
# Location: .claude/Observability/scripts/reset-system.ps1

$ScriptDir = $PSScriptRoot
$ManageScript = Join-Path $ScriptDir "..\manage.ps1"

if (Test-Path $ManageScript) {
    & $ManageScript -Action stop
} else {
    Write-Error "Could not find manage.ps1"
}
