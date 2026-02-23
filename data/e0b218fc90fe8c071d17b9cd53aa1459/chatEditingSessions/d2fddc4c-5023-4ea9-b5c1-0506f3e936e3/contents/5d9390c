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

$distros = wsl --list --quiet 2>$null | Where-Object { $_ -and $_.Trim() -ne "" }

if (-not $distros -or $distros.Count -eq 0) {
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
} else {
    Write-Host "✅ Linux distribution found: $($distros[0])" -ForegroundColor Green
}

# Check if Docker is already installed in WSL
Write-Host "🔍 Checking if Docker is already installed in WSL..." -ForegroundColor Yellow

$dockerInstalled = wsl docker --version 2>$null
if ($LASTEXITCODE -eq 0 -and $dockerInstalled) {
    Write-Host "✅ Docker is already installed in WSL: $dockerInstalled" -ForegroundColor Green
    
    # Check if the service is running
    $dockerRunning = wsl docker info 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Docker is running!" -ForegroundColor Green
    } else {
        Write-Host "⚠️  Docker is installed but not running." -ForegroundColor Yellow
        Write-Host "🔄 Starting Docker service..." -ForegroundColor Yellow
        wsl sudo service docker start
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ Docker service started successfully!" -ForegroundColor Green
        } else {
            Write-Host "❌ Error starting Docker service" -ForegroundColor Red
        }
    }
    exit 0
}

# Install Docker in WSL
Write-Host "📦 Installing Docker Engine in WSL..." -ForegroundColor Yellow

# Docker installation script to run in WSL
$dockerInstallScript = @'
#!/bin/bash
set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}🐳 Installing Docker Engine...${NC}"

# Remove old versions if they exist
echo -e "${YELLOW}🧹 Removing old Docker versions (if any)...${NC}"
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do
    sudo apt-get remove -y $pkg 2>/dev/null || true
done

# Update packages
echo -e "${YELLOW}📦 Updating package list...${NC}"
sudo apt-get update

# Install dependencies
echo -e "${YELLOW}📦 Installing dependencies...${NC}"
sudo apt-get install -y ca-certificates curl gnupg

# Add Docker's official GPG key
echo -e "${YELLOW}🔑 Adding Docker GPG key...${NC}"
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg --yes
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Add Docker repository
echo -e "${YELLOW}📋 Adding Docker repository...${NC}"
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Update and install Docker
echo -e "${YELLOW}📦 Installing Docker Engine...${NC}"
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Add user to docker group
echo -e "${YELLOW}👤 Adding user to docker group...${NC}"
sudo usermod -aG docker $USER

# Start Docker service
echo -e "${YELLOW}🚀 Starting Docker service...${NC}"
sudo service docker start

# Verify installation
echo -e "${YELLOW}🔍 Verifying installation...${NC}"
sudo docker run --rm hello-world

echo -e "${GREEN}✅ Docker Engine installed successfully!${NC}"
echo -e "${CYAN}💡 To use docker without sudo, logout and login again or run: newgrp docker${NC}"
'@

# Save temporary script and run in WSL
$tempScript = [System.IO.Path]::GetTempFileName() -replace '\.tmp$', '.sh'
$dockerInstallScript | Out-File -FilePath $tempScript -Encoding utf8 -NoNewline

# Convert Windows path to WSL
$wslPath = wsl wslpath -u ($tempScript -replace '\\', '/')

# Run script in WSL
Write-Host "🚀 Running installation in WSL..." -ForegroundColor Cyan
wsl bash $wslPath

if ($LASTEXITCODE -eq 0) {
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
} else {
    Write-Host "❌ Error during Docker installation" -ForegroundColor Red
    exit 1
}

# Clean up temporary file
Remove-Item -Path $tempScript -Force -ErrorAction SilentlyContinue
