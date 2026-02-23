# ============================================================================
# Script: export-git-repos.ps1
# Description: Procura repos Git em uma pasta, identifica remote/branch e gera
#              script para clonar a estrutura em outro computador
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
    Write-Host "Uso: .\export-git-repos.ps1 [opções]"
    Write-Host ""
    Write-Host "Opções:"
    Write-Host "  -Path PATH       Pasta raiz para buscar repos (padrão: diretório atual)"
    Write-Host "  -Output FILE     Arquivo de saída para o script (padrão: clone-repos.ps1)"
    Write-Host "  -Help            Mostra esta ajuda"
    Write-Host ""
    Write-Host "Exemplos:"
    Write-Host "  .\export-git-repos.ps1 -Path C:\Projetos"
    Write-Host "  .\export-git-repos.ps1 -Path D:\Repos -Output meus-repos.ps1"
}

function Test-Prerequisites {
    Write-Info "Verificando pré-requisitos..."
    
    if (-not (Get-Command "git" -ErrorAction SilentlyContinue)) {
        Write-Err "Git não encontrado. Instale o Git primeiro."
        exit 1
    }
    
    Write-Success "Pré-requisitos OK"
}

function Get-SearchPath {
    param([string]$InputPath)
    
    if ([string]::IsNullOrWhiteSpace($InputPath)) {
        $InputPath = Read-Host "📁 Pasta raiz para buscar repos [$(Get-Location)]"
        if ([string]::IsNullOrWhiteSpace($InputPath)) {
            $InputPath = (Get-Location).Path
        }
    }
    
    # Resolver path absoluto
    try {
        $resolvedPath = (Resolve-Path -Path $InputPath -ErrorAction Stop).Path
    }
    catch {
        Write-Err "Pasta não encontrada: $InputPath"
        exit 1
    }
    
    if (-not (Test-Path $resolvedPath -PathType Container)) {
        Write-Err "Pasta não encontrada: $InputPath"
        exit 1
    }
    
    Write-Info "Pasta de busca: $resolvedPath"
    return $resolvedPath
}

function Get-OutputFile {
    param([string]$InputFile)
    
    if ([string]::IsNullOrWhiteSpace($InputFile)) {
        $InputFile = Read-Host "📄 Nome do arquivo de saída [clone-repos.ps1]"
        if ([string]::IsNullOrWhiteSpace($InputFile)) {
            $InputFile = "clone-repos.ps1"
        }
    }
    
    # Garantir extensão .ps1
    if (-not $InputFile.EndsWith(".ps1")) {
        $InputFile = "$InputFile.ps1"
    }
    
    Write-Info "Arquivo de saída: $InputFile"
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
    
    Write-Step "Buscando repositórios Git recursivamente..."
    Write-Host ""
    
    # Buscar todos os diretórios .git recursivamente
    $gitDirs = Get-ChildItem -Path $SearchPath -Directory -Recurse -Filter ".git" -Force -ErrorAction SilentlyContinue
    
    $total = $gitDirs.Count
    Write-Info "Encontrados $total repositórios Git"
    Write-Host ""
    
    $current = 0
    foreach ($gitDir in $gitDirs) {
        $current++
        $repoPath = $gitDir.Parent.FullName
        
        # Caminho relativo à pasta de busca
        $relativePath = $repoPath.Substring($SearchPath.Length).TrimStart('\', '/')
        
        # Obter informações do repo
        $repoInfo = Get-RepoInfo -RepoPath $repoPath
        
        Write-Host "[$current/$total] " -ForegroundColor Cyan -NoNewline
        Write-Host $relativePath
        
        if ([string]::IsNullOrWhiteSpace($repoInfo.RemoteUrl)) {
            Write-Warn "  └── Sem remote origin (ignorado)"
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
    Write-Step "Gerando script de clonagem..."
    
    # Cabeçalho do script gerado
    $scriptContent = @'
# ============================================================================
# Script: clone-repos.ps1 (gerado automaticamente)
# Description: Clona repositórios Git mantendo estrutura de pastas original
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
        Write-Warn "Repo já existe: $RelativePath"
        $script:ReposSkipped += $RelativePath
        return
    }
    
    Write-Install "Clonando: $RelativePath"
    Write-Host "  ├── URL: $RemoteUrl"
    Write-Host "  └── Branch: $Branch"
    
    # Criar pasta pai se não existir
    $parentDir = Split-Path -Parent $targetDir
    if (-not (Test-Path $parentDir)) {
        New-Item -Path $parentDir -ItemType Directory -Force | Out-Null
    }
    
    # Tentar clonar com branch específica
    $result = git clone --branch $Branch $RemoteUrl $targetDir 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Success "Clonado: $RelativePath"
        $script:ReposCloned += $RelativePath
    }
    else {
        # Tentar sem branch específica
        $result = git clone $RemoteUrl $targetDir 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Warn "Clonado (branch padrão): $RelativePath"
            $script:ReposCloned += $RelativePath
        }
        else {
            Write-Err "Falha ao clonar: $RelativePath"
            $script:ReposFailed += $RelativePath
        }
    }
}

function Show-Summary {
    Write-Host ""
    Write-Host "============================================================================"
    Write-Host " Resumo"
    Write-Host "============================================================================"
    
    if ($script:ReposCloned.Count -gt 0) {
        Write-Success "Clonados: $($script:ReposCloned.Count)"
    }
    
    if ($script:ReposSkipped.Count -gt 0) {
        Write-Warn "Já existentes: $($script:ReposSkipped.Count)"
    }
    
    if ($script:ReposFailed.Count -gt 0) {
        Write-Err "Falhas: $($script:ReposFailed.Count)"
        foreach ($repo in $script:ReposFailed) {
            Write-Host "  - $repo"
        }
    }
}

# ============================================================================
# Main
# ============================================================================

function Main {
    Write-Step "Clonando repositórios para: $BaseDir"
    Write-Host ""

'@

    # Adicionar metadados
    $scriptContent += "`n# Gerado em: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')`n"
    $scriptContent += "# Pasta original: $SearchPath`n"
    $scriptContent += "# Total de repositórios: $($script:ReposFound.Count)`n`n"
    
    # Adicionar chamadas de clone para cada repo
    foreach ($repo in $script:ReposFound) {
        $scriptContent += "    Invoke-CloneRepo -RelativePath `"$($repo.RelativePath)`" -RemoteUrl `"$($repo.RemoteUrl)`" -Branch `"$($repo.Branch)`"`n"
    }
    
    # Footer do script
    $scriptContent += @'

    Show-Summary
}

Main
'@

    # Salvar arquivo
    $scriptContent | Out-File -FilePath $OutputFile -Encoding utf8
}

function Show-Summary {
    Write-Host ""
    Write-Host "============================================================================"
    Write-Host " Resumo"
    Write-Host "============================================================================"
    
    Write-Success "Repositórios encontrados: $($script:ReposFound.Count)"
    
    if ($script:ReposNoRemote.Count -gt 0) {
        Write-Warn "Sem remote (ignorados): $($script:ReposNoRemote.Count)"
        foreach ($repo in $script:ReposNoRemote) {
            Write-Host "  - $repo"
        }
    }
    
    Write-Host ""
    Write-Success "Script gerado: $script:OutputFile"
    Write-Host ""
    Write-Info "Para usar em outro computador:"
    Write-Host "    1. Copie o arquivo '$script:OutputFile' para o destino"
    Write-Host "    2. Execute: .\$script:OutputFile -BaseDir [pasta_destino]"
}

# ============================================================================
# Main
# ============================================================================

function Main {
    Write-Step "Exportador de Repositórios Git"
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
        Write-Warn "Nenhum repositório com remote origin encontrado."
        exit 0
    }
    
    New-CloneScript -OutputFile $script:OutputFile -SearchPath $script:SearchPath
    Show-Summary
}

Main
