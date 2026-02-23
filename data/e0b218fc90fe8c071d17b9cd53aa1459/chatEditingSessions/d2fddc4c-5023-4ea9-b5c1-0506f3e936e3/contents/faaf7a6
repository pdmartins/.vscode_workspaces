# Script to uninstall Docker Engine from Windows (WSL2)
# Author: GitHub Copilot
# Date: 2026-01-30
# Note: This script removes Docker Engine installed via WSL2

# Output colors
$ErrorActionPreference = "Stop"

Write-Host "🐳 Uninstalling Docker Engine from WSL2..." -ForegroundColor Cyan

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
    Write-Host "❌ WSL is not installed. Nothing to do." -ForegroundColor Red
    exit 0
}

Write-Host "✅ WSL is installed" -ForegroundColor Green

# Check if a Linux distribution is installed
Write-Host "🔍 Checking installed Linux distributions..." -ForegroundColor Yellow

$distroList = wsl --list --quiet 2>$null | Where-Object { $_ -and $_.Trim() -ne "" -and $_ -notmatch "docker-desktop" }
# Clean null characters that WSL sometimes returns
$distroList = $distroList | ForEach-Object { $_ -replace "`0", "" } | Where-Object { $_.Trim() -ne "" }

if (-not $distroList -or @($distroList).Count -eq 0) {
    Write-Host "❌ No Linux distribution found. Nothing to do." -ForegroundColor Red
    exit 0
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

# Check if Docker is installed in WSL
Write-Host "🔍 Checking if Docker is installed in WSL ($selectedDistro)..." -ForegroundColor Yellow

$dockerInstalled = wsl -d $selectedDistro -- docker --version 2>$null
if ($LASTEXITCODE -ne 0 -or -not $dockerInstalled) {
    Write-Host "ℹ️  Docker is not installed in this distribution. Nothing to do." -ForegroundColor Cyan
    exit 0
}

Write-Host "✅ Docker found: $dockerInstalled" -ForegroundColor Green

# Confirm uninstallation
Write-Host ""
Write-Host "⚠️  WARNING: This action will remove:" -ForegroundColor Yellow
Write-Host "   • Docker Engine (docker-ce, docker-ce-cli)" -ForegroundColor White
Write-Host "   • Containerd" -ForegroundColor White
Write-Host "   • Docker Buildx and Compose plugins" -ForegroundColor White
Write-Host "   • All Docker images, containers and volumes" -ForegroundColor White
Write-Host "   • Docker configurations" -ForegroundColor White
Write-Host ""

$confirm = Read-Host "❓ Do you want to continue? (y/n)"
if ($confirm -ne "y" -and $confirm -ne "Y") {
    Write-Host "❌ Operation cancelled by user." -ForegroundColor Red
    exit 0
}

Write-Host ""
Write-Host "┌─────────────────────────────────────────────────────────────┐" -ForegroundColor Magenta
Write-Host "│  🐧 Running in WSL - enter sudo password if prompted       │" -ForegroundColor Magenta
Write-Host "└─────────────────────────────────────────────────────────────┘" -ForegroundColor Magenta
Write-Host ""

# Get bash script path (same folder as ps1 script)
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$bashScript = Join-Path $scriptDir "uninstall-docker.sh"

# Check if bash script exists
if (-not (Test-Path $bashScript)) {
    Write-Host "❌ Bash script not found: $bashScript" -ForegroundColor Red
    exit 1
}

# Convert Windows path to WSL
$wslPath = wsl -d $selectedDistro -- wslpath -u ($bashScript -replace '\\', '/')

# Run script in WSL interactively (allows sudo to ask for password)
# Using 'yes |' to auto-confirm since we already confirmed in PowerShell
Write-Host "🚀 Running uninstallation in WSL..." -ForegroundColor Cyan
Write-Host ""

# Direct execution - allows interaction with sudo
wsl -d $selectedDistro -- bash -c "yes | bash '$wslPath'"
$exitCode = $LASTEXITCODE

Write-Host ""

if ($exitCode -eq 0) {
    Write-Host ""
    Write-Host "✅ Docker Engine uninstalled successfully from WSL!" -ForegroundColor Green
    Write-Host ""
    Write-Host "📋 What was removed:" -ForegroundColor Cyan
    Write-Host "   • Docker Engine and all components" -ForegroundColor White
    Write-Host "   • All images, containers and volumes" -ForegroundColor White
    Write-Host "   • Configurations and GPG keys" -ForegroundColor White
    Write-Host ""
    Write-Host "💡 To reinstall, run: .\install-docker.ps1" -ForegroundColor Yellow
} else {
    Write-Host "❌ Error during Docker uninstallation" -ForegroundColor Red
    exit 1
}
