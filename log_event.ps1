# PAI Event Logger for Windows/PowerShell
param(
    [string]$Type = "Log",
    [string]$Payload = "{}",
    [string]$Agent = "Gemini"
)

# 1. Resolve PAI_DIR
$PaiDir = Join-Path $PSScriptRoot ".claude"
if ($Env:PAI_DIR) { $PaiDir = $Env:PAI_DIR }

# 2. Get PST Timestamp (approximate if TZ not available, but trying to be accurate)
# Windows doesn't easily do IANA timezones without .NET calls
try {
    $Timezone = [System.TimeZoneInfo]::FindSystemTimeZoneById("Pacific Standard Time")
    $PstTime = [System.TimeZoneInfo]::ConvertTimeFromUtc([DateTime]::UtcNow, $Timezone)
} catch {
    # Fallback to local time if PST not found
    $PstTime = Get-Date
}

$TimestampPst = $PstTime.ToString("yyyy-MM-dd HH:mm:ss 'PST'")
$Year = $PstTime.Year
$Month = $PstTime.ToString("MM")
$Day = $PstTime.ToString("dd")

# 3. Determine File Path
$LogDir = Join-Path $PaiDir "history\raw-outputs\$Year-$Month"
if (-not (Test-Path $LogDir)) {
    New-Item -ItemType Directory -Force -Path $LogDir | Out-Null
}

$LogFile = Join-Path $LogDir "$Year-$Month-${Day}_all-events.jsonl"

# 4. Construct Event
# Parse Payload if it's a string, to ensure it's valid JSON
try {
    $PayloadObj = $Payload | ConvertFrom-Json
} catch {
    $PayloadObj = @{ message = $Payload }
}

$Event = @{
    source_app = $Agent
    session_id = "gemini-session-cli"
    hook_event_type = $Type
    payload = $PayloadObj
    timestamp = [int64](([DateTimeOffset]::UtcNow).ToUnixTimeMilliseconds())
    timestamp_pst = $TimestampPst
}

# 5. Write to file
$EventJson = $Event | ConvertTo-Json -Compress -Depth 10
Add-Content -Path $LogFile -Value $EventJson -Encoding UTF8

Write-Host "Event logged to $LogFile"
