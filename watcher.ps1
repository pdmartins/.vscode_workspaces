#Requires -Version 5.1
$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# Load .env
$EnvFile = Join-Path $ScriptDir ".env"
if (Test-Path $EnvFile) {
    Get-Content $EnvFile | ForEach-Object {
        if ($_ -match '^\s*([^#][^=]+)=(.*)$') {
            $key = $matches[1].Trim()
            $val = $matches[2].Trim()
            if ($val) { [Environment]::SetEnvironmentVariable($key, $val, "Process") }
        }
    }
}

$SyncInterval = if ($env:SYNC_INTERVAL) { [int]$env:SYNC_INTERVAL } else { 30 }
$PullInterval = if ($env:PULL_INTERVAL) { [int]$env:PULL_INTERVAL } else { 5 }
$PullIntervalSec = $PullInterval * 60
$VscodeEditions = if ($env:VSCODE_EDITIONS) { $env:VSCODE_EDITIONS } else { "stable,insiders" }

# Collect watch paths
$WatchPaths = @()
$VscodeEditions -split ',' | ForEach-Object {
    $edition = $_.Trim()
    switch ($edition) {
        "stable" {
            $p = if ($env:VSCODE_STORAGE_PATH_STABLE) { $env:VSCODE_STORAGE_PATH_STABLE }
                 else { Join-Path $env:APPDATA "Code\User\workspaceStorage" }
        }
        "insiders" {
            $p = if ($env:VSCODE_STORAGE_PATH_INSIDERS) { $env:VSCODE_STORAGE_PATH_INSIDERS }
                 else { Join-Path $env:APPDATA "Code - Insiders\User\workspaceStorage" }
        }
    }
    if ($p -and (Test-Path $p)) { $WatchPaths += $p }
}

if ($WatchPaths.Count -eq 0) {
    Write-Error "No VS Code storage paths found to watch."
    exit 1
}

Write-Host "=== VS Code Chat Sync Watcher ==="
foreach ($p in $WatchPaths) { Write-Host "Watching: $p" }
Write-Host "Push debounce: ${SyncInterval}s"
Write-Host "Pull interval: ${PullInterval}min"
Write-Host "Press Ctrl+C to stop"

$lastPush = [DateTime]::MinValue
$lastPull = [DateTime]::MinValue
$pendingSync = $false

# Initial pull on startup
Write-Host "[$(Get-Date -Format 'HH:mm:ss')] Startup pull..."
try { & "$ScriptDir\sync.ps1" pull } catch { Write-Warning "Startup pull failed: $_" }
$lastPull = Get-Date

# Setup file watchers for all paths
$watchers = @()
$action = { $script:pendingSync = $true }

foreach ($watchPath in $WatchPaths) {
    $watcher = New-Object System.IO.FileSystemWatcher
    $watcher.Path = $watchPath
    $watcher.IncludeSubdirectories = $true
    $watcher.EnableRaisingEvents = $true
    $watcher.NotifyFilter = [System.IO.NotifyFilters]::LastWrite -bor
                             [System.IO.NotifyFilters]::FileName -bor
                             [System.IO.NotifyFilters]::DirectoryName

    Register-ObjectEvent $watcher "Changed" -Action $action | Out-Null
    Register-ObjectEvent $watcher "Created" -Action $action | Out-Null
    Register-ObjectEvent $watcher "Deleted" -Action $action | Out-Null
    Register-ObjectEvent $watcher "Renamed" -Action $action | Out-Null

    $watchers += $watcher
}

try {
    while ($true) {
        Start-Sleep -Seconds 5
        $now = Get-Date

        # Push on local changes (with debounce)
        if ($pendingSync) {
            $elapsedPush = ($now - $lastPush).TotalSeconds
            if ($elapsedPush -ge $SyncInterval) {
                Write-Host "[$(Get-Date -Format 'HH:mm:ss')] Local changes detected, pushing..."
                Push-Location $ScriptDir
                try { & "$ScriptDir\sync.ps1" push }
                catch { Write-Warning "Push failed: $_" }
                finally { Pop-Location }

                $lastPush = Get-Date
                $pendingSync = $false
            }
        }

        # Periodic pull
        $elapsedPull = ($now - $lastPull).TotalSeconds
        if ($elapsedPull -ge $PullIntervalSec) {
            Write-Host "[$(Get-Date -Format 'HH:mm:ss')] Periodic pull..."
            Push-Location $ScriptDir
            try { & "$ScriptDir\sync.ps1" pull }
            catch { Write-Warning "Pull failed: $_" }
            finally { Pop-Location }

            $lastPull = Get-Date
        }
    }
} finally {
    foreach ($w in $watchers) {
        $w.EnableRaisingEvents = $false
        $w.Dispose()
    }
    Get-EventSubscriber | Unregister-Event
    Write-Host "Watcher stopped."
}
