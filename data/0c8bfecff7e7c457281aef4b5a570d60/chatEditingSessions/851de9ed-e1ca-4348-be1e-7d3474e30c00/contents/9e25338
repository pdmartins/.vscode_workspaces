<#
.SYNOPSIS
    Exports an Azure Resource Group as an ARM Template.

.DESCRIPTION
    This script connects to an Azure tenant, exports all resources from a Resource Group
    as an ARM Template, and saves it locally for later migration or backup.

.PARAMETER TenantId
    ID of the Azure tenant where the Resource Group is located.

.PARAMETER SubscriptionId
    ID of the subscription where the Resource Group is located.

.PARAMETER ResourceGroupName
    Name of the Resource Group to export.

.PARAMETER ExportPath
    Local path where files will be saved. Default: .\azure-migration

.PARAMETER SkipLogin
    If specified, skips login (useful if already authenticated).

.EXAMPLE
    .\Export-AzureResourceGroup.ps1 -TenantId "xxx" -SubscriptionId "yyy" -ResourceGroupName "my-rg"

.EXAMPLE
    .\Export-AzureResourceGroup.ps1 -TenantId "xxx" -SubscriptionId "yyy" -ResourceGroupName "my-rg" -ExportPath ".\backup" -SkipLogin

.NOTES
    Author: Pedro
    Requires: Azure CLI installed
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory = $false, HelpMessage = "Azure tenant ID")]
    [string]$TenantId,

    [Parameter(Mandatory = $false, HelpMessage = "Azure subscription ID")]
    [string]$SubscriptionId,

    [Parameter(Mandatory = $false, HelpMessage = "Name of the Resource Group to export")]
    [string]$ResourceGroupName,

    [Parameter(Mandatory = $false, HelpMessage = "Path to save the files")]
    [string]$ExportPath,

    [Parameter(Mandatory = $false, HelpMessage = "Skip login if already authenticated")]
    [switch]$SkipLogin
)

# === CHECK EXECUTION POLICY ===
$currentPolicy = Get-ExecutionPolicy -Scope CurrentUser
$effectivePolicy = Get-ExecutionPolicy

if ($effectivePolicy -eq "Restricted") {
    Write-Host ""
    Write-Host "════════════════════════════════════════════════════════════════" -ForegroundColor Red
    Write-Host "⚠️  EXECUTION POLICY BLOCKED" -ForegroundColor Red
    Write-Host "════════════════════════════════════════════════════════════════" -ForegroundColor Red
    Write-Host ""
    Write-Host "The current execution policy does not allow running scripts." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "💡 Options to resolve:" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "   Option 1 - Run this script only (recommended):" -ForegroundColor White
    Write-Host "   powershell -ExecutionPolicy Bypass -File .\Export-AzureResourceGroup.ps1" -ForegroundColor Gray
    Write-Host ""
    Write-Host "   Option 2 - Change policy for current user:" -ForegroundColor White
    Write-Host "   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser" -ForegroundColor Gray
    Write-Host ""
    exit 1
}

# === HEADER ===
Write-Host ""
Write-Host "════════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "☁️  AZURE RESOURCE GROUP EXPORTER" -ForegroundColor Cyan
Write-Host "════════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

# === REQUEST MISSING PARAMETERS ===
if ([string]::IsNullOrWhiteSpace($TenantId)) {
    Write-Host "🔑 Tenant ID:" -ForegroundColor Yellow -NoNewline
    Write-Host " (find it at: Azure Portal > Azure Active Directory > Overview)" -ForegroundColor DarkGray
    $TenantId = Read-Host "   Enter Tenant ID"
    
    if ([string]::IsNullOrWhiteSpace($TenantId)) {
        Write-Host "❌ Tenant ID is required." -ForegroundColor Red
        exit 1
    }
    Write-Host ""
}

if ([string]::IsNullOrWhiteSpace($SubscriptionId)) {
    Write-Host "🎫 Subscription ID:" -ForegroundColor Yellow -NoNewline
    Write-Host " (find it at: Azure Portal > Subscriptions)" -ForegroundColor DarkGray
    $SubscriptionId = Read-Host "   Enter Subscription ID"
    
    if ([string]::IsNullOrWhiteSpace($SubscriptionId)) {
        Write-Host "❌ Subscription ID is required." -ForegroundColor Red
        exit 1
    }
    Write-Host ""
}

if ([string]::IsNullOrWhiteSpace($ResourceGroupName)) {
    Write-Host "📦 Resource Group Name:" -ForegroundColor Yellow -NoNewline
    Write-Host " (name of the Resource Group to export)" -ForegroundColor DarkGray
    $ResourceGroupName = Read-Host "   Enter Resource Group name"
    
    if ([string]::IsNullOrWhiteSpace($ResourceGroupName)) {
        Write-Host "❌ Resource Group Name is required." -ForegroundColor Red
        exit 1
    }
    Write-Host ""
}

if ([string]::IsNullOrWhiteSpace($ExportPath)) {
    Write-Host "📁 Export path:" -ForegroundColor Yellow -NoNewline
    Write-Host " (where files will be saved)" -ForegroundColor DarkGray
    Write-Host "   Press Enter to use default: .\azure-migration" -ForegroundColor DarkGray
    $inputPath = Read-Host "   Enter path"
    
    if ([string]::IsNullOrWhiteSpace($inputPath)) {
        $ExportPath = ".\azure-migration"
    } else {
        $ExportPath = $inputPath
    }
    Write-Host ""
}

# === DISPLAY CONFIGURATION ===
Write-Host "📋 Configuration:" -ForegroundColor Cyan
Write-Host "   Tenant ID:      $TenantId" -ForegroundColor White
Write-Host "   Subscription:   $SubscriptionId" -ForegroundColor White
Write-Host "   Resource Group: $ResourceGroupName" -ForegroundColor White
Write-Host "   Export Path:    $ExportPath" -ForegroundColor White
Write-Host "   Skip Login:     $SkipLogin" -ForegroundColor White
Write-Host ""

# === VALIDATE AZURE CLI ===
Write-Host "🔍 Checking Azure CLI..." -ForegroundColor Cyan

$azVersion = az version 2>$null | ConvertFrom-Json
if (-not $azVersion) {
    Write-Host "❌ Azure CLI is not installed or not in PATH." -ForegroundColor Red
    Write-Host "💡 Install via: winget install Microsoft.AzureCLI" -ForegroundColor Yellow
    exit 1
} else {
    Write-Host "✅ Azure CLI version: $($azVersion.'azure-cli')" -ForegroundColor Green
}

# === CREATE EXPORT FOLDER ===
if (!(Test-Path $ExportPath)) {
    Write-Host "📁 Creating export folder: $ExportPath" -ForegroundColor Yellow
    
    try {
        New-Item -ItemType Directory -Path $ExportPath -Force | Out-Null
        Write-Host "✅ Folder created successfully!" -ForegroundColor Green
    } catch {
        Write-Host "❌ Error creating folder: $_" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "✅ Export folder already exists: $ExportPath" -ForegroundColor Green
}

# === LOGIN TO TENANT ===
if (-not $SkipLogin) {
    Write-Host "🔐 Logging in to tenant: $TenantId" -ForegroundColor Cyan
    
    try {
        az login --tenant $TenantId
        
        if ($LASTEXITCODE -ne 0) {
            throw "Login failed"
        }
        
        Write-Host "✅ Login successful!" -ForegroundColor Green
    } catch {
        Write-Host "❌ Error logging in: $_" -ForegroundColor Red
        Write-Host "💡 Check if Tenant ID is correct" -ForegroundColor Yellow
        exit 1
    }
} else {
    Write-Host "⏭️  Skipping login (using existing session)" -ForegroundColor Yellow
}

# === SELECT SUBSCRIPTION ===
Write-Host "🎯 Selecting subscription: $SubscriptionId" -ForegroundColor Cyan

try {
    az account set --subscription $SubscriptionId
    
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to select subscription"
    }
    
    Write-Host "✅ Subscription selected successfully!" -ForegroundColor Green
} catch {
    Write-Host "❌ Error selecting subscription: $_" -ForegroundColor Red
    Write-Host "💡 Check if Subscription ID is correct and you have access" -ForegroundColor Yellow
    exit 1
}

# === CHECK IF RESOURCE GROUP EXISTS ===
Write-Host "🔍 Checking Resource Group: $ResourceGroupName" -ForegroundColor Cyan

$rgExists = az group exists --name $ResourceGroupName
if ($rgExists -ne "true") {
    Write-Host "❌ Resource Group '$ResourceGroupName' not found." -ForegroundColor Red
    Write-Host "💡 Check the Resource Group name and try again" -ForegroundColor Yellow
    exit 1
} else {
    Write-Host "✅ Resource Group found!" -ForegroundColor Green
}

# === LIST RESOURCES IN RESOURCE GROUP ===
Write-Host ""
Write-Host "📋 Resources in Resource Group:" -ForegroundColor Yellow
Write-Host "────────────────────────────────────────────────────────────────" -ForegroundColor DarkGray

$resourceList = az resource list --resource-group $ResourceGroupName --output json | ConvertFrom-Json
az resource list --resource-group $ResourceGroupName --output table

Write-Host "────────────────────────────────────────────────────────────────" -ForegroundColor DarkGray
Write-Host ""

# === DEFINE FILE NAMES ===
$templateFile = Join-Path $ExportPath "resource_template.json"
$backupFile = Join-Path $ExportPath "resource_template_backup.json"
$documentationFile = Join-Path $ExportPath "resource_documentation.md"

# === EXPORT ARM TEMPLATE ===
Write-Host "📦 Exporting ARM Template..." -ForegroundColor Cyan

try {
    az group export `
        --name $ResourceGroupName `
        --include-parameter-default-value `
        --output json > $templateFile
    
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to export template"
    }
    
    Write-Host "✅ Template exported successfully!" -ForegroundColor Green
} catch {
    Write-Host "❌ Error exporting template: $_" -ForegroundColor Red
    Write-Host "💡 Some resources may not support export" -ForegroundColor Yellow
    exit 1
}

# === CREATE BACKUP ===
Write-Host "💾 Creating template backup..." -ForegroundColor Cyan

try {
    Copy-Item $templateFile $backupFile
    Write-Host "✅ Backup created successfully!" -ForegroundColor Green
} catch {
    Write-Host "⚠️  Could not create backup, but continuing with main file" -ForegroundColor Yellow
}

# === GENERATE MARKDOWN DOCUMENTATION ===
Write-Host "📝 Generating resource documentation..." -ForegroundColor Cyan

try {
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    
    $markdown = @"
# Azure Resource Group Export

## Export Information

| Field | Value |
|-------|-------|
| **Date/Time** | $timestamp |
| **Tenant ID** | $TenantId |
| **Subscription ID** | $SubscriptionId |
| **Resource Group** | $ResourceGroupName |

## Exported Resources

| Name | Type | Location |
|------|------|----------|
"@

    foreach ($resource in $resourceList) {
        $name = $resource.name
        $type = $resource.type
        $location = $resource.location
        $markdown += "`n| $name | $type | $location |"
    }

    $markdown += @"


## Generated Files

| File | Description |
|------|-------------|
| ``resource_template.json`` | ARM template for import in new tenant |
| ``resource_template_backup.json`` | Template backup |
| ``resource_documentation.md`` | This documentation file |

## Next Steps

1. Run the import script in the new tenant
2. Provide the new Resource Group name
3. Verify all resources were created correctly

## Notes

- Some sub-resources (extensions, certificates, siteextensions) are not exported automatically
- Custom HTTPS configurations need to be reconfigured manually
- Managed Identities may need new permissions in the new tenant
"@

    $markdown | Out-File -FilePath $documentationFile -Encoding UTF8
    Write-Host "✅ Documentation generated successfully!" -ForegroundColor Green
} catch {
    Write-Host "⚠️  Could not generate documentation: $_" -ForegroundColor Yellow
}

# === SUMMARY ===
Write-Host ""
Write-Host "════════════════════════════════════════════════════════════════" -ForegroundColor Green
Write-Host "✅ EXPORT COMPLETED SUCCESSFULLY!" -ForegroundColor Green
Write-Host "════════════════════════════════════════════════════════════════" -ForegroundColor Green
Write-Host ""
Write-Host "📄 Template:      $templateFile" -ForegroundColor White
Write-Host "💾 Backup:        $backupFile" -ForegroundColor White
Write-Host "📝 Documentation: $documentationFile" -ForegroundColor White
Write-Host ""
Write-Host "💡 Next step: Run the import script in the new tenant" -ForegroundColor Cyan
Write-Host ""

# === RETURN INFO ===
$result = @{
    TemplatePath       = $templateFile
    BackupPath         = $backupFile
    DocumentationPath  = $documentationFile
    ResourceGroupName  = $ResourceGroupName
    ResourceCount      = $resourceList.Count
}

return $result
