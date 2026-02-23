# GitHub Copilot Instructions

Este arquivo contém instruções para o GitHub Copilot sobre como criar e manter scripts neste repositório.

## 📋 Visão Geral do Projeto

Este é um repositório de scripts utilitários para automação de tarefas de desenvolvimento e configuração de ambiente. Os scripts são projetados para serem:

- **Idempotentes**: Podem ser executados múltiplas vezes sem causar efeitos colaterais
- **Bilíngues**: Versão em português (raiz) e inglês (.english-version)
- **Multiplataforma**: PowerShell para Windows, Bash para Linux/macOS

## 🏗️ Estrutura do Projeto

```
scripts/
├── README.md                    # README principal (português)
├── .github/
│   └── copilot-instructions.md  # Este arquivo
├── .english-version/            # Versão em inglês
│   ├── README.md
│   ├── azure/
│   ├── docker/
│   ├── oh-my-posh/
│   └── ssh/
├── azure/                       # Scripts Azure
│   ├── README.md
│   └── *.ps1
├── docker/                      # Scripts Docker
│   ├── README.md
│   ├── *.ps1
│   └── *.sh
├── oh-my-posh/                  # Scripts Oh My Posh
│   ├── README.md
│   ├── *.ps1
│   └── *.sh
└── ssh/                         # Scripts SSH
    ├── README.md
    ├── *.ps1
    └── *.sh
```

## 📝 Padrões de Código

### PowerShell (.ps1)

```powershell
# Cabeçalho do script
# Script para [descrição do que faz]
# Autor: [nome]
# Data: [YYYY-MM-DD]

# Cores para output (usar -ForegroundColor)
# Cyan    = Títulos e informações principais
# Yellow  = Avisos e ações em progresso
# Green   = Sucesso
# Red     = Erros
# White   = Informações secundárias
# Gray    = Prompts e textos auxiliares

# Emojis padronizados
# 🔍 = Verificando/Buscando
# 📦 = Instalando/Pacote
# ✅ = Sucesso
# ❌ = Erro
# ⚠️ = Aviso
# 💡 = Dica
# 🔄 = Atualizando
# 🚀 = Iniciando/Executando
# 📁 = Diretório/Pasta
# 🔐 = Segurança/Chave
# 🐳 = Docker
# ☁️ = Cloud/Azure
# 🎨 = Tema/Visual

# Estrutura de verificação idempotente
if (Test-Condition) {
    Write-Host "✅ Já está configurado" -ForegroundColor Green
} else {
    Write-Host "📦 Instalando..." -ForegroundColor Yellow
    # código de instalação
}

# Tratamento de erros
try {
    # código
    Write-Host "✅ Operação concluída!" -ForegroundColor Green
} catch {
    Write-Host "❌ Erro: $_" -ForegroundColor Red
    exit 1
}
```

### Bash (.sh)

```bash
#!/bin/bash
# Script para [descrição do que faz]
# Autor: [nome]
# Data: [YYYY-MM-DD]

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
GRAY='\033[0;90m'
NC='\033[0m' # No Color

# Funções auxiliares (recomendado)
print_success() { echo -e "${GREEN}✅ $1${NC}"; }
print_error() { echo -e "${RED}❌ $1${NC}"; }
print_warning() { echo -e "${YELLOW}⚠️ $1${NC}"; }
print_info() { echo -e "${CYAN}$1${NC}"; }

# Estrutura de verificação idempotente
if command -v tool &>/dev/null; then
    print_success "Já está instalado"
else
    print_info "📦 Instalando..."
    # código de instalação
fi

# Estrutura principal com funções
main() {
    check_prerequisites
    install_tool
    configure_tool
    verify_installation
}

main "$@"
```

## 🔧 Diretrizes para Novos Scripts

### 1. Idempotência

Todo script DEVE ser idempotente. Sempre verificar o estado atual antes de fazer alterações:

```powershell
# PowerShell
if (-not (Test-Path $path)) {
    # criar arquivo/pasta
}

if (-not (Get-Command tool -ErrorAction SilentlyContinue)) {
    # instalar ferramenta
}
```

```bash
# Bash
if [[ ! -f "$path" ]]; then
    # criar arquivo
fi

if ! command -v tool &>/dev/null; then
    # instalar ferramenta
fi
```

### 2. Interatividade

Scripts devem funcionar com parâmetros OU interativamente:

```powershell
# PowerShell - aceitar parâmetro ou solicitar
param([string]$Email)

if ([string]::IsNullOrWhiteSpace($Email)) {
    $Email = Read-Host "📧 Digite o email"
}
```

```bash
# Bash - aceitar argumento ou solicitar
email="$1"

if [[ -z "$email" ]]; then
    read -p "📧 Enter email: " email
fi
```

### 3. Feedback Visual

Sempre fornecer feedback claro sobre o que está acontecendo:

- Usar emojis consistentes
- Usar cores apropriadas (verde=sucesso, vermelho=erro, amarelo=aviso)
- Mostrar progresso em operações longas
- Exibir resumo ao final

### 4. Documentação

Cada pasta DEVE ter um README.md com:

- Descrição dos scripts
- Parâmetros/argumentos aceitos
- Exemplos de uso
- Requisitos/dependências

### 5. Bilinguismo

Para cada script em português na raiz, deve existir uma versão equivalente em inglês na pasta `.english-version/`:

- Mesma funcionalidade
- Mensagens traduzidas
- README traduzido

## 📐 Convenções de Nomenclatura

- **Arquivos**: `verbo-substantivo.ps1` ou `verbo-substantivo.sh`
  - Exemplos: `install-docker.ps1`, `generate-ssh-key.sh`
- **Funções PowerShell**: `Verb-Noun` (PascalCase)
  - Exemplos: `Test-Administrator`, `Resolve-ExistingKey`
- **Funções Bash**: `snake_case`
  - Exemplos: `check_privileges`, `install_docker`
- **Variáveis PowerShell**: `$PascalCase`
- **Variáveis Bash**: `snake_case` ou `UPPER_CASE` para constantes

## ✅ Checklist para Novos Scripts

- [ ] Script é idempotente
- [ ] Verifica pré-requisitos (permissões, dependências)
- [ ] Usa cores e emojis consistentes
- [ ] Fornece feedback de progresso
- [ ] Trata erros apropriadamente
- [ ] Tem versão em português e inglês
- [ ] README da pasta está atualizado
- [ ] Funciona com parâmetros e interativamente

## 🔄 Manutenção

Ao atualizar um script:

1. Atualizar AMBAS as versões (português e inglês)
2. Manter a paridade de funcionalidades
3. Atualizar READMEs se necessário
4. Testar em ambiente limpo (fresh install)
