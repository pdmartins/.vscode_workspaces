---
applyTo: '**'
---
# Copilot Instructions

<rules>
  <rule id="language">
    <chat>Português brasileiro</chat>
    <code>Inglês (variáveis, funções, parâmetros, nomes de arquivo)</code>
  </rule>
  
  <rule id="no-auto-docs">
    NUNCA crie arquivos markdown/logs para documentar atividades automaticamente.
    Apenas crie/atualize quando explicitamente solicitado.
  </rule>
</rules>

## Projeto

Scripts utilitários de automação — idempotentes, bilíngues (PT na raiz, EN em `.english-version/`), multiplataforma.

<structure>
scripts/
├── .github/instructions/     # Instruções Copilot
│   └── directives/           # Diretivas específicas
├── .english-version/         # Versão inglês
├── azure/                    # Scripts Azure
├── docker/                   # Scripts Docker  
├── oh-my-posh/              # Scripts Oh My Posh
└── ssh/                      # Scripts SSH
</structure>

## Nomenclatura

| Tipo | Padrão | Exemplo |
|------|--------|---------|
| Arquivos | `verbo-substantivo.{ps1,sh}` | `install-docker.ps1` |
| Funções PS | `Verb-Noun` | `Test-Administrator` |
| Funções Bash | `snake_case` | `check_privileges` |
| Variáveis PS | `$PascalCase` | `$UserProfile` |
| Variáveis Bash | `snake_case` / `UPPER_CASE` | `user_home` / `RED` |

## Emojis & Cores

| Emoji | Uso | Cor PS | Cor Bash |
|-------|-----|--------|----------|
| 🔍 | Verificando | Cyan | `\033[0;36m` |
| 📦 | Instalando | Yellow | `\033[1;33m` |
| ✅ | Sucesso | Green | `\033[0;32m` |
| ❌ | Erro | Red | `\033[0;31m` |
| ⚠️ | Aviso | Yellow | `\033[1;33m` |
| 🔄 | Atualizando | Cyan | `\033[0;36m` |
| 🚀 | Executando | White | `\033[1;37m` |

## Regras de Código

<when condition="criando/editando script">
  <do>
    - Verificar estado antes de alterar (idempotência)
    - Aceitar parâmetros OU solicitar interativamente
    - Fornecer feedback visual com emojis e cores
    - Tratar erros com try/catch ou set -e
  </do>
</when>

<when condition="script em português (raiz)">
  <do>Criar/atualizar versão equivalente em `.english-version/`</do>
</when>

<when condition="nova pasta de scripts">
  <do>Criar README.md com: descrição, parâmetros, exemplos, requisitos</do>
</when>

## Segurança

<forbidden>
  - Senhas, tokens, API keys
  - IDs de tenant/subscription/recursos
  - Paths absolutos: `C:\Users\...`, `D:\Repos\...`, `/home/...`
  - URLs hardcoded de repos específicos
</forbidden>

<safe-paths>
  <powershell>$env:USERPROFILE, $env:APPDATA, $env:TEMP, $PSScriptRoot</powershell>
  <bash>$HOME, $XDG_CONFIG_HOME, /tmp, ${BASH_SOURCE[0]}</bash>
</safe-paths>

## Checklist

<checklist context="novo-script">
  - [ ] Idempotente
  - [ ] Verifica pré-requisitos
  - [ ] Cores e emojis consistentes
  - [ ] Feedback de progresso
  - [ ] Tratamento de erros
  - [ ] Versão PT e EN
  - [ ] README atualizado
  - [ ] Sem dados sensíveis
  - [ ] Sem paths absolutos
</checklist>

