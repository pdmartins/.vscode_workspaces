# Conventions

<conventions id="scripts-conventions">

## Nomenclatura

| Tipo | Padrão | Exemplo |
|------|--------|---------|
| Arquivos | `verbo-substantivo.{ext}` | `install-docker.ps1` |
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
| 📋 | Lista criada | - | - |
| 📝 | Documentando | - | - |
| 📄 | Arquivo criado | - | - |

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

## Checklist Obrigatório

<checklist context="qualquer-script" execute="always">
  - [ ] Idempotente
  - [ ] Verifica pré-requisitos
  - [ ] Cores e emojis consistentes
  - [ ] Feedback de progresso
  - [ ] Tratamento de erros
  - [ ] Versão PT e EN
  - [ ] README da pasta existe e atualizado
  - [ ] Sem dados sensíveis
  - [ ] Sem paths absolutos
</checklist>

</conventions>
