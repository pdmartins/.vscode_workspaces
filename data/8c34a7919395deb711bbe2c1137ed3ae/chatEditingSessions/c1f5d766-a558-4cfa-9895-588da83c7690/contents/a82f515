# ============================================================================
# Script: export-git-repos.ps1
# Description: Searches for Git repos in a folder, identifies remote/branch
#              and generates a script to clone the structure on another computer
# ============================================================================

param(
    [string]$Path,
    [string]$Output,
    [switch]$Help
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

function Write-Warn {
    param([string]$Message)
    Write-Host "⚠️ $Message" -ForegroundColor Yellow
}

function Write-Err {
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

# Tracking arrays
$script:ReposFound = @()
$script:ReposNoRemote = @()

# ============================================================================
# Functions
# ============================================================================

function Show-Usage {
    Write-Host "Usage: .\export-git-repos.ps1 [options]"
    Write-Host ""
    Write-Host "Options:"
    Write-Host "  -Path PATH       Root folder to search for repos (default: current directory)"
    Write-Host "  -Output FILE     Output file for the script (default: clone-repos.ps1)"
    Write-Host "  -Help            Show this help"
    Write-Host ""
    Write-Host "Examples:"
    Write-Host "  .\export-git-repos.ps1 -Path C:\Projects"
    Write-Host "  .\export-git-repos.ps1 -Path D:\Repos -Output my-repos.ps1"
}

function Test-Prerequisites {
    Write-Info "Checking prerequisites..."
    
    if (-not (Get-Command "git" -ErrorAction SilentlyContinue)) {
        Write-Err "Git not found. Please install Git first."
        exit 1
    }
    
    Write-Success "Prerequisites OK"
}

function Get-SearchPath {
    param([string]$InputPath)
    
    if ([string]::IsNullOrWhiteSpace($InputPath)) {
        $InputPath = Read-Host "📁 Root folder to search for repos [$(Get-Location)]"
        if ([string]::IsNullOrWhiteSpace($InputPath)) {
            $InputPath = (Get-Location).Path
        }
    }
    
    # Resolve absolute path
    try {
        $resolvedPath = (Resolve-Path -Path $InputPath -ErrorAction Stop).Path
    }
    catch {
        Write-Err "Folder not found: $InputPath"
        exit 1
    }
    
    if (-not (Test-Path $resolvedPath -PathType Container)) {
        Write-Err "Folder not found: $InputPath"
        exit 1
    }
    
    Write-Info "Search folder: $resolvedPath"
    return $resolvedPath
}

function Get-OutputFile {
    param([string]$InputFile)
    
    if ([string]::IsNullOrWhiteSpace($InputFile)) {
        $InputFile = Read-Host "📄 Output file name [clone-repos.ps1]"
        if ([string]::IsNullOrWhiteSpace($InputFile)) {
            $InputFile = "clone-repos.ps1"
        }
    }
    
    # Ensure .ps1 extension
    if (-not $InputFile.EndsWith(".ps1")) {
        $InputFile = "$InputFile.ps1"
    }
    
    Write-Info "Output file: $InputFile"
    return $InputFile
}

function Get-RepoInfo {
    param([string]$RepoPath)
    
    $originalLocation = Get-Location
    Set-Location $RepoPath
    
    try {
        $remoteUrl = git remote get-url origin 2>$null
        $currentBranch = git branch --show-current 2>$null
        
        if ([string]::IsNullOrWhiteSpace($currentBranch)) {
            $currentBranch = git rev-parse --abbrev-ref HEAD 2>$null
            if ([string]::IsNullOrWhiteSpace($currentBranch)) {
                $currentBranch = "main"
            }
        }
    }
    catch {
        $remoteUrl = ""
        $currentBranch = "main"
    }
    
    Set-Location $originalLocation
    
    return @{
        RemoteUrl = $remoteUrl
        Branch = $currentBranch
    }
}

function Find-AllRepos {
    param([string]$SearchPath)
    
    Write-Step "Searching for Git repositories recursively..."
    Write-Host ""
    
    # Search all .git directories recursively
    $gitDirs = Get-ChildItem -Path $SearchPath -Directory -Recurse -Filter ".git" -Force -ErrorAction SilentlyContinue
    
    $total = $gitDirs.Count
    Write-Info "Found $total Git repositories"
    Write-Host ""
    
    $current = 0
    foreach ($gitDir in $gitDirs) {
        $current++
        $repoPath = $gitDir.Parent.FullName
        
        # Path relative to search folder
        $relativePath = $repoPath.Substring($SearchPath.Length).TrimStart('\', '/')
        
        # Get repo info
        $repoInfo = Get-RepoInfo -RepoPath $repoPath
        
        Write-Host "[$current/$total] " -ForegroundColor Cyan -NoNewline
        Write-Host $relativePath
        
        if ([string]::IsNullOrWhiteSpace($repoInfo.RemoteUrl)) {
            Write-Warn "  └── No remote origin (skipped)"
            $script:ReposNoRemote += $relativePath
        }
        else {
            Write-Host "  ├── Remote: $($repoInfo.RemoteUrl)"
            Write-Host "  └── Branch: $($repoInfo.Branch)"
            $script:ReposFound += @{
                RelativePath = $relativePath
                RemoteUrl = $repoInfo.RemoteUrl
                Branch = $repoInfo.Branch
            }
        }
    }
}

function New-CloneScript {
    param([string]$OutputFile, [string]$SearchPath)
    
    Write-Host ""
    Write-Step "Generating clone script..."
    
    # Generated script header
    $scriptContent = @'
# ============================================================================
# Script: clone-repos.ps1 (auto-generated)
# Description: Clones Git repositories preserving original folder structure
# ============================================================================

param(
    [string]$BaseDir = (Get-Location).Path
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

function Write-Warn {
    param([string]$Message)
    Write-Host "⚠️ $Message" -ForegroundColor Yellow
}

function Write-Err {
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

# Tracking
$script:ReposCloned = @()
$script:ReposSkipped = @()
$script:ReposFailed = @()

# ============================================================================
# Functions
# ============================================================================

function Invoke-CloneRepo {
    param(
        [string]$RelativePath,
        [string]$RemoteUrl,
        [string]$Branch
    )
    
    $targetDir = Join-Path $BaseDir $RelativePath
    
    if (Test-Path (Join-Path $targetDir ".git")) {
        Write-Warn "Repo already exists: $RelativePath"
        $script:ReposSkipped += $RelativePath
        return
    }
    
    Write-Install "Cloning: $RelativePath"
    Write-Host "  ├── URL: $RemoteUrl"
    Write-Host "  └── Branch: $Branch"
    
    # Create parent folder if it doesn't exist
    $parentDir = Split-Path -Parent $targetDir
    if (-not (Test-Path $parentDir)) {
        New-Item -Path $parentDir -ItemType Directory -Force | Out-Null
    }
    
    # Try to clone with specific branch
    $result = git clone --branch $Branch $RemoteUrl $targetDir 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Success "Cloned: $RelativePath"
        $script:ReposCloned += $RelativePath
    }
    else {
        # Try without specific branch
        $result = git clone $RemoteUrl $targetDir 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Warn "Cloned (default branch): $RelativePath"
            $script:ReposCloned += $RelativePath
        }
        else {
            Write-Err "Failed to clone: $RelativePath"
            $script:ReposFailed += $RelativePath
        }
    }
}

function Show-Summary {
    Write-Host ""
    Write-Host "============================================================================"
    Write-Host " Summary"
    Write-Host "============================================================================"
    
    if ($script:ReposCloned.Count -gt 0) {
        Write-Success "Cloned: $($script:ReposCloned.Count)"
    }
    
    if ($script:ReposSkipped.Count -gt 0) {
        Write-Warn "Already existing: $($script:ReposSkipped.Count)"
    }
    
    if ($script:ReposFailed.Count -gt 0) {
        Write-Err "Failed: $($script:ReposFailed.Count)"
        foreach ($repo in $script:ReposFailed) {
            Write-Host "  - $repo"
        }
    }
}

# ============================================================================
# Main
# ============================================================================

function Main {
    Write-Step "Cloning repositories to: $BaseDir"
    Write-Host ""

'@

    # Add metadata
    $scriptContent += "`n# Generated on: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')`n"
    $scriptContent += "# Original folder: $SearchPath`n"
    $scriptContent += "# Total repositories: $($script:ReposFound.Count)`n`n"
    
    # Add clone calls for each repo
    foreach ($repo in $script:ReposFound) {
        $scriptContent += "    Invoke-CloneRepo -RelativePath `"$($repo.RelativePath)`" -RemoteUrl `"$($repo.RemoteUrl)`" -Branch `"$($repo.Branch)`"`n"
    }
    
    # Script footer
    $scriptContent += @'

    Show-Summary
}

Main
'@

    # Save file
    $scriptContent | Out-File -FilePath $OutputFile -Encoding utf8
}

function Show-Summary {
    Write-Host ""
    Write-Host "============================================================================"
    Write-Host " Summary"
    Write-Host "============================================================================"
    
    Write-Success "Repositories found: $($script:ReposFound.Count)"
    
    if ($script:ReposNoRemote.Count -gt 0) {
        Write-Warn "No remote (skipped): $($script:ReposNoRemote.Count)"
        foreach ($repo in $script:ReposNoRemote) {
            Write-Host "  - $repo"
        }
    }
    
    Write-Host ""
    Write-Success "Script generated: $script:OutputFile"
    Write-Host ""
    Write-Info "To use on another computer:"
    Write-Host "    1. Copy the file '$script:OutputFile' to the destination"
    Write-Host "    2. Run: .\$script:OutputFile -BaseDir [target_folder]"
}

# ============================================================================
# Main
# ============================================================================

function Main {
    Write-Step "Git Repository Exporter"
    Write-Host ""
    
    if ($Help) {
        Show-Usage
        exit 0
    }
    
    Test-Prerequisites
    $script:SearchPath = Get-SearchPath -InputPath $Path
    $script:OutputFile = Get-OutputFile -InputFile $Output
    Write-Host ""
    
    Find-AllRepos -SearchPath $script:SearchPath
    
    if ($script:ReposFound.Count -eq 0) {
        Write-Warn "No repository with remote origin found."
        exit 0
    }
    
    New-CloneScript -OutputFile $script:OutputFile -SearchPath $script:SearchPath
    Show-Summary
}

Main
