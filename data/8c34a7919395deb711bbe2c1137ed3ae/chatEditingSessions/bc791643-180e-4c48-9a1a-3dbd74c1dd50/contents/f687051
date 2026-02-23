#!/bin/bash
set -euo pipefail

# ============================================================================
# Script: clone-devops-repos.sh
# Description: Clone all repositories from an Azure DevOps project
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
CONFIG_FILE="${SCRIPT_DIR}/config.json"

# Default values
ORGANIZATION_URL=""
PROJECT=""
USERNAME=""
PAT=""
CLONE_PATH=""

# Tracking arrays
REPOS_CLONED=()
REPOS_UPDATED=()
REPOS_STASHED=()
REPOS_FAILED=()

# Error handling
trap 'print_error "Error on line $LINENO"; exit 1' ERR

# ============================================================================
# Functions
# ============================================================================

show_usage() {
    echo "Usage: $0 [options]"
    echo ""
    echo "Options:"
    echo "  -o, --org URL            Azure DevOps organization URL"
    echo "  -p, --project NAME       Project name"
    echo "  -u, --username USER      Username"
    echo "  -t, --pat TOKEN          Personal Access Token"
    echo "  -d, --destination PATH   Destination folder (default: ./repos)"
    echo "  -c, --config FILE        JSON configuration file"
    echo "  -h, --help               Show this help"
    echo ""
    echo "Config file example (config.json):"
    echo '{'
    echo '  "organization_url": "https://dev.azure.com/your-org",'
    echo '  "project": "project-name",'
    echo '  "username": "your-username",'
    echo '  "pat": "your-personal-access-token",'
    echo '  "clone_path": "./repos"'
    echo '}'
}

load_config() {
    local config_path="$1"
    
    if [[ ! -f "$config_path" ]]; then
        return 1
    fi
    
    print_info "Loading configuration from: $config_path"
    
    # Check if jq is available
    if ! command -v jq &>/dev/null; then
        print_error "jq not found. Install with: sudo apt install jq"
        exit 1
    fi
    
    ORGANIZATION_URL=$(jq -r '.organization_url // empty' "$config_path")
    PROJECT=$(jq -r '.project // empty' "$config_path")
    USERNAME=$(jq -r '.username // empty' "$config_path")
    PAT=$(jq -r '.pat // empty' "$config_path")
    CLONE_PATH=$(jq -r '.clone_path // empty' "$config_path")
    
    print_success "Configuration loaded"
}

check_prerequisites() {
    print_info "Checking prerequisites..."
    
    if ! command -v git &>/dev/null; then
        print_error "Git not found. Install Git first."
        exit 1
    fi
    
    if ! command -v curl &>/dev/null; then
        print_error "curl not found. Install curl first."
        exit 1
    fi
    
    if ! command -v jq &>/dev/null; then
        print_error "jq not found. Install with: sudo apt install jq"
        exit 1
    fi
    
    print_success "Prerequisites OK"
}

validate_config() {
    local valid=true
    
    if [[ -z "$ORGANIZATION_URL" ]]; then
        print_error "Organization URL not provided"
        valid=false
    fi
    
    if [[ -z "$PROJECT" ]]; then
        print_error "Project name not provided"
        valid=false
    fi
    
    if [[ -z "$USERNAME" ]]; then
        print_error "Username not provided"
        valid=false
    fi
    
    if [[ -z "$PAT" ]]; then
        print_error "PAT (Personal Access Token) not provided"
        valid=false
    fi
    
    if [[ "$valid" == "false" ]]; then
        echo ""
        show_usage
        exit 1
    fi
    
    # Default value for clone_path
    if [[ -z "$CLONE_PATH" ]]; then
        CLONE_PATH="./repos"
    fi
}

get_repositories() {
    print_info "Fetching repositories from project: $PROJECT"
    
    # Encode credentials in base64
    local auth=$(echo -n "${USERNAME}:${PAT}" | base64)
    
    # Remove trailing slash from URL if exists
    ORGANIZATION_URL="${ORGANIZATION_URL%/}"
    
    # API URL to list repositories
    local api_url="${ORGANIZATION_URL}/${PROJECT}/_apis/git/repositories?api-version=7.0"
    
    # Make request
    local response
    response=$(curl -s -H "Authorization: Basic ${auth}" "$api_url")
    
    # Check for error
    if echo "$response" | jq -e '.message' &>/dev/null; then
        local error_msg=$(echo "$response" | jq -r '.message')
        print_error "API Error: $error_msg"
        exit 1
    fi
    
    # Extract repository list
    echo "$response" | jq -r '.value[] | "\(.name)|\(.remoteUrl)"'
}

clone_repository() {
    local repo_name="$1"
    local repo_url="$2"
    local target_dir="${CLONE_PATH}/${repo_name}"
    local had_stash=false
    
    # Build URL with authentication
    local auth_url
    auth_url=$(echo "$repo_url" | sed "s|https://|https://${USERNAME}:${PAT}@|")
    
    if [[ -d "$target_dir/.git" ]]; then
        print_update "Updating: $repo_name"
        
        cd "$target_dir"
        
        # Check for local changes
        if ! git diff --quiet 2>/dev/null || ! git diff --cached --quiet 2>/dev/null; then
            print_warning "  Local changes detected, stashing..."
            if git stash push -m "auto-stash before pull $(date +%Y%m%d-%H%M%S)" --quiet 2>/dev/null; then
                had_stash=true
                REPOS_STASHED+=("$repo_name")
            else
                print_error "  Failed to stash"
                REPOS_FAILED+=("$repo_name (stash failed)")
                cd - > /dev/null
                return 1
            fi
        fi
        
        # Pull
        if git pull --quiet 2>/dev/null; then
            REPOS_UPDATED+=("$repo_name")
            if [[ "$had_stash" == "true" ]]; then
                print_info "  Restoring stash..."
                if ! git stash pop --quiet 2>/dev/null; then
                    print_warning "  ⚠️ Conflict restoring stash. Use 'git stash pop' manually."
                fi
            fi
            print_success "OK: $repo_name"
        else
            print_error "  Pull failed"
            REPOS_FAILED+=("$repo_name (pull failed)")
            # Restore stash even if pull failed
            if [[ "$had_stash" == "true" ]]; then
                git stash pop --quiet 2>/dev/null || true
            fi
            cd - > /dev/null
            return 1
        fi
        
        cd - > /dev/null
    else
        print_install "Cloning: $repo_name"
        if git clone --quiet "$auth_url" "$target_dir" 2>/dev/null; then
            REPOS_CLONED+=("$repo_name")
            print_success "OK: $repo_name"
        else
            print_error "Failed to clone: $repo_name"
            REPOS_FAILED+=("$repo_name (clone failed)")
            return 1
        fi
    fi
}

print_summary() {
    echo ""
    echo "============================================================"
    print_step "EXECUTION SUMMARY"
    echo "============================================================"
    echo ""
    
    # Cloned
    if [[ ${#REPOS_CLONED[@]} -gt 0 ]]; then
        print_install "Cloned repositories (${#REPOS_CLONED[@]}):"
        for repo in "${REPOS_CLONED[@]}"; do
            echo "    • $repo"
        done
        echo ""
    fi
    
    # Updated
    if [[ ${#REPOS_UPDATED[@]} -gt 0 ]]; then
        print_update "Updated repositories (${#REPOS_UPDATED[@]}):"
        for repo in "${REPOS_UPDATED[@]}"; do
            echo "    • $repo"
        done
        echo ""
    fi
    
    # Stashed
    if [[ ${#REPOS_STASHED[@]} -gt 0 ]]; then
        print_warning "Repositories with stash applied (${#REPOS_STASHED[@]}):"
        for repo in "${REPOS_STASHED[@]}"; do
            echo "    • $repo"
        done
        echo ""
    fi
    
    # Failed
    if [[ ${#REPOS_FAILED[@]} -gt 0 ]]; then
        print_error "Failed repositories (${#REPOS_FAILED[@]}):"
        for repo in "${REPOS_FAILED[@]}"; do
            echo "    • $repo"
        done
        echo ""
    fi
    
    # Totals
    echo "------------------------------------------------------------"
    local total=$((${#REPOS_CLONED[@]} + ${#REPOS_UPDATED[@]} + ${#REPOS_FAILED[@]}))
    local success=$((${#REPOS_CLONED[@]} + ${#REPOS_UPDATED[@]}))
    echo -e "${WHITE}📊 TOTAL: $success of $total repositories processed successfully${NC}"
    echo -e "   📦 Cloned:    ${#REPOS_CLONED[@]}"
    echo -e "   🔄 Updated:   ${#REPOS_UPDATED[@]}"
    echo -e "   📂 Stashed:   ${#REPOS_STASHED[@]}"
    echo -e "   ❌ Failed:    ${#REPOS_FAILED[@]}"
    echo "------------------------------------------------------------"
    print_info "Location: $CLONE_PATH"
}

# ============================================================================
# Main
# ============================================================================

main() {
    print_step "Azure DevOps Repository Clone"
    echo ""
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -o|--org)
                ORGANIZATION_URL="$2"
                shift 2
                ;;
            -p|--project)
                PROJECT="$2"
                shift 2
                ;;
            -u|--username)
                USERNAME="$2"
                shift 2
                ;;
            -t|--pat)
                PAT="$2"
                shift 2
                ;;
            -d|--destination)
                CLONE_PATH="$2"
                shift 2
                ;;
            -c|--config)
                CONFIG_FILE="$2"
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
    
    # Try to load config if exists and parameters were not provided
    if [[ -z "$ORGANIZATION_URL" ]] && [[ -f "$CONFIG_FILE" ]]; then
        load_config "$CONFIG_FILE"
    fi
    
    check_prerequisites
    validate_config
    
    # Create destination folder
    if [[ ! -d "$CLONE_PATH" ]]; then
        print_info "Creating folder: $CLONE_PATH"
        mkdir -p "$CLONE_PATH"
    fi
    
    # Fetch and clone repositories
    local repos
    repos=$(get_repositories)
    
    if [[ -z "$repos" ]]; then
        print_warning "No repositories found in project"
        exit 0
    fi
    
    while IFS='|' read -r repo_name repo_url; do
        clone_repository "$repo_name" "$repo_url" || true
    done <<< "$repos"
    
    print_summary
}

main "$@"
