# ============================================ 
# PAI (Personal AI Infrastructure) Setup Script (Windows/PowerShell)
# ============================================ 

param (
    [switch]$Unattended = $false,
    [string]$InstallPath = ""
)

$ErrorActionPreference = "Stop"

# Colors
$Green = "Green"
$Red = "Red"
$Yellow = "Yellow"
$Cyan = "Cyan"
$Magenta = "Magenta"

function Print-Header ($Message) {
    Write-Host "" 
    Write-Host ("=" * 50) -ForegroundColor $Magenta
    Write-Host "  $Message" -ForegroundColor $Magenta
    Write-Host ("=" * 50) -ForegroundColor $Magenta
    Write-Host "" 
}

function Print-Success ($Message) {
    Write-Host "[OK] $Message" -ForegroundColor $Green
}

function Print-Error ($Message) {
    Write-Host "[ERROR] $Message" -ForegroundColor $Red
}

function Print-Warning ($Message) {
    Write-Host "[WARN] $Message" -ForegroundColor $Yellow
}

function Print-Info ($Message) {
    Write-Host "[INFO] $Message" -ForegroundColor $Cyan
}

function Ask-YesNo ($Question, $Default = $true) {
    if ($Unattended) { return $Default }
    $Prompt = if ($Default) { "[Y/n]" } else { "[y/N]" } 
    
    while ($true) {
        $Response = Read-Host -Prompt "$Question $Prompt"
        if ([string]::IsNullOrWhiteSpace($Response)) { return $Default }
        if ($Response -match "^[Yy]") { return $true }
        if ($Response -match "^[Nn]") { return $false }
    }
}

function Ask-Input ($Question, $DefaultValue) {
    if ($Unattended) { return $DefaultValue }
    $Response = Read-Host -Prompt "$Question [$DefaultValue]"
    if ([string]::IsNullOrWhiteSpace($Response)) { return $DefaultValue }
    return $Response
}

function Test-Command ($Cmd) {
    return (Get-Command $Cmd -ErrorAction SilentlyContinue)
}

# ============================================ 
# Welcome
# ============================================ 

Clear-Host
Print-Header "PAI - Personal AI Infrastructure Setup (Windows)"
Write-Host "This script will set up PAI on your Windows machine."
Write-Host "It handles prerequisites, environment variables, and configuration."
Write-Host "" 

if (-not (Ask-YesNo "Ready to get started?")) {
    exit
}

# ============================================ 
# Step 1: Check Prerequisites
# ============================================ 

Print-Header "Step 1: Checking Prerequisites"

$HasGit = [bool](Test-Command git)
if ($HasGit) {
    $GitVer = git --version
    Print-Success "$GitVer is installed"
} else {
    Print-Warning "Git is not installed"
}

$HasBun = [bool](Test-Command bun)
if ($HasBun) {
    $BunVer = bun --version
    Print-Success "Bun $BunVer is installed"
} else {
    Print-Warning "Bun is not installed"
}

# ============================================ 
# Step 2: Install Missing Software
# ============================================ 

if (-not $HasGit -or -not $HasBun) {
    Print-Header "Step 2: Installing Missing Software"
    
    if (-not $HasGit) {
        if (Ask-YesNo "Install Git via Winget?") {
            winget install Git.Git -e --source winget
            $HasGit = $true
        } else {
            Print-Error "Git is required. Please install it manually."
            exit 1
        }
    }

    if (-not $HasBun) {
        if (Ask-YesNo "Install Bun via Powershell installer?") {
            powershell -c "irm bun.sh/install.ps1 | iex"
            # Add to path for current session
            $Env:BUN_INSTALL = "$Env:USERPROFILE\.bun"
            $Env:Path += ";$Env:BUN_INSTALL\bin"
            $HasBun = $true
        } else {
            Print-Warning "Bun is recommended for Voice Server. Skipping."
        }
    }
} else {
    Print-Success "All prerequisites met."
}

# ============================================
# Step 3: Installation Location
# ============================================

Print-Header "Step 3: Installation Location"

if (-not [string]::IsNullOrWhiteSpace($InstallPath)) {
    $PaiDir = $InstallPath
} else {
    $DefaultDir = Join-Path $Env:USERPROFILE "PAI"
    $PaiDir = Ask-Input "Install PAI to:" $DefaultDir
}

Print-Info "Installing to: $PaiDir"
# ============================================ 
# Step 4: Download/Update PAI
# ============================================ 

Print-Header "Step 4: Getting PAI"

if (Test-Path "$PaiDir\.git") {
    Print-Info "PAI already installed."
    if (Ask-YesNo "Update to latest?") {
        Push-Location $PaiDir
        git pull
        Pop-Location
        Print-Success "Updated."
    }
} else {
    if (-not (Test-Path $PaiDir)) {
        New-Item -ItemType Directory -Force -Path $PaiDir | Out-Null
    }
    git clone https://github.com/danielmiessler/Personal_AI_Infrastructure.git $PaiDir
    Print-Success "Downloaded PAI."
}

# ============================================ 
# Step 5: Environment Variables
# ============================================ 

Print-Header "Step 5: Configuring Environment"

$ProfilePath = $PROFILE
if (-not (Test-Path $ProfilePath)) {
    New-Item -ItemType File -Force -Path $ProfilePath | Out-Null
}

$AiName = Ask-Input "Name of your AI Assistant?" "Kai"

# Check if already configured
$ConfigExists = Select-String -Path $ProfilePath -Pattern "PAI_DIR" -Quiet

if (-not $ConfigExists -or (Ask-YesNo "Update environment variables in $ProfilePath?")) {
    $ConfigBlock = @"

# ========== PAI Configuration ========== 
`$Env:PAI_DIR = "$PaiDir"
`$Env:PAI_HOME = "`$Env:USERPROFILE"
`$Env:DA = "$AiName"
# ======================================= 
"@
    Add-Content -Path $ProfilePath -Value $ConfigBlock
    Print-Success "Updated PowerShell Profile."
    
    # Set for current session
    $Env:PAI_DIR = $PaiDir
    $Env:PAI_HOME = $Env:USERPROFILE
    $Env:DA = $AiName
}

# ============================================ 
# Step 6: .env Setup
# ============================================ 

Print-Header "Step 6: Configuring API Keys"

$EnvFile = Join-Path $PaiDir ".env"
$EnvExample = Join-Path $PaiDir ".env.example"

if (-not (Test-Path $EnvFile)) {
    if (Test-Path $EnvExample) {
        Copy-Item $EnvExample $EnvFile
        # Update PAI_DIR in .env
        (Get-Content $EnvFile) -replace 'PAI_DIR="/path/to/PAI"', "PAI_DIR=`"$PaiDir`"" | Set-Content $EnvFile
        Print-Success "Created .env file."
    }
} else {
    Print-Info ".env already exists."
}

if (Ask-YesNo "Edit .env file now?" $false) {
    notepad $EnvFile
}

# ============================================ 
# Step 7: Voice Server
# ============================================ 

if ($HasBun) {
    Print-Header "Step 7: Voice Server Setup"
    $VoiceDir = Join-Path $PaiDir "voice-server"
    
    if (Test-Path $VoiceDir) {
        if (Ask-YesNo "Install Voice Server dependencies?") {
            Push-Location $VoiceDir
            bun install
            Pop-Location
            Print-Success "Dependencies installed."
            
            Print-Info "To start voice server: cd $VoiceDir; bun server.ts"
        }
    }
}

# ============================================ 
# Step 8: Claude/Gemini Integration
# ============================================ 

Print-Header "Step 8: AI Integration"

$ClaudeDir = Join-Path $Env:USERPROFILE ".claude"
if (-not (Test-Path $ClaudeDir)) {
    New-Item -ItemType Directory -Force -Path $ClaudeDir | Out-Null
}

if (Ask-YesNo "Copy PAI config to ~/.claude (for universal access)?") {
    $SourceClaude = Join-Path $PaiDir ".claude"
    
    # Copy subdirectories
    foreach ($Item in @("hooks", "skills", "commands", "Tools")) {
        $Src = Join-Path $SourceClaude $Item
        $Dest = Join-Path $ClaudeDir $Item
        if (Test-Path $Src) {
            try {
                if (Test-Path $Dest) { Remove-Item $Dest -Recurse -Force -ErrorAction SilentlyContinue }
                Copy-Item -Recurse -Force $Src $Dest
                Print-Success "Copied $Item"
            } catch {
                Print-Warning "Failed to copy $Item to ~/.claude. This is usually okay for Gemini CLI."
            }
        }
    }
    
    # Handle settings.json
    $SrcSettings = Join-Path $SourceClaude "settings.json"
    $DestSettings = Join-Path $ClaudeDir "settings.json"
    
    if (Test-Path $SrcSettings) {
        $JsonContent = Get-Content $SrcSettings -Raw
        # Replace __HOME__
        $JsonContent = $JsonContent.Replace("__HOME__", $Env:USERPROFILE.Replace("\", "\\"))
        Set-Content -Path $DestSettings -Value $JsonContent
        Print-Success "Configured settings.json"
    }
}

Print-Header "Setup Complete!"
Print-Success "PAI is ready."
Print-Info "Restart your terminal to load environment variables."
