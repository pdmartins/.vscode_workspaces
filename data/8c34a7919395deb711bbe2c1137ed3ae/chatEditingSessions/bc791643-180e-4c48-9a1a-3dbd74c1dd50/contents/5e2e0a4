# ============================================================================
# Script: clone-devops-repos.ps1
# Description: Clone all repositories from an Azure DevOps project
# ============================================================================

param(
    [string]$OrganizationUrl,
    [string]$Project,
    [string]$Username,
    [string]$Pat,
    [string]$ClonePath,
    [string]$ConfigFile
)

# ============================================================================
# Helper Functions
# ============================================================================

function Write-Step {
    param([string]$Message)
    Write-Host "🚀 $Message" -ForegroundColor White
}

function Write-Info {
    param([string]$Message)
    Write-Host "🔍 $Message" -ForegroundColor Cyan
}

function Write-Success {
    param([string]$Message)
    Write-Host "✅ $Message" -ForegroundColor Green
}

function Write-Warning {
    param([string]$Message)
    Write-Host "⚠️ $Message" -ForegroundColor Yellow
}

function Write-Error {
    param([string]$Message)
    Write-Host "❌ $Message" -ForegroundColor Red
}

function Write-Install {
    param([string]$Message)
    Write-Host "📦 $Message" -ForegroundColor Yellow
}

function Write-Update {
    param([string]$Message)
    Write-Host "🔄 $Message" -ForegroundColor Cyan
}

# Script directory
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$DefaultConfigFile = Join-Path $ScriptDir "devops-config.json"

# Tracking arrays
$script:ReposCloned = @()
$script:ReposUpdated = @()
$script:ReposStashed = @()
$script:ReposFailed = @()

# ============================================================================
# Functions
# ============================================================================

function Show-Usage {
    Write-Host "Usage: .\clone-devops-repos.ps1 [options]"
    Write-Host ""
    Write-Host "Options:"
    Write-Host "  -OrganizationUrl URL     Azure DevOps organization URL"
    Write-Host "  -Project NAME            Project name"
    Write-Host "  -Username USER           Username"
    Write-Host "  -Pat TOKEN               Personal Access Token"
    Write-Host "  -ClonePath PATH          Destination folder (default: .\repos)"
    Write-Host "  -ConfigFile FILE         JSON configuration file"
    Write-Host ""
    Write-Host "Config file example (devops-config.json):"
    Write-Host '{'
    Write-Host '  "organization_url": "https://dev.azure.com/your-org",'
    Write-Host '  "project": "project-name",'
    Write-Host '  "username": "your-username",'
    Write-Host '  "pat": "your-personal-access-token",'
    Write-Host '  "clone_path": "./repos"'
    Write-Host '}'
}

function Import-ConfigFile {
    param([string]$Path)
    
    if (-not (Test-Path $Path)) {
        return $false
    }
    
    Write-Info "Loading configuration from: $Path"
    
    try {
        $config = Get-Content $Path -Raw | ConvertFrom-Json
        
        if ($config.organization_url) { $script:OrganizationUrl = $config.organization_url }
        if ($config.project) { $script:Project = $config.project }
        if ($config.username) { $script:Username = $config.username }
        if ($config.pat) { $script:Pat = $config.pat }
        if ($config.clone_path) { $script:ClonePath = $config.clone_path }
        
        Write-Success "Configuration loaded"
        return $true
    }
    catch {
        Write-Error "Error reading configuration: $_"
        return $false
    }
}

function Test-Prerequisites {
    Write-Info "Checking prerequisites..."
    
    if (-not (Get-Command "git" -ErrorAction SilentlyContinue)) {
        Write-Error "Git not found. Install Git first."
        exit 1
    }
    
    Write-Success "Prerequisites OK"
}

function Test-Configuration {
    $valid = $true
    
    if ([string]::IsNullOrEmpty($OrganizationUrl)) {
        Write-Error "Organization URL not provided"
        $valid = $false
    }
    
    if ([string]::IsNullOrEmpty($Project)) {
        Write-Error "Project name not provided"
        $valid = $false
    }
    
    if ([string]::IsNullOrEmpty($Username)) {
        Write-Error "Username not provided"
        $valid = $false
    }
    
    if ([string]::IsNullOrEmpty($Pat)) {
        Write-Error "PAT (Personal Access Token) not provided"
        $valid = $false
    }
    
    if (-not $valid) {
        Write-Host ""
        Show-Usage
        exit 1
    }
    
    # Default value for ClonePath
    if ([string]::IsNullOrEmpty($script:ClonePath)) {
        $script:ClonePath = ".\repos"
    }
}

function Get-Repositories {
    Write-Info "Fetching repositories from project: $Project"
    
    # Remove trailing slash from URL
    $orgUrl = $OrganizationUrl.TrimEnd('/')
    
    # Encode credentials in base64
    $auth = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("${Username}:${Pat}"))
    
    # API URL
    $apiUrl = "${orgUrl}/${Project}/_apis/git/repositories?api-version=7.0"
    
    try {
        $headers = @{
            "Authorization" = "Basic $auth"
        }
        
        $response = Invoke-RestMethod -Uri $apiUrl -Headers $headers -Method Get
        
        return $response.value
    }
    catch {
        Write-Error "Error fetching repositories: $_"
        exit 1
    }
}

function Copy-Repository {
    param(
        [string]$RepoName,
        [string]$RepoUrl
    )
    
    $targetDir = Join-Path $ClonePath $RepoName
    $hadStash = $false
    
    # Build URL with authentication
    $authUrl = $RepoUrl -replace "https://", "https://${Username}:${Pat}@"
    
    if (Test-Path (Join-Path $targetDir ".git")) {
        Write-Update "Updating: $RepoName"
        
        try {
            Push-Location $targetDir
            
            # Check for local changes
            $diffOutput = git diff --quiet 2>&1
            $diffCachedOutput = git diff --cached --quiet 2>&1
            $hasChanges = ($LASTEXITCODE -ne 0)
            
            if ($hasChanges) {
                Write-Warning "  Local changes detected, stashing..."
                $stashResult = git stash push -m "auto-stash before pull $(Get-Date -Format 'yyyyMMdd-HHmmss')" --quiet 2>&1
                if ($LASTEXITCODE -eq 0) {
                    $hadStash = $true
                    $script:ReposStashed += $RepoName
                }
                else {
                    Write-Error "  Failed to stash"
                    $script:ReposFailed += "$RepoName (stash failed)"
                    Pop-Location
                    return $false
                }
            }
            
            # Pull
            git pull --quiet 2>&1 | Out-Null
            if ($LASTEXITCODE -eq 0) {
                $script:ReposUpdated += $RepoName
                if ($hadStash) {
                    Write-Info "  Restoring stash..."
                    git stash pop --quiet 2>&1 | Out-Null
                    if ($LASTEXITCODE -ne 0) {
                        Write-Warning "  ⚠️ Conflict restoring stash. Use 'git stash pop' manually."
                    }
                }
                Write-Success "OK: $RepoName"
            }
            else {
                Write-Error "  Pull failed"
                $script:ReposFailed += "$RepoName (pull failed)"
                if ($hadStash) {
                    git stash pop --quiet 2>&1 | Out-Null
                }
                Pop-Location
                return $false
            }
            
            Pop-Location
        }
        catch {
            Write-Warning "Failed to update $RepoName"
            $script:ReposFailed += "$RepoName (error: $_)"
            Pop-Location
            return $false
        }
    }
    else {
        Write-Install "Cloning: $RepoName"
        try {
            git clone --quiet $authUrl $targetDir 2>&1 | Out-Null
            if ($LASTEXITCODE -eq 0) {
                $script:ReposCloned += $RepoName
                Write-Success "OK: $RepoName"
            }
            else {
                Write-Error "Failed to clone: $RepoName"
                $script:ReposFailed += "$RepoName (clone failed)"
                return $false
            }
        }
        catch {
            Write-Warning "Failed to clone $RepoName"
            $script:ReposFailed += "$RepoName (clone failed)"
            return $false
        }
    }
    
    return $true
}

function Write-Summary {
    Write-Host ""
    Write-Host "============================================================"
    Write-Step "EXECUTION SUMMARY"
    Write-Host "============================================================"
    Write-Host ""
    
    # Cloned
    if ($script:ReposCloned.Count -gt 0) {
        Write-Install "Cloned repositories ($($script:ReposCloned.Count)):"
        foreach ($repo in $script:ReposCloned) {
            Write-Host "    • $repo"
        }
        Write-Host ""
    }
    
    # Updated
    if ($script:ReposUpdated.Count -gt 0) {
        Write-Update "Updated repositories ($($script:ReposUpdated.Count)):"
        foreach ($repo in $script:ReposUpdated) {
            Write-Host "    • $repo"
        }
        Write-Host ""
    }
    
    # Stashed
    if ($script:ReposStashed.Count -gt 0) {
        Write-Warning "Repositories with stash applied ($($script:ReposStashed.Count)):"
        foreach ($repo in $script:ReposStashed) {
            Write-Host "    • $repo"
        }
        Write-Host ""
    }
    
    # Failed
    if ($script:ReposFailed.Count -gt 0) {
        Write-Error "Failed repositories ($($script:ReposFailed.Count)):"
        foreach ($repo in $script:ReposFailed) {
            Write-Host "    • $repo"
        }
        Write-Host ""
    }
    
    # Totals
    Write-Host "------------------------------------------------------------"
    $total = $script:ReposCloned.Count + $script:ReposUpdated.Count + $script:ReposFailed.Count
    $success = $script:ReposCloned.Count + $script:ReposUpdated.Count
    Write-Host "📊 TOTAL: $success of $total repositories processed successfully" -ForegroundColor White
    Write-Host "   📦 Cloned:    $($script:ReposCloned.Count)"
    Write-Host "   🔄 Updated:   $($script:ReposUpdated.Count)"
    Write-Host "   📂 Stashed:   $($script:ReposStashed.Count)"
    Write-Host "   ❌ Failed:    $($script:ReposFailed.Count)"
    Write-Host "------------------------------------------------------------"
    Write-Info "Location: $ClonePath"
}

# ============================================================================
# Main
# ============================================================================

function Main {
    Write-Step "Azure DevOps Repository Clone"
    Write-Host ""
    
    # Try to load config if parameters were not provided
    if ([string]::IsNullOrEmpty($OrganizationUrl)) {
        if (-not [string]::IsNullOrEmpty($ConfigFile)) {
            Import-ConfigFile -Path $ConfigFile | Out-Null
        }
        elseif (Test-Path $DefaultConfigFile) {
            Import-ConfigFile -Path $DefaultConfigFile | Out-Null
        }
    }
    
    Test-Prerequisites
    Test-Configuration
    
    # Create destination folder
    if (-not (Test-Path $ClonePath)) {
        Write-Info "Creating folder: $ClonePath"
        New-Item -ItemType Directory -Path $ClonePath -Force | Out-Null
    }
    
    # Fetch repositories
    $repos = Get-Repositories
    
    if ($repos.Count -eq 0) {
        Write-Warning "No repositories found in project"
        exit 0
    }
    
    foreach ($repo in $repos) {
        Copy-Repository -RepoName $repo.name -RepoUrl $repo.remoteUrl | Out-Null
    }
    
    Write-Summary
}

Main
