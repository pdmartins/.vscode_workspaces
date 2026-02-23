---
applyTo: '**/*.ps1'
---
# PowerShell Script Directives

## Template Base

```powershell
# Cores via -ForegroundColor: Cyan, Yellow, Green, Red, White, Gray

# Verificação de admin
function Test-Administrator {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = [Security.Principal.WindowsPrincipal]$identity
    $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# Obter diretório do script
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
```

## Padrões de Idempotência

```powershell
# Verificar comando existe
if (-not (Get-Command "tool" -ErrorAction SilentlyContinue)) {
    # instalar
}

# Verificar path existe
if (-not (Test-Path $path)) {
    # criar
}

# Verificar serviço
if ((Get-Service "Name" -ErrorAction SilentlyContinue).Status -ne "Running") {
    # iniciar
}
```

## Parâmetros Interativos

```powershell
param(
    [string]$Param1
)

if ([string]::IsNullOrWhiteSpace($Param1)) {
    $Param1 = Read-Host "📝 Digite valor"
}
```

## Tratamento de Erros

```powershell
try {
    # operação
    Write-Host "✅ Sucesso" -ForegroundColor Green
} catch {
    Write-Host "❌ Erro: $_" -ForegroundColor Red
    exit 1
}
```

## Output Padronizado

```powershell
Write-Host "🔍 Verificando..." -ForegroundColor Cyan
Write-Host "📦 Instalando..." -ForegroundColor Yellow
Write-Host "✅ Concluído!" -ForegroundColor Green
Write-Host "❌ Falhou: $msg" -ForegroundColor Red
Write-Host "⚠️ Aviso: $msg" -ForegroundColor Yellow
```
