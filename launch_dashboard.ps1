# Launch PAI Observability Dashboard
$ScriptDir = Split-Path $MyInvocation.MyCommand.Path

# Prefer the manage.ps1 in skills/Observability if it exists
$ManageScript = Join-Path $ScriptDir ".claude\skills\Observability\manage.ps1"

if (-not (Test-Path $ManageScript)) {
    # Fallback to the one in .claude/Observability
    $ManageScript = Join-Path $ScriptDir ".claude\Observability\manage.ps1"
}

if (Test-Path $ManageScript) {
    Write-Host "Launching via manage.ps1..." -ForegroundColor Cyan
    & $ManageScript -Action start
} else {
    Write-Error "Could not find manage.ps1 script."
    exit 1
}