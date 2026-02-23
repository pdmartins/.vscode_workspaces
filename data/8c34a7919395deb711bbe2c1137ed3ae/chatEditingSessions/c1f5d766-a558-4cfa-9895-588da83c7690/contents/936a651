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
print_install() { echo -e "${YELLOW}📦 $1${NC}"; }
print_update()  { echo -e "${CYAN}🔄 $1${NC}"; }

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Default values
SEARCH_PATH=""
OUTPUT_FILE=""

# Tracking arrays
REPOS_FOUND=()
REPOS_NO_REMOTE=()

# Error handling
trap 'print_error "Erro na linha $LINENO"; exit 1' ERR

# ============================================================================
# Functions
# ============================================================================

show_usage() {
    echo "Uso: $0 [opções]"
    echo ""
    echo "Opções:"
    echo "  -p, --path PATH      Pasta raiz para buscar repos (padrão: diretório atual)"
    echo "  -o, --output FILE    Arquivo de saída para o script (padrão: clone-repos.sh)"
    echo "  -h, --help           Mostra esta ajuda"
    echo ""
    echo "Exemplos:"
    echo "  $0 -p ~/projetos"
    echo "  $0 -p /home/user/repos -o meus-repos.sh"
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
                show_usage
                exit 0
                ;;
            *)
                print_error "Opção desconhecida: $1"
                show_usage
                exit 1
                ;;
        esac
    done
}

check_prerequisites() {
    print_info "Verificando pré-requisitos..."
    
    if ! command -v git &>/dev/null; then
        print_error "Git não encontrado. Instale o Git primeiro."
        exit 1
    fi
    
    if ! command -v find &>/dev/null; then
        print_error "find não encontrado."
        exit 1
    fi
    
    print_success "Pré-requisitos OK"
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
    
    print_info "Pasta de busca: $SEARCH_PATH"
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
    
    print_info "Arquivo de saída: $OUTPUT_FILE"
}

get_repo_info() {
    local repo_path="$1"
    local remote_url=""
    local current_branch=""
    
    # Salvar diretório atual
    local original_dir="$PWD"
    
    # Entrar no diretório do repo
    cd "$repo_path"
    
    # Obter URL do remote origin
    remote_url=$(git remote get-url origin 2>/dev/null || echo "")
    
    # Obter branch atual
    current_branch=$(git branch --show-current 2>/dev/null || echo "")
    
    # Se não tem branch atual, tentar pegar a HEAD
    if [[ -z "$current_branch" ]]; then
        current_branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "main")
    fi
    
    # Voltar ao diretório original
    cd "$original_dir"
    
    echo "$remote_url|$current_branch"
}

find_all_repos() {
    local search_path="$1"
    
    print_step "Buscando repositórios Git recursivamente..."
    echo ""
    
    # Usar mapfile para capturar todos os resultados corretamente
    local git_dirs=()
    while IFS= read -r -d '' git_dir; do
        git_dirs+=("$(dirname "$git_dir")")
    done < <(find "$search_path" -type d -name ".git" -print0 2>/dev/null)
    
    local total=${#git_dirs[@]}
    print_info "Encontrados $total repositórios Git"
    echo ""
    
    # Processar cada repositório
    local current=0
    for repo_path in "${git_dirs[@]}"; do
        ((current++))
        
        # Caminho relativo à pasta de busca
        local relative_path="${repo_path#$search_path/}"
        
        # Obter informações do repo
        local repo_info
        repo_info=$(get_repo_info "$repo_path")
        
        local remote_url="${repo_info%%|*}"
        local branch="${repo_info##*|}"
        
        echo -e "${CYAN}[$current/$total]${NC} $relative_path"
        
        if [[ -z "$remote_url" ]]; then
            print_warning "  └── Sem remote origin (ignorado)"
            REPOS_NO_REMOTE+=("$relative_path")
        else
            echo "  ├── Remote: $remote_url"
            echo "  └── Branch: $branch"
            REPOS_FOUND+=("$relative_path|$remote_url|$branch")
        fi
    done
}

generate_clone_script() {
    local output_file="$1"
    
    echo ""
    print_step "Gerando script de clonagem..."
    
    # Cabeçalho do script gerado
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
print_install() { echo -e "${YELLOW}📦 $1${NC}"; }
print_update()  { echo -e "${CYAN}🔄 $1${NC}"; }

# Tracking
REPOS_CLONED=()
REPOS_SKIPPED=()
REPOS_FAILED=()

# ============================================================================
# Configuration
# ============================================================================

BASE_DIR="${1:-$(pwd)}"

# ============================================================================
# Functions
# ============================================================================

clone_repo() {
    local relative_path="$1"
    local remote_url="$2"
    local branch="$3"
    
    local target_dir="$BASE_DIR/$relative_path"
    
    if [[ -d "$target_dir/.git" ]]; then
        print_warning "Repo já existe: $relative_path"
        REPOS_SKIPPED+=("$relative_path")
        return 0
    fi
    
    print_install "Clonando: $relative_path"
    echo "  ├── URL: $remote_url"
    echo "  └── Branch: $branch"
    
    # Criar pasta pai se não existir
    mkdir -p "$(dirname "$target_dir")"
    
    # Tentar clonar com branch específica
    if git clone --branch "$branch" "$remote_url" "$target_dir" 2>/dev/null; then
        print_success "Clonado: $relative_path"
        REPOS_CLONED+=("$relative_path")
    else
        # Tentar sem branch específica
        if git clone "$remote_url" "$target_dir" 2>/dev/null; then
            print_warning "Clonado (branch padrão): $relative_path"
            REPOS_CLONED+=("$relative_path")
        else
            print_error "Falha ao clonar: $relative_path"
            REPOS_FAILED+=("$relative_path")
            return 1
        fi
    fi
}

show_summary() {
    echo ""
    echo "============================================================================"
    echo " Resumo"
    echo "============================================================================"
    
    if [[ ${#REPOS_CLONED[@]} -gt 0 ]]; then
        print_success "Clonados: ${#REPOS_CLONED[@]}"
    fi
    
    if [[ ${#REPOS_SKIPPED[@]} -gt 0 ]]; then
        print_warning "Já existentes: ${#REPOS_SKIPPED[@]}"
    fi
    
    if [[ ${#REPOS_FAILED[@]} -gt 0 ]]; then
        print_error "Falhas: ${#REPOS_FAILED[@]}"
        for repo in "${REPOS_FAILED[@]}"; do
            echo "  - $repo"
        done
    fi
}

# ============================================================================
# Main
# ============================================================================

main() {
    print_step "Clonando repositórios para: $BASE_DIR"
    echo ""

HEADER

    # Adicionar metadados
    echo "# Gerado em: $(date '+%Y-%m-%d %H:%M:%S')" >> "$output_file"
    echo "# Pasta original: $SEARCH_PATH" >> "$output_file"
    echo "# Total de repositórios: ${#REPOS_FOUND[@]}" >> "$output_file"
    echo "" >> "$output_file"
    
    # Adicionar chamadas de clone para cada repo
    for repo_data in "${REPOS_FOUND[@]}"; do
        local relative_path="${repo_data%%|*}"
        local temp="${repo_data#*|}"
        local remote_url="${temp%%|*}"
        local branch="${temp##*|}"
        
        echo "    clone_repo \"$relative_path\" \"$remote_url\" \"$branch\"" >> "$output_file"
    done
    
    # Footer do script
    cat >> "$output_file" << 'FOOTER'

    show_summary
}

main
FOOTER

    # Tornar executável
    chmod +x "$output_file"
}

show_summary() {
    echo ""
    echo "============================================================================"
    echo " Resumo"
    echo "============================================================================"
    
    print_success "Repositórios encontrados: ${#REPOS_FOUND[@]}"
    
    if [[ ${#REPOS_NO_REMOTE[@]} -gt 0 ]]; then
        print_warning "Sem remote (ignorados): ${#REPOS_NO_REMOTE[@]}"
        for repo in "${REPOS_NO_REMOTE[@]}"; do
            echo "  - $repo"
        done
    fi
    
    echo ""
    print_success "Script gerado: $OUTPUT_FILE"
    echo ""
    print_info "Para usar em outro computador:"
    echo "    1. Copie o arquivo '$OUTPUT_FILE' para o destino"
    echo "    2. Execute: ./$OUTPUT_FILE [pasta_destino]"
}

# ============================================================================
# Main
# ============================================================================

main() {
    print_step "Exportador de Repositórios Git"
    echo ""
    
    parse_arguments "$@"
    check_prerequisites
    get_search_path
    get_output_file
    echo ""
    
    find_all_repos "$SEARCH_PATH"
    
    if [[ ${#REPOS_FOUND[@]} -eq 0 ]]; then
        print_warning "Nenhum repositório com remote origin encontrado."
        exit 0
    fi
    
    generate_clone_script "$OUTPUT_FILE"
    show_summary
}

main "$@"
