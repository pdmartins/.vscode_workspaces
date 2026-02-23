# Cross-Platform Rules

<rules id="cross-platform" critical="true">

## Regra Fundamental

<rule>
  TODO script DEVE ter versão Linux (.sh) E Windows (.ps1).
  Se não existir solução nativa para uma plataforma, criar WRAPPER WSL.
</rule>

## Estratégias de Sincronização

| Estratégia | Quando Usar | Exemplo |
|------------|-------------|---------|
| `full-sync` | Ambas plataformas têm solução nativa | docker/, ssh/ |
| `wrapper` | Linux-only, Windows via WSL | - |
| `platform-specific` | Só existe para uma plataforma | azure/ (Windows-only) |

## WSL Wrapper Template

Quando não existir solução nativa para Windows, criar wrapper que executa via WSL:

```powershell
<#
.SYNOPSIS
    WSL Wrapper para {script-name}
.DESCRIPTION
    Executa a versão Linux do script via WSL.
    Requer WSL instalado e configurado.
#>

param(
    # Parâmetros do script original
)

# Verificar WSL
if (-not (Get-Command wsl -ErrorAction SilentlyContinue)) {
    Write-Host "❌ WSL não está instalado" -ForegroundColor Red
    Write-Host "   Instale com: wsl --install" -ForegroundColor Yellow
    exit 1
}

# Converter path do script
$ScriptDir = $PSScriptRoot
$WslPath = wsl wslpath -u ($ScriptDir -replace '\\', '/')
$ShScript = "{script-name}.sh"

# Executar via WSL
Write-Host "🚀 Executando via WSL..." -ForegroundColor Cyan
wsl bash -c "cd '$WslPath' && ./$ShScript $args"
```

## Workflow de Sincronização

<workflow id="cross-platform-sync">
  <step n="1" goal="Identificar estratégia">
    <action>Verificar se existe solução nativa para ambas plataformas</action>
    
    <check if="solução nativa existe para ambas">
      <action>Usar estratégia full-sync</action>
    </check>
    
    <check if="solução existe só para Linux">
      <action>Criar wrapper WSL para Windows</action>
    </check>
    
    <check if="solução existe só para Windows">
      <action>Documentar como platform-specific</action>
    </check>
  </step>

  <step n="2" goal="Sincronizar scripts">
    <check if="full-sync">
      <action>Manter lógica equivalente em ambos</action>
      <action>Sincronizar parâmetros, output, comportamento</action>
    </check>
    
    <check if="wrapper">
      <action>Criar .ps1 que chama .sh via WSL</action>
      <action>Documentar requisito de WSL no README</action>
    </check>
  </step>
</workflow>

## Exceções

Consultar `project-structure.md` para lista de exceções atuais.

</rules>
