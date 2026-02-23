# Script para instalar Docker Engine no Windows (WSL2)
# Autor: GitHub Copilot
# Data: 2026-01-30
# Nota: Este script instala o Docker Engine via WSL2, não o Docker Desktop

# Cores para output
$ErrorActionPreference = "Stop"

Write-Host "🐳 Instalando Docker Engine via WSL2..." -ForegroundColor Cyan

# Função para verificar se está rodando como administrador
function Test-Administrator {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# Verificar privilégios de administrador
if (-not (Test-Administrator)) {
    Write-Host "❌ Este script precisa ser executado como Administrador!" -ForegroundColor Red
    Write-Host "💡 Clique com o botão direito no PowerShell e selecione 'Executar como administrador'" -ForegroundColor Yellow
    exit 1
}

# Verificar se WSL está instalado
Write-Host "🔍 Verificando instalação do WSL..." -ForegroundColor Yellow

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
    Write-Host "📦 WSL não está instalado. Instalando WSL2..." -ForegroundColor Yellow
    
    try {
        wsl --install --no-distribution
        Write-Host "✅ WSL2 instalado com sucesso!" -ForegroundColor Green
        Write-Host "⚠️  É necessário reiniciar o computador para continuar." -ForegroundColor Yellow
        Write-Host "💡 Após reiniciar, execute este script novamente." -ForegroundColor Cyan
        
        $restart = Read-Host "Deseja reiniciar agora? (s/n)"
        if ($restart -eq "s" -or $restart -eq "S") {
            Restart-Computer -Force
        }
        exit 0
    } catch {
        Write-Host "❌ Erro ao instalar WSL: $_" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "✅ WSL já está instalado" -ForegroundColor Green
}

# Verificar se existe uma distribuição Linux instalada
Write-Host "🔍 Verificando distribuições Linux instaladas..." -ForegroundColor Yellow

$distroList = wsl --list --quiet 2>$null | Where-Object { $_ -and $_.Trim() -ne "" -and $_ -notmatch "docker-desktop" }
# Limpar caracteres nulos que o WSL às vezes retorna
$distroList = $distroList | ForEach-Object { $_ -replace "`0", "" } | Where-Object { $_.Trim() -ne "" }

if (-not $distroList -or @($distroList).Count -eq 0) {
    Write-Host "📦 Nenhuma distribuição Linux encontrada. Instalando Ubuntu..." -ForegroundColor Yellow
    
    try {
        wsl --install -d Ubuntu
        Write-Host "✅ Ubuntu instalado com sucesso!" -ForegroundColor Green
        Write-Host "⚠️  Configure seu usuário e senha no Ubuntu que será aberto." -ForegroundColor Yellow
        Write-Host "💡 Após configurar, execute este script novamente para instalar o Docker." -ForegroundColor Cyan
        exit 0
    } catch {
        Write-Host "❌ Erro ao instalar Ubuntu: $_" -ForegroundColor Red
        exit 1
    }
}

# Converter para array se necessário
$distroList = @($distroList)

# Selecionar distro
if ($distroList.Count -eq 1) {
    $selectedDistro = $distroList[0].Trim()
    Write-Host "✅ Distribuição Linux encontrada: $selectedDistro" -ForegroundColor Green
} else {
    Write-Host "📋 Múltiplas distribuições Linux encontradas:" -ForegroundColor Cyan
    for ($i = 0; $i -lt $distroList.Count; $i++) {
        Write-Host "   [$($i + 1)] $($distroList[$i].Trim())" -ForegroundColor White
    }
    Write-Host ""
    
    do {
        $selection = Read-Host "🐧 Escolha a distribuição (1-$($distroList.Count))"
        $selectionIndex = [int]$selection - 1
    } while ($selectionIndex -lt 0 -or $selectionIndex -ge $distroList.Count)
    
    $selectedDistro = $distroList[$selectionIndex].Trim()
    Write-Host "✅ Distribuição selecionada: $selectedDistro" -ForegroundColor Green
}

# Verificar se Docker já está instalado no WSL
Write-Host "🔍 Verificando se Docker já está instalado no WSL ($selectedDistro)..." -ForegroundColor Yellow

$dockerInstalled = wsl -d $selectedDistro -- docker --version 2>$null
if ($LASTEXITCODE -eq 0 -and $dockerInstalled) {
    Write-Host "✅ Docker já está instalado no WSL: $dockerInstalled" -ForegroundColor Green
    
    # Verificar se o serviço está rodando
    $dockerRunning = wsl -d $selectedDistro -- docker info 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Docker está rodando!" -ForegroundColor Green
    } else {
        Write-Host "⚠️  Docker está instalado mas não está rodando." -ForegroundColor Yellow
        Write-Host "🔄 Iniciando serviço Docker..." -ForegroundColor Yellow
        wsl -d $selectedDistro -- sudo service docker start
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ Serviço Docker iniciado com sucesso!" -ForegroundColor Green
        } else {
            Write-Host "❌ Erro ao iniciar serviço Docker" -ForegroundColor Red
        }
    }
    exit 0
}

# Instalar Docker no WSL
Write-Host "📦 Instalando Docker Engine no WSL ($selectedDistro)..." -ForegroundColor Yellow
Write-Host ""
Write-Host "┌─────────────────────────────────────────────────────────────┐" -ForegroundColor Magenta
Write-Host "│  🐧 Executando no WSL - digite a senha sudo se solicitado  │" -ForegroundColor Magenta
Write-Host "└─────────────────────────────────────────────────────────────┘" -ForegroundColor Magenta
Write-Host ""

# Obter caminho do script bash (na mesma pasta do script ps1)
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$bashScript = Join-Path $scriptDir "install-docker.sh"

# Verificar se o script bash existe
if (-not (Test-Path $bashScript)) {
    Write-Host "❌ Script bash não encontrado: $bashScript" -ForegroundColor Red
    exit 1
}

# Converter caminho Windows para WSL
$wslPath = wsl -d $selectedDistro -- wslpath -u ($bashScript -replace '\\', '/')

# Executar script no WSL de forma interativa (permite sudo pedir senha)
Write-Host "🚀 Executando instalação no WSL..." -ForegroundColor Cyan
Write-Host ""

# Execução direta - permite interação com sudo
wsl -d $selectedDistro -- bash $wslPath
$exitCode = $LASTEXITCODE

Write-Host ""

if ($exitCode -eq 0) {
    Write-Host ""
    Write-Host "✅ Docker Engine instalado com sucesso no WSL!" -ForegroundColor Green
    Write-Host ""
    Write-Host "📋 Para usar o Docker:" -ForegroundColor Cyan
    Write-Host "   • Abra o WSL (digite 'wsl' no terminal)" -ForegroundColor White
    Write-Host "   • Use comandos docker normalmente (docker run, docker ps, etc.)" -ForegroundColor White
    Write-Host ""
    Write-Host "💡 Dica: Para usar 'docker' diretamente do PowerShell, adicione ao seu perfil:" -ForegroundColor Yellow
    Write-Host '   function docker { wsl docker $args }' -ForegroundColor Gray
    Write-Host '   function docker-compose { wsl docker compose $args }' -ForegroundColor Gray
    Write-Host ""
    Write-Host "   Ou especificando a distro:" -ForegroundColor Yellow
    Write-Host "   function docker { wsl -d $selectedDistro docker `$args }" -ForegroundColor Gray
} else {
    Write-Host "❌ Erro durante a instalação do Docker" -ForegroundColor Red
    exit 1
}
