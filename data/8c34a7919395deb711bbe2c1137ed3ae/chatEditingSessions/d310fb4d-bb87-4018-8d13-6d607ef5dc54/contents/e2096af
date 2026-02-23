# Sync Instructions

<skill id="sync" context="after modifying *.ps1 or *.sh">

## Regras Fundamentais

<rules critical="true">
  <rule id="english-version">
    A pasta `.english-version/` DEVE SEMPRE refletir os scripts da raiz.
    TODA alteração em script/README DEVE ser replicada com textos em inglês.
  </rule>
  
  <rule id="cross-platform">
    TODO script DEVE ter versão Linux (.sh) E Windows (.ps1) quando possível.
    Se não existir solução nativa para uma plataforma, criar WRAPPER para WSL.
  </rule>
</rules>

## Workflow

<workflow id="sync-workflow" trigger="after-script-modification">
  
  <step n="1" goal="Identificar tipo de mudança">
    <action>Analisar alterações feitas no script</action>
    
    <check if="mudança em parâmetros">
      <action>Marcar: sync_params = true</action>
    </check>
    
    <check if="mudança em lógica/comportamento">
      <action>Marcar: sync_logic = true</action>
    </check>
    
    <check if="mudança em output/mensagens">
      <action>Marcar: sync_output = true</action>
    </check>
  </step>

  <step n="2" goal="Determinar estratégia de sincronização">
    <action>Consultar: {workspace}/.github/instructions/core/project-structure.md</action>
    <action>Verificar tabela "Exceções de Sincronização"</action>
    <action>Identificar se pasta tem exceção</action>
    
    <check if="pasta está em exceções com tipo 'wrapper'">
      <action>Marcar: strategy = "wrapper"</action>
      <output>ℹ️ Pasta usa estratégia WRAPPER (PS1 chama SH via WSL)</output>
    </check>
    
    <check if="pasta está em exceções com tipo 'platform-specific'">
      <action>Marcar: strategy = "platform-specific"</action>
      <output>ℹ️ Pasta é específica de plataforma - sem contraparte</output>
    </check>
    
    <check if="pasta NÃO está em exceções">
      <action>Marcar: strategy = "full-sync"</action>
    </check>
  </step>

  <step n="3" goal="Verificar/criar contraparte cross-platform">
    <check if="strategy == 'full-sync'">
      <check if="script é *.sh E NÃO existe *.ps1">
        <action>Criar arquivo .ps1 com mesma lógica adaptada para PowerShell</action>
        <output>✨ Criado: {arquivo}.ps1 (versão Windows)</output>
      </check>
      
      <check if="script é *.ps1 E NÃO existe *.sh">
        <action>Criar arquivo .sh com mesma lógica adaptada para Bash</action>
        <output>✨ Criado: {arquivo}.sh (versão Linux)</output>
      </check>
      
      <check if="ambos existem">
        <action>Sincronizar lógica entre os dois</action>
        <output>🔄 Sincronizado: {arquivo}.ps1 ↔ {arquivo}.sh</output>
      </check>
    </check>
    
    <check if="strategy == 'wrapper'">
      <check if="script é *.sh E NÃO existe *.ps1">
        <action>Criar WRAPPER .ps1 que executa o .sh via WSL</action>
        <action>Usar template de wrapper WSL abaixo</action>
        <output>✨ Criado: {arquivo}.ps1 (wrapper WSL)</output>
      </check>
      
      <check if="script é *.sh E existe *.ps1 wrapper">
        <action>Verificar se wrapper ainda é compatível (mesmos parâmetros)</action>
        <check if="parâmetros mudaram">
          <action>Atualizar wrapper para novos parâmetros</action>
          <output>🔄 Wrapper atualizado: {arquivo}.ps1</output>
        </check>
      </check>
    </check>
    
    <check if="strategy == 'platform-specific'">
      <output>⏭️ Sem contraparte (específico de plataforma)</output>
    </check>
  </step>

  <step n="4" goal="Atualizar README">
    <check if="sync_params == true OU sync_logic == true">
      <action>Atualizar README.md da pasta</action>
      <action>Documentar ambas versões (PS1 e SH)</action>
      <action>Se wrapper, documentar requisito de WSL</action>
      <output>📝 README atualizado</output>
    </check>
  </step>

  <step n="5" goal="Replicar para .english-version/ (OBRIGATÓRIO)">
    <action critical="true">SEMPRE replicar para .english-version/</action>
    
    <check if="script criado ou modificado">
      <action>Criar/atualizar .english-version/{pasta}/{script}</action>
      <action>Traduzir TODOS os comentários para inglês</action>
      <action>Traduzir TODAS as mensagens de output para inglês</action>
      <action>Manter nomes de variáveis/funções iguais (já são em inglês)</action>
    </check>
    
    <check if="contraparte foi criada/sincronizada">
      <action>Criar/atualizar versão EN da contraparte também</action>
    </check>
    
    <check if="README modificado">
      <action>Criar/atualizar .english-version/{pasta}/README.md</action>
      <action>Traduzir todo conteúdo para inglês</action>
    </check>
    
    <output>🌐 Versão EN sincronizada: .english-version/{pasta}/</output>
  </step>

  <step n="6" goal="Resumo de sincronização">
    <output>
      📋 **Resumo de Sincronização**
      
      | Item | Status |
      |------|--------|
      | Script principal | ✅ {ação} |
      | Contraparte ({ext}) | {status} |
      | README.md | {status} |
      | .english-version/ (PT→EN) | ✅ Obrigatório |
    </output>
  </step>
</workflow>

## Template: Wrapper WSL (PS1 → SH)

Usar quando a ferramenta NÃO tem suporte nativo Windows (ex: Docker Engine).

```powershell
# ============================================================================
# Script: {nome}.ps1
# Description: Windows wrapper for {nome}.sh (runs via WSL)
# Requires: WSL with a Linux distribution installed
# ============================================================================

param(
    # Copiar mesmos parâmetros do script .sh
)

# ============================================================================
# Helper Functions
# ============================================================================

function Test-WslAvailable {
    try {
        $null = wsl --status 2>&1
        return $true
    }
    catch {
        return $false
    }
}

function Get-WslDistro {
    $distros = wsl --list --quiet 2>&1 | Where-Object { $_ -and $_ -notmatch "^Windows" }
    if ($distros) {
        return ($distros | Select-Object -First 1).Trim()
    }
    return $null
}

# ============================================================================
# Main
# ============================================================================

Write-Host "🚀 Running {nome} via WSL..." -ForegroundColor White

# Check WSL
if (-not (Test-WslAvailable)) {
    Write-Host "❌ WSL is not available. Please install WSL first." -ForegroundColor Red
    Write-Host "   Run: wsl --install" -ForegroundColor Yellow
    exit 1
}

$distro = Get-WslDistro
if (-not $distro) {
    Write-Host "❌ No WSL distribution found. Please install one." -ForegroundColor Red
    Write-Host "   Run: wsl --install -d Ubuntu" -ForegroundColor Yellow
    exit 1
}

# Get script path in WSL format
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$WslScriptDir = $ScriptDir -replace '\\', '/' -replace '^([A-Za-z]):', '/mnt/$1'.ToLower()
$ShellScript = "{nome}.sh"

# Build arguments string
$WslArgs = @()
# Adicionar parâmetros conforme necessário
# if ($Param1) { $WslArgs += "--param1 `"$Param1`"" }

# Execute via WSL
$WslCommand = "cd '$WslScriptDir' && chmod +x '$ShellScript' && ./'$ShellScript' $($WslArgs -join ' ')"

try {
    wsl -d $distro -- bash -c $WslCommand
    $exitCode = $LASTEXITCODE
    
    if ($exitCode -eq 0) {
        Write-Host "✅ Done!" -ForegroundColor Green
    } else {
        Write-Host "❌ Script exited with code: $exitCode" -ForegroundColor Red
        exit $exitCode
    }
}
catch {
    Write-Host "❌ Error executing script: $_" -ForegroundColor Red
    exit 1
}
```

## Estratégias de Sincronização

| Estratégia | Descrição | Quando Usar |
|------------|-----------|-------------|
| `full-sync` | Manter lógica idêntica em ambos | Ferramentas com suporte nativo em ambas plataformas |
| `wrapper` | PS1 chama SH via WSL | Ferramenta só existe no Linux (ex: Docker Engine) |
| `platform-specific` | Sem contraparte | Ferramenta exclusiva de uma plataforma (ex: Azure CLI Windows) |

## Matriz de Sincronização

| Ação | PS1↔SH | README | .english-version |
|------|--------|--------|------------------|
| Novo script | ✓ Criar contraparte | ✓ Criar | ✅ **OBRIGATÓRIO** |
| Alterar parâmetros | ✓ Sincronizar | ✓ Atualizar | ✅ **OBRIGATÓRIO** |
| Alterar lógica | ✓ Sincronizar | ✓ Se funcional | ✅ **OBRIGATÓRIO** |
| Alterar mensagens | ✓ Sincronizar | ✗ Não necessário | ✅ **OBRIGATÓRIO** |

## Checklist Pós-Alteração

<checklist>
  - [ ] Contraparte existe? Se não, criar (full-sync ou wrapper)
  - [ ] Contraparte sincronizada com mudanças
  - [ ] README atualizado (se mudança funcional)
  - [ ] **OBRIGATÓRIO**: .english-version/ atualizado para TODOS os arquivos modificados
  - [ ] Mensagens/comentários traduzidos para EN
</checklist>

</skill>
