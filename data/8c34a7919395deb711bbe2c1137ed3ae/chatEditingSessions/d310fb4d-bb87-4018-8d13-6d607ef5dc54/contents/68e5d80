# PowerShell Script Skill

<skill id="powershell" context="*.ps1 files">

## Quando Usar

<triggers>
  - Criar/editar arquivos `*.ps1`
  - Pedido para criar script PowerShell
</triggers>

## Workflow

<workflow id="powershell-script-workflow">
  <step n="1" goal="Validar estrutura do script">
    <check if="arquivo novo">
      <action>Aplicar template base completo</action>
    </check>
    
    <check if="arquivo existente">
      <action>Preservar estrutura e estilo existente</action>
      <action>Identificar padrões já utilizados</action>
    </check>
  </step>

  <step n="2" goal="Verificar bloco param">
    <check if="script aceita parâmetros">
      <validate condition="bloco param() no topo">
        <action if="false">Adicionar bloco param com tipos adequados</action>
      </validate>
    </check>
  </step>

  <step n="3" goal="Verificar funções helper">
    <check if="script precisa verificar admin">
      <validate condition="função Test-Administrator existe">
        <action if="false">Adicionar função de verificação</action>
      </validate>
    </check>
  </step>

  <step n="4" goal="Aplicar padrões de idempotência">
    <action>Antes de instalar/criar, verificar se já existe</action>
    <action>Usar Get-Command para verificar comandos</action>
    <action>Usar Test-Path para verificar paths</action>
  </step>

  <step n="5" goal="Garantir tratamento de erros">
    <validate condition="try/catch em operações críticas">
      <action if="false">Envolver operações em try/catch</action>
    </validate>
  </step>
</workflow>

## Template Base

```powershell
# ============================================================================
# Script: {Nome-Do-Script}.ps1
# Description: {descrição breve}
# ============================================================================

param(
    [string]$Param1,
    [switch]$Force
)

# ============================================================================
# Helper Functions
# ============================================================================

function Test-Administrator {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = [Security.Principal.WindowsPrincipal]$identity
    $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

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

function Write-Warning {
    param([string]$Message)
    Write-Host "⚠️ $Message" -ForegroundColor Yellow
}

function Write-Error {
    param([string]$Message)
    Write-Host "❌ $Message" -ForegroundColor Red
}

# Script directory
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# ============================================================================
# Functions
# ============================================================================

function Test-Prerequisites {
    Write-Info "Checking prerequisites..."
    
    # Example: check if command exists
    # if (-not (Get-Command "docker" -ErrorAction SilentlyContinue)) {
    #     Write-Error "Docker not found"
    #     exit 1
    # }
    
    Write-Success "Prerequisites OK"
}

# ============================================================================
# Main
# ============================================================================

function Main {
    Write-Step "Starting {Nome-Do-Script}..."
    
    try {
        Test-Prerequisites
        
        # Add main logic here
        
        Write-Success "Done!"
    }
    catch {
        Write-Error "Error: $_"
        exit 1
    }
}

Main
```

## Padrões de Código

<patterns>
  <pattern name="idempotency-command">
    ```powershell
    if (-not (Get-Command "tool" -ErrorAction SilentlyContinue)) {
        Write-Info "Installing tool..."
        # install
    } else {
        Write-Success "Tool already installed"
    }
    ```
  </pattern>

  <pattern name="idempotency-path">
    ```powershell
    if (-not (Test-Path $Path)) {
        Write-Info "Creating path..."
        New-Item -Path $Path -ItemType Directory -Force | Out-Null
    } else {
        Write-Success "Path already exists"
    }
    ```
  </pattern>

  <pattern name="idempotency-service">
    ```powershell
    $service = Get-Service "ServiceName" -ErrorAction SilentlyContinue
    if ($null -eq $service) {
        Write-Info "Installing service..."
        # install
    } elseif ($service.Status -ne "Running") {
        Write-Info "Starting service..."
        Start-Service "ServiceName"
    }
    ```
  </pattern>

  <pattern name="interactive-param">
    ```powershell
    param(
        [string]$Param1
    )
    
    if ([string]::IsNullOrWhiteSpace($Param1)) {
        $Param1 = Read-Host "📝 Enter value"
    }
    
    if ([string]::IsNullOrWhiteSpace($Param1)) {
        Write-Error "Parameter required"
        exit 1
    }
    ```
  </pattern>

  <pattern name="admin-check">
    ```powershell
    if (-not (Test-Administrator)) {
        Write-Error "This script requires Administrator privileges"
        Write-Warning "Right-click PowerShell and select 'Run as Administrator'"
        exit 1
    }
    ```
  </pattern>

  <pattern name="error-handling">
    ```powershell
    try {
        # Critical operation
        Some-Command -ErrorAction Stop
        Write-Success "Operation completed"
    }
    catch {
        Write-Error "Failed: $_"
        exit 1
    }
    ```
  </pattern>
</patterns>

## Convenções

<conventions>
  <naming>
    <rule>Nomes de arquivo: `verbo-substantivo.ps1` (kebab-case)</rule>
    <rule>Funções: `Verb-Noun` (PascalCase com verbo aprovado)</rule>
    <rule>Parâmetros: `$PascalCase`</rule>
    <rule>Variáveis locais: `$PascalCase`</rule>
  </naming>
  
  <approved-verbs>
    <category name="common">Get, Set, New, Remove, Start, Stop, Test, Install, Uninstall</category>
    <category name="lifecycle">Enable, Disable, Initialize, Reset, Update</category>
    <category name="data">Import, Export, Convert, Format, Read, Write</category>
  </approved-verbs>
  
  <structure>
    <rule>Bloco param() no topo (se houver parâmetros)</rule>
    <rule>Funções helper após param</rule>
    <rule>Funções de negócio no meio</rule>
    <rule>Função Main no final</rule>
    <rule>Chamada Main na última linha</rule>
  </structure>
  
  <best-practices>
    <rule>Use -ErrorAction Stop em comandos críticos</rule>
    <rule>Prefira Out-Null para suprimir output indesejado</rule>
    <rule>Use [string]::IsNullOrWhiteSpace() para validar strings</rule>
    <rule>Evite aliases (use Get-ChildItem, não ls/dir)</rule>
  </best-practices>
</conventions>

## Cores Padrão

<colors>
  | Uso | Cor | Emoji |
  |-----|-----|-------|
  | Verificando/Info | Cyan | 🔍 |
  | Instalando | Yellow | 📦 |
  | Sucesso | Green | ✅ |
  | Erro | Red | ❌ |
  | Aviso | Yellow | ⚠️ |
  | Atualizando | Cyan | 🔄 |
  | Executando | White | 🚀 |
</colors>

</skill>
