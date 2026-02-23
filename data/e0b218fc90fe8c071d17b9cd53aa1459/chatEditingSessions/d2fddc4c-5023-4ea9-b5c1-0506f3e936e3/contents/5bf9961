# Script to install Docker Engine on Windows (WSL2)
# Author: GitHub Copilot
# Date: 2026-01-30
# Note: This script installs Docker Engine via WSL2, not Docker Desktop

# Output colors
$ErrorActionPreference = "Stop"

Write-Host "🐳 Installing Docker Engine via WSL2..." -ForegroundColor Cyan

# Function to check if running as administrator
function Test-Administrator {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# Check administrator privileges
if (-not (Test-Administrator)) {
    Write-Host "❌ This script needs to be run as Administrator!" -ForegroundColor Red
    Write-Host "💡 Right-click on PowerShell and select 'Run as administrator'" -ForegroundColor Yellow
    exit 1
}

# Check if WSL is installed
Write-Host "🔍 Checking WSL installation..." -ForegroundColor Yellow

$wslInstalled = $false
try {
    $wslVersion = wsl --version 2>$null
    if ($LASTEXITCODE -eq 0) {
        $wslInstalled = $true
    }
} catch {
    $wslInstalled = $false
}

if (-not $wslInstalled) {
    Write-Host "📦 WSL is not installed. Installing WSL2..." -ForegroundColor Yellow
    
    try {
        wsl --install --no-distribution
        Write-Host "✅ WSL2 installed successfully!" -ForegroundColor Green
        Write-Host "⚠️  A computer restart is required to continue." -ForegroundColor Yellow
        Write-Host "💡 After restarting, run this script again." -ForegroundColor Cyan
        
        $restart = Read-Host "Do you want to restart now? (y/n)"
        if ($restart -eq "y" -or $restart -eq "Y") {
            Restart-Computer -Force
        }
        exit 0
    } catch {
        Write-Host "❌ Error installing WSL: $_" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "✅ WSL is already installed" -ForegroundColor Green
}

# Check if a Linux distribution is installed
Write-Host "🔍 Checking installed Linux distributions..." -ForegroundColor Yellow

$distroList = wsl --list --quiet 2>$null | Where-Object { $_ -and $_.Trim() -ne "" -and $_ -notmatch "docker-desktop" }
# Clean null characters that WSL sometimes returns
$distroList = $distroList | ForEach-Object { $_ -replace "`0", "" } | Where-Object { $_.Trim() -ne "" }

if (-not $distroList -or @($distroList).Count -eq 0) {
    Write-Host "📦 No Linux distribution found. Installing Ubuntu..." -ForegroundColor Yellow
    
    try {
        wsl --install -d Ubuntu
        Write-Host "✅ Ubuntu installed successfully!" -ForegroundColor Green
        Write-Host "⚠️  Configure your username and password in the Ubuntu window that will open." -ForegroundColor Yellow
        Write-Host "💡 After configuring, run this script again to install Docker." -ForegroundColor Cyan
        exit 0
    } catch {
        Write-Host "❌ Error installing Ubuntu: $_" -ForegroundColor Red
        exit 1
    }
}

# Convert to array if needed
$distroList = @($distroList)

# Select distro
if ($distroList.Count -eq 1) {
    $selectedDistro = $distroList[0].Trim()
    Write-Host "✅ Linux distribution found: $selectedDistro" -ForegroundColor Green
} else {
    Write-Host "📋 Multiple Linux distributions found:" -ForegroundColor Cyan
    for ($i = 0; $i -lt $distroList.Count; $i++) {
        Write-Host "   [$($i + 1)] $($distroList[$i].Trim())" -ForegroundColor White
    }
    Write-Host ""
    
    do {
        $selection = Read-Host "🐧 Choose the distribution (1-$($distroList.Count))"
        $selectionIndex = [int]$selection - 1
    } while ($selectionIndex -lt 0 -or $selectionIndex -ge $distroList.Count)
    
    $selectedDistro = $distroList[$selectionIndex].Trim()
    Write-Host "✅ Distribution selected: $selectedDistro" -ForegroundColor Green
}

# Check if Docker is already installed in WSL
Write-Host "🔍 Checking if Docker is already installed in WSL ($selectedDistro)..." -ForegroundColor Yellow

$dockerInstalled = wsl -d $selectedDistro -- docker --version 2>$null
if ($LASTEXITCODE -eq 0 -and $dockerInstalled) {
    Write-Host "✅ Docker is already installed in WSL: $dockerInstalled" -ForegroundColor Green
    
    # Check if the service is running
    $dockerRunning = wsl -d $selectedDistro -- docker info 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Docker is running!" -ForegroundColor Green
    } else {
        Write-Host "⚠️  Docker is installed but not running." -ForegroundColor Yellow
        Write-Host "🔄 Starting Docker service..." -ForegroundColor Yellow
        wsl -d $selectedDistro -- sudo service docker start
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ Docker service started successfully!" -ForegroundColor Green
        } else {
            Write-Host "❌ Error starting Docker service" -ForegroundColor Red
        }
    }
    exit 0
}

# Install Docker in WSL
Write-Host "📦 Installing Docker Engine in WSL ($selectedDistro)..." -ForegroundColor Yellow
Write-Host ""
Write-Host "┌─────────────────────────────────────────────────────────────┐" -ForegroundColor Magenta
Write-Host "│  🐧 Running in WSL - enter sudo password if prompted       │" -ForegroundColor Magenta
Write-Host "└─────────────────────────────────────────────────────────────┘" -ForegroundColor Magenta
Write-Host ""

# Get bash script path (same folder as ps1 script)
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$bashScript = Join-Path $scriptDir "install-docker.sh"

# Check if bash script exists
if (-not (Test-Path $bashScript)) {
    Write-Host "❌ Bash script not found: $bashScript" -ForegroundColor Red
    exit 1
}

# Convert Windows path to WSL
$wslPath = wsl -d $selectedDistro -- wslpath -u ($bashScript -replace '\\', '/')

# Run script in WSL interactively (allows sudo to ask for password)
Write-Host "🚀 Running installation in WSL..." -ForegroundColor Cyan
Write-Host ""

# Direct execution - allows interaction with sudo
wsl -d $selectedDistro -- bash $wslPath
$exitCode = $LASTEXITCODE

Write-Host ""

if ($exitCode -eq 0) {
    Write-Host ""
    Write-Host "✅ Docker Engine installed successfully in WSL!" -ForegroundColor Green
    Write-Host ""
    Write-Host "📋 To use Docker:" -ForegroundColor Cyan
    Write-Host "   • Open WSL (type 'wsl' in terminal)" -ForegroundColor White
    Write-Host "   • Use docker commands normally (docker run, docker ps, etc.)" -ForegroundColor White
    Write-Host ""
    Write-Host "💡 Tip: To use 'docker' directly from PowerShell, add to your profile:" -ForegroundColor Yellow
    Write-Host '   function docker { wsl docker $args }' -ForegroundColor Gray
    Write-Host '   function docker-compose { wsl docker compose $args }' -ForegroundColor Gray
    Write-Host ""
    Write-Host "   Or specifying the distro:" -ForegroundColor Yellow
    Write-Host "   function docker { wsl -d $selectedDistro docker `$args }" -ForegroundColor Gray
} else {
    Write-Host "❌ Error during Docker installation" -ForegroundColor Red
    exit 1
}
