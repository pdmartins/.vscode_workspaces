# ============================================================================
# Script: export-git-repos.ps1
# Description: Searches for Git repos in a folder, identifies remote/branch
#              and generates a script to clone the structure on another computer
# ============================================================================

param(
    [string]$Path,
    [string]$Output
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

# Script directory
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# ============================================================================
# Functions
# ============================================================================

function Show-Help {
    @"
Usage: .\export-git-repos.ps1 [OPTIONS]

Searches for Git repositories in a folder and generates a script to clone the structure.

OPTIONS:
    -Path PATH       Root folder to search for repos (default: current directory)
    -Output FILE     Output file for the script (default: clone-repos.ps1)

EXAMPLES:
    .\export-git-repos.ps1 -Path C:\Projects
    .\export-git-repos.ps1 -Path D:\Repos -Output my-repos.ps1

"@
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
    $resolvedPath = Resolve-Path -Path $InputPath -ErrorAction SilentlyContinue
    
    if (-not $resolvedPath -or -not (Test-Path $resolvedPath)) {
        Write-Err "Folder not found: $InputPath"
        exit 1
    }
    
    return $resolvedPath.Path
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
    
    return $InputFile
}

function Find-GitRepos {
    param([string]$SearchPath)
    
    Write-Info "Searching for Git repositories in: $SearchPath"
    
    $gitFolders = Get-ChildItem -Path $SearchPath -Directory -Recurse -Filter ".git" -ErrorAction SilentlyContinue -Force
    
    $repos = @()
    foreach ($gitFolder in $gitFolders) {
        $repos += $gitFolder.Parent.FullName
    }
    
    return $repos
}

function Get-RepoInfo {
    param([string]$RepoPath)
    
    Push-Location $RepoPath
    
    try {
        $remoteUrl = git remote get-url origin 2>$null
        $currentBranch = git branch --show-current 2>$null
        
        if ([string]::IsNullOrWhiteSpace($currentBranch)) {
            $currentBranch = "main"
        }
    }
    catch {
        $remoteUrl = ""
        $currentBranch = "main"
    }
    
    Pop-Location
    
    return @{
        RemoteUrl = $remoteUrl
        Branch = $currentBranch
    }
}

function New-CloneScript {
    param(
        [string]$SearchPath,
        [string]$OutputFile
    )
    
    Write-Step "Generating clone script..."
    
    $repoCount = 0
    
    # Script header
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

# ============================================================================
# Clone Function
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
        return
    }
    
    Write-Info "Cloning: $RelativePath"
    Write-Info "  URL: $RemoteUrl"
    Write-Info "  Branch: $Branch"
    
    $parentDir = Split-Path -Parent $targetDir
    if (-not (Test-Path $parentDir)) {
        New-Item -Path $parentDir -ItemType Directory -Force | Out-Null
    }
    
    try {
        git clone --branch $Branch $RemoteUrl $targetDir 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-Success "Cloned: $RelativePath"
        } else {
            throw "Clone failed"
        }
    }
    catch {
        # Try without specific branch
        try {
            git clone $RemoteUrl $targetDir 2>$null
            Write-Warn "Cloned (default branch): $RelativePath"
        }
        catch {
            Write-Err "Failed to clone: $RelativePath"
        }
    }
}

Write-Step "Cloning repositories to: $BaseDir"

# ============================================================================
# Repositories
# ============================================================================

'@

    # Add metadata
    $scriptContent += "`n# Generated on: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')`n"
    $scriptContent += "# Original folder: $SearchPath`n`n"
    
    # Process each repository
    $repos = Find-GitRepos -SearchPath $SearchPath
    
    foreach ($repoPath in $repos) {
        $repoInfo = Get-RepoInfo -RepoPath $repoPath
        
        # Path relative to search folder
        $relativePath = $repoPath.Substring($SearchPath.Length).TrimStart('\', '/')
        
        if ([string]::IsNullOrWhiteSpace($repoInfo.RemoteUrl)) {
            Write-Warn "Repo without remote origin: $relativePath"
            $scriptContent += "# WARNING: Local repo without remote - $relativePath`n"
            continue
        }
        
        $scriptContent += "Invoke-CloneRepo -RelativePath `"$relativePath`" -RemoteUrl `"$($repoInfo.RemoteUrl)`" -Branch `"$($repoInfo.Branch)`"`n"
        $repoCount++
        
        Write-Info "Found: $relativePath"
        Write-Host "           Branch: $($repoInfo.Branch)"
    }
    
    # Script footer
    $scriptContent += @'

# ============================================================================
# Summary
# ============================================================================

Write-Success "Clone process completed!"
'@

    # Save file
    $scriptContent | Out-File -FilePath $OutputFile -Encoding utf8
    
    return $repoCount
}

# ============================================================================
# Main
# ============================================================================

function Main {
    Write-Step "Git Repository Exporter"
    Write-Host ""
    
    $searchPath = Get-SearchPath -InputPath $Path
    $outputFile = Get-OutputFile -InputFile $Output
    
    Write-Host ""
    
    $count = New-CloneScript -SearchPath $searchPath -OutputFile $outputFile
    
    Write-Host ""
    Write-Success "Script generated: $outputFile"
    Write-Success "Total repositories: $count"
    Write-Host ""
    Write-Info "To use on another computer:"
    Write-Host "    1. Copy the file '$outputFile' to the destination"
    Write-Host "    2. Run: .\$outputFile -BaseDir [target_folder]"
}

Main
