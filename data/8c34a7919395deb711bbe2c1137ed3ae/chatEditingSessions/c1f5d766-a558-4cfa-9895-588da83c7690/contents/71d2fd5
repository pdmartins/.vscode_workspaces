# ============================================================================
# Script: export-git-repos.ps1
# Description: Procura repos Git em uma pasta, identifica remote/branch e gera
#              script para clonar a estrutura em outro computador
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
Uso: .\export-git-repos.ps1 [OPÇÕES]

Procura repositórios Git em uma pasta e gera script para clonar a estrutura.

OPÇÕES:
    -Path PATH       Pasta raiz para buscar repos (padrão: diretório atual)
    -Output FILE     Arquivo de saída para o script (padrão: clone-repos.ps1)

EXEMPLOS:
    .\export-git-repos.ps1 -Path C:\Projetos
    .\export-git-repos.ps1 -Path D:\Repos -Output meus-repos.ps1

"@
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
    $resolvedPath = Resolve-Path -Path $InputPath -ErrorAction SilentlyContinue
    
    if (-not $resolvedPath -or -not (Test-Path $resolvedPath)) {
        Write-Err "Pasta não encontrada: $InputPath"
        exit 1
    }
    
    return $resolvedPath.Path
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
    
    return $InputFile
}

function Find-GitRepos {
    param([string]$SearchPath)
    
    Write-Info "Buscando repositórios Git em: $SearchPath"
    
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
    
    Write-Step "Gerando script de clonagem..."
    
    $repoCount = 0
    
    # Cabeçalho do script
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
        Write-Warn "Repo já existe: $RelativePath"
        return
    }
    
    Write-Info "Clonando: $RelativePath"
    Write-Info "  URL: $RemoteUrl"
    Write-Info "  Branch: $Branch"
    
    $parentDir = Split-Path -Parent $targetDir
    if (-not (Test-Path $parentDir)) {
        New-Item -Path $parentDir -ItemType Directory -Force | Out-Null
    }
    
    try {
        git clone --branch $Branch $RemoteUrl $targetDir 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-Success "Clonado: $RelativePath"
        } else {
            throw "Clone failed"
        }
    }
    catch {
        # Tentar sem branch específica
        try {
            git clone $RemoteUrl $targetDir 2>$null
            Write-Warn "Clonado (branch padrão): $RelativePath"
        }
        catch {
            Write-Err "Falha ao clonar: $RelativePath"
        }
    }
}

Write-Step "Clonando repositórios para: $BaseDir"

# ============================================================================
# Repositories
# ============================================================================

'@

    # Adicionar metadados
    $scriptContent += "`n# Gerado em: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')`n"
    $scriptContent += "# Pasta original: $SearchPath`n`n"
    
    # Processar cada repositório
    $repos = Find-GitRepos -SearchPath $SearchPath
    
    foreach ($repoPath in $repos) {
        $repoInfo = Get-RepoInfo -RepoPath $repoPath
        
        # Caminho relativo à pasta de busca
        $relativePath = $repoPath.Substring($SearchPath.Length).TrimStart('\', '/')
        
        if ([string]::IsNullOrWhiteSpace($repoInfo.RemoteUrl)) {
            Write-Warn "Repo sem remote origin: $relativePath"
            $scriptContent += "# AVISO: Repo local sem remote - $relativePath`n"
            continue
        }
        
        $scriptContent += "Invoke-CloneRepo -RelativePath `"$relativePath`" -RemoteUrl `"$($repoInfo.RemoteUrl)`" -Branch `"$($repoInfo.Branch)`"`n"
        $repoCount++
        
        Write-Info "Encontrado: $relativePath"
        Write-Host "           Branch: $($repoInfo.Branch)"
    }
    
    # Footer do script
    $scriptContent += @'

# ============================================================================
# Summary
# ============================================================================

Write-Success "Processo de clonagem concluído!"
'@

    # Salvar arquivo
    $scriptContent | Out-File -FilePath $OutputFile -Encoding utf8
    
    return $repoCount
}

# ============================================================================
# Main
# ============================================================================

function Main {
    Write-Step "Exportador de Repositórios Git"
    Write-Host ""
    
    $searchPath = Get-SearchPath -InputPath $Path
    $outputFile = Get-OutputFile -InputFile $Output
    
    Write-Host ""
    
    $count = New-CloneScript -SearchPath $searchPath -OutputFile $outputFile
    
    Write-Host ""
    Write-Success "Script gerado: $outputFile"
    Write-Success "Total de repositórios: $count"
    Write-Host ""
    Write-Info "Para usar em outro computador:"
    Write-Host "    1. Copie o arquivo '$outputFile' para o destino"
    Write-Host "    2. Execute: .\$outputFile -BaseDir [pasta_destino]"
}

Main
