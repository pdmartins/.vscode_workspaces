#!/bin/bash
set -euo pipefail

# ============================================================================
# Script: export-git-repos.sh
# Description: Searches for Git repos in a folder, identifies remote/branch
#              and generates a script to clone the structure on another computer
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
trap 'print_error "Error on line $LINENO"; exit 1' ERR

# ============================================================================
# Functions
# ============================================================================

show_usage() {
    echo "Usage: $0 [options]"
    echo ""
    echo "Options:"
    echo "  -p, --path PATH      Root folder to search for repos (default: current directory)"
    echo "  -o, --output FILE    Output file for the script (default: clone-repos.sh)"
    echo "  -h, --help           Show this help"
    echo ""
    echo "Examples:"
    echo "  $0 -p ~/projects"
    echo "  $0 -p /home/user/repos -o my-repos.sh"
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
                print_error "Unknown option: $1"
                show_usage
                exit 1
                ;;
        esac
    done
}

check_prerequisites() {
    print_info "Checking prerequisites..."
    
    if ! command -v git &>/dev/null; then
        print_error "Git not found. Please install Git first."
        exit 1
    fi
    
    if ! command -v find &>/dev/null; then
        print_error "find not found."
        exit 1
    fi
    
    print_success "Prerequisites OK"
}

get_search_path() {
    if [[ -z "$SEARCH_PATH" ]]; then
        read -p "📁 Root folder to search for repos [$(pwd)]: " SEARCH_PATH
        SEARCH_PATH="${SEARCH_PATH:-$(pwd)}"
    fi
    
    # Expand ~ and convert to absolute path
    SEARCH_PATH=$(realpath -m "$SEARCH_PATH")
    
    if [[ ! -d "$SEARCH_PATH" ]]; then
        print_error "Folder not found: $SEARCH_PATH"
        exit 1
    fi
    
    print_info "Search folder: $SEARCH_PATH"
}

get_output_file() {
    if [[ -z "$OUTPUT_FILE" ]]; then
        read -p "📄 Output file name [clone-repos.sh]: " OUTPUT_FILE
        OUTPUT_FILE="${OUTPUT_FILE:-clone-repos.sh}"
    fi
    
    # Ensure .sh extension
    if [[ "$OUTPUT_FILE" != *.sh ]]; then
        OUTPUT_FILE="${OUTPUT_FILE}.sh"
    fi
    
    print_info "Output file: $OUTPUT_FILE"
}

get_repo_info() {
    local repo_path="$1"
    local remote_url=""
    local current_branch=""
    
    # Save current directory
    local original_dir="$PWD"
    
    # Enter repo directory
    cd "$repo_path"
    
    # Get origin remote URL
    remote_url=$(git remote get-url origin 2>/dev/null || echo "")
    
    # Get current branch
    current_branch=$(git branch --show-current 2>/dev/null || echo "")
    
    # If no current branch, try to get HEAD
    if [[ -z "$current_branch" ]]; then
        current_branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "main")
    fi
    
    # Return to original directory
    cd "$original_dir"
    
    echo "$remote_url|$current_branch"
}

find_all_repos() {
    local search_path="$1"
    
    print_step "Searching for Git repositories recursively..."
    echo ""
    
    # Use mapfile to capture all results correctly
    local git_dirs=()
    while IFS= read -r -d '' git_dir; do
        git_dirs+=("$(dirname "$git_dir")")
    done < <(find "$search_path" -type d -name ".git" -print0 2>/dev/null)
    
    local total=${#git_dirs[@]}
    print_info "Found $total Git repositories"
    echo ""
    
    # Process each repository
    local current=0
    for repo_path in "${git_dirs[@]}"; do
        ((current++))
        
        # Path relative to search folder
        local relative_path="${repo_path#$search_path/}"
        
        # Get repo info
        local repo_info
        repo_info=$(get_repo_info "$repo_path")
        
        local remote_url="${repo_info%%|*}"
        local branch="${repo_info##*|}"
        
        echo -e "${CYAN}[$current/$total]${NC} $relative_path"
        
        if [[ -z "$remote_url" ]]; then
            print_warning "  └── No remote origin (skipped)"
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
    print_step "Generating clone script..."
    
    # Generated script header
    cat > "$output_file" << 'HEADER'
#!/bin/bash
set -euo pipefail

# ============================================================================
# Script: clone-repos.sh (auto-generated)
# Description: Clones Git repositories preserving original folder structure
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
        print_warning "Repo already exists: $relative_path"
        REPOS_SKIPPED+=("$relative_path")
        return 0
    fi
    
    print_install "Cloning: $relative_path"
    echo "  ├── URL: $remote_url"
    echo "  └── Branch: $branch"
    
    # Create parent folder if it doesn't exist
    mkdir -p "$(dirname "$target_dir")"
    
    # Try to clone with specific branch
    if git clone --branch "$branch" "$remote_url" "$target_dir" 2>/dev/null; then
        print_success "Cloned: $relative_path"
        REPOS_CLONED+=("$relative_path")
    else
        # Try without specific branch
        if git clone "$remote_url" "$target_dir" 2>/dev/null; then
            print_warning "Cloned (default branch): $relative_path"
            REPOS_CLONED+=("$relative_path")
        else
            print_error "Failed to clone: $relative_path"
            REPOS_FAILED+=("$relative_path")
            return 1
        fi
    fi
}

show_summary() {
    echo ""
    echo "============================================================================"
    echo " Summary"
    echo "============================================================================"
    
    if [[ ${#REPOS_CLONED[@]} -gt 0 ]]; then
        print_success "Cloned: ${#REPOS_CLONED[@]}"
    fi
    
    if [[ ${#REPOS_SKIPPED[@]} -gt 0 ]]; then
        print_warning "Already existing: ${#REPOS_SKIPPED[@]}"
    fi
    
    if [[ ${#REPOS_FAILED[@]} -gt 0 ]]; then
        print_error "Failed: ${#REPOS_FAILED[@]}"
        for repo in "${REPOS_FAILED[@]}"; do
            echo "  - $repo"
        done
    fi
}

# ============================================================================
# Main
# ============================================================================

main() {
    print_step "Cloning repositories to: $BASE_DIR"
    echo ""

HEADER

    # Add metadata
    echo "# Generated on: $(date '+%Y-%m-%d %H:%M:%S')" >> "$output_file"
    echo "# Original folder: $SEARCH_PATH" >> "$output_file"
    echo "# Total repositories: ${#REPOS_FOUND[@]}" >> "$output_file"
    echo "" >> "$output_file"
    
    # Add clone calls for each repo
    for repo_data in "${REPOS_FOUND[@]}"; do
        local relative_path="${repo_data%%|*}"
        local temp="${repo_data#*|}"
        local remote_url="${temp%%|*}"
        local branch="${temp##*|}"
        
        echo "    clone_repo \"$relative_path\" \"$remote_url\" \"$branch\"" >> "$output_file"
    done
    
    # Script footer
    cat >> "$output_file" << 'FOOTER'

    show_summary
}

main
FOOTER

    # Make executable
    chmod +x "$output_file"
}

show_summary() {
    echo ""
    echo "============================================================================"
    echo " Summary"
    echo "============================================================================"
    
    print_success "Repositories found: ${#REPOS_FOUND[@]}"
    
    if [[ ${#REPOS_NO_REMOTE[@]} -gt 0 ]]; then
        print_warning "No remote (skipped): ${#REPOS_NO_REMOTE[@]}"
        for repo in "${REPOS_NO_REMOTE[@]}"; do
            echo "  - $repo"
        done
    fi
    
    echo ""
    print_success "Script generated: $OUTPUT_FILE"
    echo ""
    print_info "To use on another computer:"
    echo "    1. Copy the file '$OUTPUT_FILE' to the destination"
    echo "    2. Run: ./$OUTPUT_FILE [target_folder]"
}

# ============================================================================
# Main
# ============================================================================

main() {
    print_step "Git Repository Exporter"
    echo ""
    
    parse_arguments "$@"
    check_prerequisites
    get_search_path
    get_output_file
    echo ""
    
    find_all_repos "$SEARCH_PATH"
    
    if [[ ${#REPOS_FOUND[@]} -eq 0 ]]; then
        print_warning "No repository with remote origin found."
        exit 0
    fi
    
    generate_clone_script "$OUTPUT_FILE"
    show_summary
}

main "$@"
