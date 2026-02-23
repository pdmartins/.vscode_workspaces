#Requires -Version 5.1
param(
    [Parameter(Position = 0)]
    [ValidateSet("push", "force-push", "pull", "status")]
    [string]$Action = "help"
)

$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoDir = $ScriptDir
$DataDir = Join-Path $RepoDir "data"

# Load .env
$EnvFile = Join-Path $RepoDir ".env"
if (Test-Path $EnvFile) {
    Get-Content $EnvFile | ForEach-Object {
        if ($_ -match '^\s*([^#][^=]+)=(.*)$') {
            $key = $matches[1].Trim()
            $val = $matches[2].Trim()
            if ($val -and -not [Environment]::GetEnvironmentVariable($key)) {
                [Environment]::SetEnvironmentVariable($key, $val, "Process")
            }
        }
    }
}

$GitBranch = if ($env:GIT_BRANCH) { $env:GIT_BRANCH } else { "main" }
$CommitPrefix = if ($env:COMMIT_PREFIX) { $env:COMMIT_PREFIX } else { "chatsync" }
$VscodeEditions = if ($env:VSCODE_EDITIONS) { $env:VSCODE_EDITIONS } else { "stable,insiders" }

# Resolve WSL storage path
function Get-WslStoragePath {
    $distro = if ($env:WSL_DISTRO) { $env:WSL_DISTRO } else { "Ubuntu" }

    if ($env:VSCODE_STORAGE_PATH_WSL) {
        return $env:VSCODE_STORAGE_PATH_WSL
    }

    # Auto-detect WSL user
    $wslUser = $env:WSL_USER
    if (-not $wslUser) {
        try {
            $wslUser = (wsl -d $distro whoami 2>$null).Trim()
        } catch { return $null }
    }
    if (-not $wslUser) { return $null }

    $p = "\\wsl$\$distro\home\$wslUser\.vscode-server\data\User\workspaceStorage"
    if (Test-Path $p) { return $p }
    return $null
}

function Get-WslGlobalStoragePath {
    $distro = if ($env:WSL_DISTRO) { $env:WSL_DISTRO } else { "Ubuntu" }
    $wslUser = $env:WSL_USER
    if (-not $wslUser) {
        try { $wslUser = (wsl -d $distro whoami 2>$null).Trim() } catch { return $null }
    }
    if (-not $wslUser) { return $null }

    $p = "\\wsl$\$distro\home\$wslUser\.vscode-server\data\User\globalStorage\GitHub.copilot-chat"
    if (Test-Path $p) { return $p }
    return $null
}

# Resolve storage paths
function Get-StoragePath {
    param([string]$Edition)
    switch ($Edition) {
        "stable" {
            if ($env:VSCODE_STORAGE_PATH_STABLE) { return $env:VSCODE_STORAGE_PATH_STABLE }
            $p = Join-Path $env:APPDATA "Code\User\workspaceStorage"
            if (Test-Path $p) { return $p }
        }
        "insiders" {
            if ($env:VSCODE_STORAGE_PATH_INSIDERS) { return $env:VSCODE_STORAGE_PATH_INSIDERS }
            $p = Join-Path $env:APPDATA "Code - Insiders\User\workspaceStorage"
            if (Test-Path $p) { return $p }
        }
        "wsl" {
            return Get-WslStoragePath
        }
    }
    return $null
}

function Get-GlobalStoragePath {
    param([string]$Edition)
    switch ($Edition) {
        "wsl" { return Get-WslGlobalStoragePath }
        default {
            $wsPath = Get-StoragePath $Edition
            if (-not $wsPath) { return $null }
            $globalDir = Join-Path (Split-Path $wsPath) "globalStorage\GitHub.copilot-chat"
            if (Test-Path $globalDir) { return $globalDir }
        }
    }
    return $null
}

# Collect active editions
$StoragePaths = @{}
$VscodeEditions -split ',' | ForEach-Object {
    $edition = $_.Trim()
    # SSH edition handled on the remote machine, not Windows
    if ($edition -eq "ssh") { return }
    $path = Get-StoragePath $edition
    if ($path -and (Test-Path $path)) {
        $StoragePaths[$edition] = $path
    }
}

if ($StoragePaths.Count -eq 0) {
    Write-Error "No VS Code storage paths found. Check VSCODE_EDITIONS and storage path settings in .env"
    exit 1
}

Write-Host "Active editions: $($StoragePaths.Keys -join ', ')"

function Get-WorkspaceName {
    param([string]$WsDir)
    $wsJson = Join-Path $WsDir "workspace.json"
    if (Test-Path $wsJson) {
        try {
            $data = Get-Content $wsJson -Raw | ConvertFrom-Json
            $uri = $data.folder
            $decoded = [System.Uri]::UnescapeDataString($uri)
            $path = $decoded -replace '^file:///?', ''
            return Split-Path $path -Leaf
        } catch { return "unknown" }
    }
    return "unknown"
}

function Get-NewestFileTimestamp {
    param([string]$Path)
    if (-not (Test-Path $Path)) { return [datetime]::MinValue }
    $newest = Get-ChildItem $Path -Recurse -File -ErrorAction SilentlyContinue |
        Sort-Object LastWriteTimeUtc -Descending | Select-Object -First 1
    if ($newest) { return $newest.LastWriteTimeUtc }
    return [datetime]::MinValue
}

function Sync-WorkspaceToRepo {
    param([string]$WsId, [string]$WsSrc, [switch]$Force)
    $wsDest = Join-Path $DataDir $WsId

    $copilotDir = Join-Path $WsSrc "GitHub.copilot-chat"
    $workspaceJson = Join-Path $WsSrc "workspace.json"

    if ((Test-Path $copilotDir) -or (Test-Path $workspaceJson)) {
        New-Item -ItemType Directory -Force -Path $wsDest | Out-Null
        if (Test-Path $workspaceJson) { Copy-Item $workspaceJson $wsDest -Force }
        if (Test-Path $copilotDir) {
            $destCopilot = Join-Path $wsDest "GitHub.copilot-chat"

            if ($Force) {
                if (Test-Path $destCopilot) { Remove-Item $destCopilot -Recurse -Force }
                Copy-Item $copilotDir $destCopilot -Recurse -Force
            } else {
                $srcTs = Get-NewestFileTimestamp $copilotDir
                $destTs = Get-NewestFileTimestamp $destCopilot

                if ($srcTs -ge $destTs) {
                    if (Test-Path $destCopilot) { Remove-Item $destCopilot -Recurse -Force }
                    Copy-Item $copilotDir $destCopilot -Recurse -Force
                }
            }
        }
        return $true
    }
    return $false
}

function Do-Push {
    param([switch]$Force)
    New-Item -ItemType Directory -Force -Path $DataDir | Out-Null
    Push-Location $RepoDir
    try {
        $pushed = $false
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $hostname = $env:COMPUTERNAME

        foreach ($edition in $StoragePaths.Keys) {
            $storage = $StoragePaths[$edition]
            $editionLabel = if ($edition -eq "wsl") { "wsl" } else { "" }

            Get-ChildItem $storage -Directory -ErrorAction SilentlyContinue | ForEach-Object {
                $wsId = $_.Name
                $synced = if ($Force) {
                    Sync-WorkspaceToRepo -WsId $wsId -WsSrc $_.FullName -Force
                } else {
                    Sync-WorkspaceToRepo -WsId $wsId -WsSrc $_.FullName
                }
                if (-not $synced) { return }

                git add "data/$wsId/" 2>$null
                $diff = git diff --cached --quiet -- "data/$wsId/" 2>&1
                if ($LASTEXITCODE -ne 0) {
                    $wsName = Get-WorkspaceName (Join-Path $DataDir $wsId)
                    $source = if ($editionLabel) { "$hostname/$editionLabel" } else { $hostname }
                    git commit -m "$CommitPrefix`: $source | $wsName | $timestamp"
                    $pushed = $true
                }
            }

            # Global storage
            $globalPath = Get-GlobalStoragePath $edition
            if ($globalPath) {
                $destGlobal = Join-Path $DataDir "_globalStorage"
                New-Item -ItemType Directory -Force -Path $destGlobal | Out-Null
                Get-ChildItem $globalPath -Recurse -File -ErrorAction SilentlyContinue | ForEach-Object {
                    $rel = $_.FullName.Substring($globalPath.Length)
                    $destFile = Join-Path $destGlobal $rel
                    $destDir2 = Split-Path $destFile
                    New-Item -ItemType Directory -Force -Path $destDir2 | Out-Null
                    if (-not (Test-Path $destFile) -or $_.LastWriteTimeUtc -gt (Get-Item $destFile).LastWriteTimeUtc) {
                        Copy-Item $_.FullName $destFile -Force
                    }
                }
            }
        }

        if (Test-Path (Join-Path $DataDir "_globalStorage")) {
            git add "data/_globalStorage/" 2>$null
            $diff = git diff --cached --quiet -- "data/_globalStorage/" 2>&1
            if ($LASTEXITCODE -ne 0) {
                git commit -m "$CommitPrefix`: $($env:COMPUTERNAME) | globalStorage | $timestamp"
                $pushed = $true
            }
        }

        if ($pushed) {
            git push origin $GitBranch
            Write-Host "Pushed changes successfully."
        } else {
            Write-Host "No changes to sync."
        }
    } finally { Pop-Location }
}

function Sync-FromRepo {
    if (-not (Test-Path $DataDir)) {
        Write-Error "No data directory found. Run 'push' first on the source machine."
        exit 1
    }

    foreach ($edition in $StoragePaths.Keys) {
        $storage = $StoragePaths[$edition]
        Write-Host "Restoring to $edition ($storage)..."

        Get-ChildItem $DataDir -Directory -ErrorAction SilentlyContinue | Where-Object { $_.Name -ne "_globalStorage" } | ForEach-Object {
            $wsId = $_.Name
            $srcDir = $_.FullName
            $destDir = Join-Path $storage $wsId

            New-Item -ItemType Directory -Force -Path $destDir | Out-Null

            $workspaceJson = Join-Path $srcDir "workspace.json"
            if (Test-Path $workspaceJson) { Copy-Item $workspaceJson $destDir -Force }

            $copilotDir = Join-Path $srcDir "GitHub.copilot-chat"
            if (Test-Path $copilotDir) {
                $destCopilot = Join-Path $destDir "GitHub.copilot-chat"
                New-Item -ItemType Directory -Force -Path $destCopilot | Out-Null
                Copy-Item "$copilotDir\*" $destCopilot -Recurse -Force
            }
        }

        # Global storage
        $srcGlobal = Join-Path $DataDir "_globalStorage"
        if (Test-Path $srcGlobal) {
            $globalDest = Get-GlobalStoragePath $edition
            if (-not $globalDest) {
                if ($edition -eq "wsl") {
                    $distro = if ($env:WSL_DISTRO) { $env:WSL_DISTRO } else { "Ubuntu" }
                    $wslUser = $env:WSL_USER
                    if (-not $wslUser) { try { $wslUser = (wsl -d $distro whoami 2>$null).Trim() } catch {} }
                    if ($wslUser) {
                        $globalDest = "\\wsl$\$distro\home\$wslUser\.vscode-server\data\User\globalStorage\GitHub.copilot-chat"
                    }
                } else {
                    $globalDest = Join-Path (Split-Path $storage) "globalStorage\GitHub.copilot-chat"
                }
            }
            if ($globalDest) {
                New-Item -ItemType Directory -Force -Path $globalDest | Out-Null
                Copy-Item "$srcGlobal\*" $globalDest -Recurse -Force
            }
        }
    }
}

function Do-Pull {
    Push-Location $RepoDir
    try {
        $before = git rev-parse HEAD 2>$null
        git pull origin $GitBranch --rebase
        $after = git rev-parse HEAD 2>$null

        if ($before -ne $after) {
            Write-Host "New changes found, applying..."
            Sync-FromRepo
            Write-Host "Pulled and applied changes successfully."
        } else {
            Write-Host "Already up to date."
        }
    } finally { Pop-Location }
}

function Do-Status {
    New-Item -ItemType Directory -Force -Path $DataDir | Out-Null

    foreach ($edition in $StoragePaths.Keys) {
        $storage = $StoragePaths[$edition]
        Get-ChildItem $storage -Directory -ErrorAction SilentlyContinue | ForEach-Object {
            Sync-WorkspaceToRepo -WsId $_.Name -WsSrc $_.FullName | Out-Null
        }
    }

    Push-Location $RepoDir
    try {
        Write-Host "=== Active Editions ==="
        foreach ($edition in $StoragePaths.Keys) {
            Write-Host "  ${edition}: $($StoragePaths[$edition])"
        }
        Write-Host ""
        Write-Host "=== Git Status ==="
        git status --short
        Write-Host ""
        Write-Host "=== Workspace Mappings ==="
        Get-ChildItem $DataDir -Filter "workspace.json" -Recurse -ErrorAction SilentlyContinue | ForEach-Object {
            $id = $_.Directory.Name
            $name = Get-WorkspaceName $_.Directory.FullName
            $content = Get-Content $_.FullName -Raw | ConvertFrom-Json
            $uri = $content.folder
            Write-Host ("  {0,-36}  [{1,-18}]  {2}" -f $id, $name, $uri)
        }
    } finally { Pop-Location }
}

switch ($Action) {
    "push"       { Do-Push }
    "force-push" { Write-Host "Force sync: copying ALL workspaces (ignoring timestamps)..."; Do-Push -Force }
    "pull"       { Do-Pull }
    "status"     { Do-Status }
    default  {
        Write-Host "Usage: .\sync.ps1 {push|force-push|pull|status}"
        Write-Host ""
        Write-Host "  push       - Sync changed chats to repo and push (one commit per workspace)"
        Write-Host "  force-push - Sync ALL chats ignoring timestamps (for initial sync)"
        Write-Host "  pull       - Pull from repo and apply to ALL active editions (incl. WSL)"
        Write-Host "  status     - Show pending changes and workspace mappings"
    }
}
