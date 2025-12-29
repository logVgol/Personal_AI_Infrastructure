# Multi-Agent Observability System Test (PowerShell)
# Location: .claude/Observability/scripts/test-system.ps1

Write-Host "🚀 Multi-Agent Observability System Test" -ForegroundColor Cyan
Write-Host "========================================"

$ScriptDir = $PSScriptRoot
$ProjectRoot = Split-Path $ScriptDir -Parent
$ServerDir = Join-Path $ProjectRoot "apps\server"

# Step 1: Start the server
Write-Host "`nStep 1: Starting server..." -ForegroundColor Green
$ServerProcess = Start-Process bun -ArgumentList "run start" -WorkingDirectory $ServerDir -PassThru -NoNewWindow
Start-Sleep -Seconds 3

if ($ServerProcess -and -not $ServerProcess.HasExited) {
    Write-Host "✅ Server started successfully (PID: $($ServerProcess.Id))"
} else {
    Write-Host "❌ Server failed to start" -ForegroundColor Red
    exit 1
}

# Step 2: Test sending an event
Write-Host "`nStep 2: Testing event endpoint..." -ForegroundColor Green
$EventBody = @{
    source_app = "test"
    session_id = "test-123"
    hook_event_type = "PreToolUse"
    payload = @{
        tool = "Bash"
        command = "ls -la"
    }
} | ConvertTo-Json

try {
    $Response = Invoke-RestMethod -Uri "http://localhost:4000/events" -Method Post -Body $EventBody -ContentType "application/json"
    Write-Host "✅ Event sent successfully"
    Write-Host "Response: $($Response | ConvertTo-Json -Compress)"
} catch {
    Write-Host "❌ Failed to send event: $($_.Exception.Message)" -ForegroundColor Red
}

# Step 3: Test filter options
Write-Host "`nStep 3: Testing filter options endpoint..." -ForegroundColor Green
try {
    $Filters = Invoke-RestMethod -Uri "http://localhost:4000/events/filter-options"
    Write-Host "✅ Filter options retrieved"
    Write-Host "Filters: $($Filters | ConvertTo-Json -Compress)"
} catch {
    Write-Host "❌ Failed to get filter options" -ForegroundColor Red
}

# Cleanup
Write-Host "`nCleaning up..." -ForegroundColor Green
Stop-Process -Id $ServerProcess.Id -Force -ErrorAction SilentlyContinue
Write-Host "✅ Server stopped"

Write-Host "`nTest complete!" -ForegroundColor Green
