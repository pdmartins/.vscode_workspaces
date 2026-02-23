#!/bin/bash
set -euo pipefail

# ============================================================================
# Script: export-git-repos.sh
# Description: Procura repos Git em uma pasta, identifica remote/branch e gera
#              script para clonar a estrutura em outro computador
# ============================================================================

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'

# Helpers
print_info()    { echo -e "${CYAN}🔍 $1${NC}"; }
print_success() { echo -e "${GREEN}✅ $1${NC}"; }
print_warning() { echo -e "${YELLOW}⚠️ $1${NC}"; }
print_error()   { echo -e "${RED}❌ $1${NC}"; }
print_step()    { echo -e "${WHITE}🚀 $1${NC}"; }

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Default values
SEARCH_PATH=""
OUTPUT_FILE=""

# Error handling
trap 'print_error "Erro na linha $LINENO"; exit 1' ERR

# ============================================================================
# Functions
# ============================================================================

show_help() {
    cat << EOF
Uso: $(basename "$0") [OPÇÕES]

Procura repositórios Git em uma pasta e gera script para clonar a estrutura.

OPÇÕES:
    -p, --path PATH      Pasta raiz para buscar repos (padrão: diretório atual)
    -o, --output FILE    Arquivo de saída para o script (padrão: clone-repos.sh)
    -h, --help           Mostra esta ajuda

EXEMPLOS:
    $(basename "$0") -p ~/projetos
    $(basename "$0") -p /home/user/repos -o meus-repos.sh

EOF
}

parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -p|--path)
                SEARCH_PATH="$2"
                shift 2
                ;;
            -o|--output)
                OUTPUT_FILE="$2"
                shift 2
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            *)
                print_error "Opção desconhecida: $1"
                show_help
                exit 1
                ;;
        esac
    done
}

get_search_path() {
    if [[ -z "$SEARCH_PATH" ]]; then
        read -p "📁 Pasta raiz para buscar repos [$(pwd)]: " SEARCH_PATH
        SEARCH_PATH="${SEARCH_PATH:-$(pwd)}"
    fi
    
    # Expandir ~ e converter para path absoluto
    SEARCH_PATH=$(realpath -m "$SEARCH_PATH")
    
    if [[ ! -d "$SEARCH_PATH" ]]; then
        print_error "Pasta não encontrada: $SEARCH_PATH"
        exit 1
    fi
}

get_output_file() {
    if [[ -z "$OUTPUT_FILE" ]]; then
        read -p "📄 Nome do arquivo de saída [clone-repos.sh]: " OUTPUT_FILE
        OUTPUT_FILE="${OUTPUT_FILE:-clone-repos.sh}"
    fi
    
    # Garantir extensão .sh
    if [[ "$OUTPUT_FILE" != *.sh ]]; then
        OUTPUT_FILE="${OUTPUT_FILE}.sh"
    fi
}

find_git_repos() {
    local search_path="$1"
    
    print_info "Buscando repositórios Git em: $search_path"
    
    # Encontrar todas as pastas .git e retornar o diretório pai
    find "$search_path" -type d -name ".git" 2>/dev/null | while read -r git_dir; do
        dirname "$git_dir"
    done
}

get_repo_info() {
    local repo_path="$1"
    local remote_url=""
    local current_branch=""
    
    # Entrar no diretório do repo
    pushd "$repo_path" > /dev/null
    
    # Obter URL do remote origin
    remote_url=$(git remote get-url origin 2>/dev/null || echo "")
    
    # Obter branch atual
    current_branch=$(git branch --show-current 2>/dev/null || echo "main")
    
    popd > /dev/null
    
    echo "$remote_url|$current_branch"
}

generate_clone_script() {
    local search_path="$1"
    local output_file="$2"
    local repo_count=0
    
    print_step "Gerando script de clonagem..."
    
    # Cabeçalho do script
    cat > "$output_file" << 'HEADER'
#!/bin/bash
set -euo pipefail

# ============================================================================
# Script: clone-repos.sh (gerado automaticamente)
# Description: Clona repositórios Git mantendo estrutura de pastas original
# ============================================================================

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'

# Helpers
print_info()    { echo -e "${CYAN}🔍 $1${NC}"; }
print_success() { echo -e "${GREEN}✅ $1${NC}"; }
print_warning() { echo -e "${YELLOW}⚠️ $1${NC}"; }
print_error()   { echo -e "${RED}❌ $1${NC}"; }
print_step()    { echo -e "${WHITE}🚀 $1${NC}"; }

# ============================================================================
# Configuration
# ============================================================================

# Pasta base onde os repos serão clonados (modifique conforme necessário)
BASE_DIR="${1:-$(pwd)}"

print_step "Clonando repositórios para: $BASE_DIR"

# ============================================================================
# Clone Repositories
# ============================================================================

clone_repo() {
    local relative_path="$1"
    local remote_url="$2"
    local branch="$3"
    
    local target_dir="$BASE_DIR/$relative_path"
    
    if [[ -d "$target_dir/.git" ]]; then
        print_warning "Repo já existe: $relative_path"
        return 0
    fi
    
    print_info "Clonando: $relative_path"
    print_info "  URL: $remote_url"
    print_info "  Branch: $branch"
    
    mkdir -p "$(dirname "$target_dir")"
    
    if git clone --branch "$branch" "$remote_url" "$target_dir" 2>/dev/null; then
        print_success "Clonado: $relative_path"
    else
        # Tentar sem especificar branch (caso a branch não exista no remote)
        if git clone "$remote_url" "$target_dir" 2>/dev/null; then
            print_warning "Clonado (branch padrão): $relative_path"
        else
            print_error "Falha ao clonar: $relative_path"
            return 1
        fi
    fi
}

HEADER

    # Adicionar metadados
    echo "" >> "$output_file"
    echo "# Gerado em: $(date '+%Y-%m-%d %H:%M:%S')" >> "$output_file"
    echo "# Pasta original: $search_path" >> "$output_file"
    echo "" >> "$output_file"
    echo "# ============================================================================" >> "$output_file"
    echo "# Repositories" >> "$output_file"
    echo "# ============================================================================" >> "$output_file"
    echo "" >> "$output_file"

    # Processar cada repositório
    while IFS= read -r repo_path; do
        [[ -z "$repo_path" ]] && continue
        
        local repo_info
        repo_info=$(get_repo_info "$repo_path")
        
        local remote_url="${repo_info%%|*}"
        local branch="${repo_info##*|}"
        
        # Caminho relativo à pasta de busca
        local relative_path="${repo_path#$search_path/}"
        
        if [[ -z "$remote_url" ]]; then
            print_warning "Repo sem remote origin: $relative_path"
            echo "# AVISO: Repo local sem remote - $relative_path" >> "$output_file"
            continue
        fi
        
        echo "clone_repo \"$relative_path\" \"$remote_url\" \"$branch\"" >> "$output_file"
        ((repo_count++))
        
        print_info "Encontrado: $relative_path"
        echo "           Branch: $branch"
        
    done < <(find_git_repos "$search_path")

    # Footer do script
    cat >> "$output_file" << 'FOOTER'

# ============================================================================
# Summary
# ============================================================================

print_success "Processo de clonagem concluído!"
FOOTER

    # Tornar executável
    chmod +x "$output_file"
    
    echo "$repo_count"
}

# ============================================================================
# Main
# ============================================================================

main() {
    print_step "Exportador de Repositórios Git"
    echo ""
    
    parse_arguments "$@"
    get_search_path
    get_output_file
    
    echo ""
    
    local count
    count=$(generate_clone_script "$SEARCH_PATH" "$OUTPUT_FILE")
    
    echo ""
    print_success "Script gerado: $OUTPUT_FILE"
    print_success "Total de repositórios: $count"
    echo ""
    print_info "Para usar em outro computador:"
    echo "    1. Copie o arquivo '$OUTPUT_FILE' para o destino"
    echo "    2. Execute: ./$OUTPUT_FILE [pasta_destino]"
}

main "$@"
