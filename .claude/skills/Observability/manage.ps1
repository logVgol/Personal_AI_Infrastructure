# Observability Dashboard Manager (PowerShell)
# Location: .claude/Observability/manage.ps1

param (
    [Parameter(Mandatory=$true)]
    [ValidateSet("start", "stop", "restart", "status")]
    [string]$Action
)

$ScriptDir = $PSScriptRoot
$ServerDir = Join-Path $ScriptDir "apps\server"
$ClientDir = Join-Path $ScriptDir "apps\client"

function Test-Port ($Port) {
    $Conn = Get-NetTCPConnection -LocalPort $Port -ErrorAction SilentlyContinue
    return $null -ne $Conn
}

function Stop-Port ($Port) {
    $Conns = Get-NetTCPConnection -LocalPort $Port -ErrorAction SilentlyContinue
    foreach ($Conn in $Conns) {
        $ProcId = $Conn.OwningProcess
        if ($ProcId) {
            Stop-Process -Id $ProcId -Force -ErrorAction SilentlyContinue
        }
    }
}

switch ($Action) {
    "start" {
        if (Test-Port 4000) {
            Write-Host "❌ Already running. Use: .\manage.ps1 -Action restart"
            exit 1
        }

        Write-Host "Starting Server..."
        $ServerProcess = Start-Process bun -ArgumentList "run dev" -WorkingDirectory $ServerDir -PassThru -NoNewWindow

        # Wait for server
        for ($i=0; $i -lt 10; $i++) {
            if (Test-Port 4000) { break }
            Start-Sleep -Seconds 1
        }

        Write-Host "Starting Client..."
        $ClientProcess = Start-Process bun -ArgumentList "run dev" -WorkingDirectory $ClientDir -PassThru -NoNewWindow

        # Wait for client
        for ($i=0; $i -lt 10; $i++) {
            if (Test-Port 5172) { break }
            Start-Sleep -Seconds 1
        }

        Write-Host "✅ Observability running at http://localhost:5172"
        Write-Host "Press Ctrl+C to stop..."

        try {
            # Keep script running to monitor processes
            while ($true) {
                if ($ServerProcess.HasExited -or $ClientProcess.HasExited) {
                    Write-Warning "One of the processes exited unexpectedly."
                    break
                }
                Start-Sleep -Seconds 1
            }
        } finally {
            # Cleanup on exit
            Stop-Process -Id $ServerProcess.Id -Force -ErrorAction SilentlyContinue
            Stop-Process -Id $ClientProcess.Id -Force -ErrorAction SilentlyContinue
            Write-Host "Stopped."
        }
    }

    "stop" {
        Stop-Port 4000
        Stop-Port 5172
        
        # Clean WAL files
        $Wal = Join-Path $ServerDir "events.db-wal"
        $Shm = Join-Path $ServerDir "events.db-shm"
        if (Test-Path $Wal) { Remove-Item $Wal -Force -ErrorAction SilentlyContinue }
        if (Test-Path $Shm) { Remove-Item $Shm -Force -ErrorAction SilentlyContinue }

        Write-Host "✅ Observability stopped"
    }

    "restart" {
        Write-Host "🔄 Restarting..."
        & $PSCommandPath -Action stop
        Start-Sleep -Seconds 1
        & $PSCommandPath -Action start
    }

    "status" {
        if (Test-Port 4000) {
            Write-Host "✅ Running at http://localhost:5172"
        } else {
            Write-Host "❌ Not running"
        }
    }
}
