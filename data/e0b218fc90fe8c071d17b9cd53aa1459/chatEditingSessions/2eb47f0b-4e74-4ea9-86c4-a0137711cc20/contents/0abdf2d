---
applyTo: '**/*.sh'
---
# Bash Script Directives

## Template Base

```bash
#!/bin/bash
set -euo pipefail

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# Helpers
print_info()    { echo -e "${CYAN}$1${NC}"; }
print_success() { echo -e "${GREEN}✅ $1${NC}"; }
print_warning() { echo -e "${YELLOW}⚠️ $1${NC}"; }
print_error()   { echo -e "${RED}❌ $1${NC}"; }

# Diretório do script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
```

## Padrões de Idempotência

```bash
# Verificar comando existe
if ! command -v tool &>/dev/null; then
    # instalar
fi

# Verificar arquivo existe
if [[ ! -f "$path" ]]; then
    # criar
fi

# Verificar diretório existe
if [[ ! -d "$path" ]]; then
    mkdir -p "$path"
fi
```

## Argumentos Interativos

```bash
param="${1:-}"

if [[ -z "$param" ]]; then
    read -p "📝 Digite valor: " param
fi
```

## Tratamento de Erros

```bash
# Com trap
trap 'print_error "Erro na linha $LINENO"; exit 1' ERR

# Ou manual
if ! some_command; then
    print_error "Falhou ao executar"
    exit 1
fi
```

## Estrutura Main

```bash
main() {
    check_prerequisites
    install_tool
    configure
    verify
}

main "$@"
```

## Detecção de OS

```bash
detect_os() {
    case "$(uname -s)" in
        Linux*)  echo "linux" ;;
        Darwin*) echo "macos" ;;
        *)       echo "unknown" ;;
    esac
}
```
