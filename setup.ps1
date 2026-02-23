#Requires -RunAsAdministrator
$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

Write-Host "=== VS Code Chat Sync - Windows Setup ==="

# Copy .env if not exists
$EnvFile = Join-Path $ScriptDir ".env"
if (-not (Test-Path $EnvFile)) {
    Copy-Item (Join-Path $ScriptDir ".env.example") $EnvFile
    Write-Host "Created .env from .env.example - edit if needed."
}

# Show detected editions
Write-Host ""
Write-Host "Detected VS Code editions:"
$stablePath = Join-Path $env:APPDATA "Code\User\workspaceStorage"
$insidersPath = Join-Path $env:APPDATA "Code - Insiders\User\workspaceStorage"
if (Test-Path $stablePath) { Write-Host "  - Stable ($stablePath)" }
if (Test-Path $insidersPath) { Write-Host "  - Insiders ($insidersPath)" }

# Create scheduled task
$TaskName = "VSCodeChatSync"

$existingTask = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue
if ($existingTask) {
    Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false
    Write-Host "Removed existing task."
}

$WatcherPath = Join-Path $ScriptDir "watcher.ps1"

$Action = New-ScheduledTaskAction `
    -Execute "powershell.exe" `
    -Argument "-NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File `"$WatcherPath`"" `
    -WorkingDirectory $ScriptDir

$Trigger = New-ScheduledTaskTrigger -AtLogOn -User $env:USERNAME

$Settings = New-ScheduledTaskSettingsSet `
    -AllowStartIfOnBatteries `
    -DontStopIfGoingOnBatteries `
    -StartWhenAvailable `
    -RestartCount 3 `
    -RestartInterval (New-TimeSpan -Minutes 1)

Register-ScheduledTask `
    -TaskName $TaskName `
    -Action $Action `
    -Trigger $Trigger `
    -Settings $Settings `
    -Description "Watches VS Code Stable + Insiders chat history and syncs via Git" `
    -RunLevel Limited

Start-ScheduledTask -TaskName $TaskName

Write-Host ""
Write-Host "Task Scheduler job installed and started!"
Write-Host ""
Write-Host "Commands:"
Write-Host "  Get-ScheduledTask -TaskName $TaskName         # Check status"
Write-Host "  Stop-ScheduledTask -TaskName $TaskName         # Stop"
Write-Host "  Start-ScheduledTask -TaskName $TaskName        # Start"
Write-Host "  Unregister-ScheduledTask -TaskName $TaskName   # Remove"
