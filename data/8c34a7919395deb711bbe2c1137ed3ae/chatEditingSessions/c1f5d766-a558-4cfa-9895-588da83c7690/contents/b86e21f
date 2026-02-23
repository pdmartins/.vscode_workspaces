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

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Default values
SEARCH_PATH=""
OUTPUT_FILE=""

# Error handling
trap 'print_error "Error on line $LINENO"; exit 1' ERR

# ============================================================================
# Functions
# ============================================================================

show_help() {
    cat << EOF
Usage: $(basename "$0") [OPTIONS]

Searches for Git repositories in a folder and generates a script to clone the structure.

OPTIONS:
    -p, --path PATH      Root folder to search for repos (default: current directory)
    -o, --output FILE    Output file for the script (default: clone-repos.sh)
    -h, --help           Show this help

EXAMPLES:
    $(basename "$0") -p ~/projects
    $(basename "$0") -p /home/user/repos -o my-repos.sh

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
                print_error "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done
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
}

find_git_repos() {
    local search_path="$1"
    
    print_info "Searching for Git repositories in: $search_path"
    
    # Find all .git folders and return parent directory
    find "$search_path" -type d -name ".git" 2>/dev/null | while read -r git_dir; do
        dirname "$git_dir"
    done
}

get_repo_info() {
    local repo_path="$1"
    local remote_url=""
    local current_branch=""
    
    # Enter repo directory
    pushd "$repo_path" > /dev/null
    
    # Get origin remote URL
    remote_url=$(git remote get-url origin 2>/dev/null || echo "")
    
    # Get current branch
    current_branch=$(git branch --show-current 2>/dev/null || echo "main")
    
    popd > /dev/null
    
    echo "$remote_url|$current_branch"
}

generate_clone_script() {
    local search_path="$1"
    local output_file="$2"
    local repo_count=0
    
    print_step "Generating clone script..."
    
    # Script header
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

# ============================================================================
# Configuration
# ============================================================================

# Base folder where repos will be cloned (modify as needed)
BASE_DIR="${1:-$(pwd)}"

print_step "Cloning repositories to: $BASE_DIR"

# ============================================================================
# Clone Repositories
# ============================================================================

clone_repo() {
    local relative_path="$1"
    local remote_url="$2"
    local branch="$3"
    
    local target_dir="$BASE_DIR/$relative_path"
    
    if [[ -d "$target_dir/.git" ]]; then
        print_warning "Repo already exists: $relative_path"
        return 0
    fi
    
    print_info "Cloning: $relative_path"
    print_info "  URL: $remote_url"
    print_info "  Branch: $branch"
    
    mkdir -p "$(dirname "$target_dir")"
    
    if git clone --branch "$branch" "$remote_url" "$target_dir" 2>/dev/null; then
        print_success "Cloned: $relative_path"
    else
        # Try without specifying branch (in case branch doesn't exist on remote)
        if git clone "$remote_url" "$target_dir" 2>/dev/null; then
            print_warning "Cloned (default branch): $relative_path"
        else
            print_error "Failed to clone: $relative_path"
            return 1
        fi
    fi
}

HEADER

    # Add metadata
    echo "" >> "$output_file"
    echo "# Generated on: $(date '+%Y-%m-%d %H:%M:%S')" >> "$output_file"
    echo "# Original folder: $search_path" >> "$output_file"
    echo "" >> "$output_file"
    echo "# ============================================================================" >> "$output_file"
    echo "# Repositories" >> "$output_file"
    echo "# ============================================================================" >> "$output_file"
    echo "" >> "$output_file"

    # Process each repository
    while IFS= read -r repo_path; do
        [[ -z "$repo_path" ]] && continue
        
        local repo_info
        repo_info=$(get_repo_info "$repo_path")
        
        local remote_url="${repo_info%%|*}"
        local branch="${repo_info##*|}"
        
        # Path relative to search folder
        local relative_path="${repo_path#$search_path/}"
        
        if [[ -z "$remote_url" ]]; then
            print_warning "Repo without remote origin: $relative_path"
            echo "# WARNING: Local repo without remote - $relative_path" >> "$output_file"
            continue
        fi
        
        echo "clone_repo \"$relative_path\" \"$remote_url\" \"$branch\"" >> "$output_file"
        ((repo_count++))
        
        print_info "Found: $relative_path"
        echo "           Branch: $branch"
        
    done < <(find_git_repos "$search_path")

    # Script footer
    cat >> "$output_file" << 'FOOTER'

# ============================================================================
# Summary
# ============================================================================

print_success "Clone process completed!"
FOOTER

    # Make executable
    chmod +x "$output_file"
    
    echo "$repo_count"
}

# ============================================================================
# Main
# ============================================================================

main() {
    print_step "Git Repository Exporter"
    echo ""
    
    parse_arguments "$@"
    get_search_path
    get_output_file
    
    echo ""
    
    local count
    count=$(generate_clone_script "$SEARCH_PATH" "$OUTPUT_FILE")
    
    echo ""
    print_success "Script generated: $OUTPUT_FILE"
    print_success "Total repositories: $count"
    echo ""
    print_info "To use on another computer:"
    echo "    1. Copy the file '$OUTPUT_FILE' to the destination"
    echo "    2. Run: ./$OUTPUT_FILE [target_folder]"
}

main "$@"
