#!/bin/bash
set -euo pipefail

# ============================================================================
# Script: configure-chrome.sh
# Description: Configura segurança, privacidade e extensões do Google Chrome
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
print_step()    { echo -e "\n${WHITE}🚀 $1${NC}"; }

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Error handling
trap 'print_error "Error on line $LINENO"; exit 1' ERR

# Options
CONFIG_PATH=""
SKIP_EXTENSIONS=false
SKIP_SETTINGS=false
FORCE=false

# ============================================================================
# OS Detection and Paths
# ============================================================================

detect_os() {
    case "$(uname -s)" in
        Linux*)  echo "linux" ;;
        Darwin*) echo "macos" ;;
        *)       echo "unknown" ;;
    esac
}

get_chrome_path() {
    local os="$1"
    
    case "$os" in
        linux)
            if [[ -d "$HOME/.config/google-chrome" ]]; then
                echo "$HOME/.config/google-chrome"
            elif [[ -d "$HOME/.config/chromium" ]]; then
                echo "$HOME/.config/chromium"
            elif [[ -d "$HOME/.config/google-chrome-beta" ]]; then
                echo "$HOME/.config/google-chrome-beta"
            else
                echo ""
            fi
            ;;
        macos)
            echo "$HOME/Library/Application Support/Google/Chrome"
            ;;
        *)
            echo ""
            ;;
    esac
}

get_chrome_binary() {
    local os="$1"
    
    case "$os" in
        linux)
            if command -v google-chrome &>/dev/null; then
                echo "google-chrome"
            elif command -v google-chrome-stable &>/dev/null; then
                echo "google-chrome-stable"
            elif command -v chromium &>/dev/null; then
                echo "chromium"
            elif command -v chromium-browser &>/dev/null; then
                echo "chromium-browser"
            else
                echo ""
            fi
            ;;
        macos)
            if [[ -d "/Applications/Google Chrome.app" ]]; then
                echo "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
            else
                echo ""
            fi
            ;;
        *)
            echo ""
            ;;
    esac
}

# ============================================================================
# Configuration Loading
# ============================================================================

load_configuration() {
    local config_path="$1"
    
    # Default config path
    if [[ -z "$config_path" ]]; then
        config_path="$SCRIPT_DIR/config.json"
    fi
    
    if [[ ! -f "$config_path" ]]; then
        print_error "Configuration file not found: $config_path"
        exit 1
    fi
    
    print_info "Loading configuration from: $config_path"
    
    # Validate JSON
    if ! jq empty "$config_path" 2>/dev/null; then
        print_error "Invalid JSON in configuration file"
        exit 1
    fi
    
    CONFIG_FILE="$config_path"
    print_success "Configuration loaded successfully"
}

get_config_value() {
    local path="$1"
    jq -r "$path" "$CONFIG_FILE"
}

get_config_array() {
    local path="$1"
    jq -r "$path | @sh" "$CONFIG_FILE"
}

# ============================================================================
# Functions
# ============================================================================

parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --config)
                CONFIG_PATH="$2"
                shift 2
                ;;
            --skip-extensions)
                SKIP_EXTENSIONS=true
                shift
                ;;
            --skip-settings)
                SKIP_SETTINGS=true
                shift
                ;;
            --force)
                FORCE=true
                shift
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

show_help() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --config PATH        Path to config.json file"
    echo "  --skip-extensions    Skip extension installation"
    echo "  --skip-settings      Skip settings configuration"
    echo "  --force              Don't ask to close Chrome"
    echo "  -h, --help           Show this help message"
}

check_jq() {
    if ! command -v jq &>/dev/null; then
        print_warning "jq not found. Installing..."
        local os
        os=$(detect_os)
        
        case "$os" in
            linux)
                if command -v apt-get &>/dev/null; then
                    sudo apt-get update && sudo apt-get install -y jq
                elif command -v dnf &>/dev/null; then
                    sudo dnf install -y jq
                elif command -v pacman &>/dev/null; then
                    sudo pacman -S --noconfirm jq
                else
                    print_error "Could not install jq. Please install it manually."
                    exit 1
                fi
                ;;
            macos)
                if command -v brew &>/dev/null; then
                    brew install jq
                else
                    print_error "Homebrew not found. Please install jq manually: brew install jq"
                    exit 1
                fi
                ;;
        esac
    fi
}

get_chrome_profiles() {
    local chrome_path="$1"
    local profiles=()
    
    print_info "Detecting Chrome profiles..."
    
    if [[ ! -d "$chrome_path" ]]; then
        print_error "Chrome User Data folder not found: $chrome_path"
        return 1
    fi
    
    # Default profile
    if [[ -d "$chrome_path/Default" ]]; then
        profiles+=("Default")
    fi
    
    # Profile N folders
    for folder in "$chrome_path"/Profile\ *; do
        if [[ -d "$folder" ]]; then
            local profile_name
            profile_name=$(basename "$folder")
            profiles+=("$profile_name")
        fi
    done
    
    print_success "Found ${#profiles[@]} profile(s)"
    for profile in "${profiles[@]}"; do
        echo "   📁 $profile"
    done
    
    CHROME_PROFILES=("${profiles[@]}")
}

set_chrome_preferences() {
    local chrome_path="$1"
    local profile_name="$2"
    local os="$3"
    
    print_step "Configuring preferences for: $profile_name"
    
    local profile_path="$chrome_path/$profile_name"
    local prefs_file="$profile_path/Preferences"
    
    # Get download path from config
    local download_path
    if [[ "$os" == "macos" ]]; then
        download_path=$(get_config_value '.downloadPath.macos' | sed "s|~|$HOME|")
    else
        download_path=$(get_config_value '.downloadPath.linux' | sed "s|~|$HOME|")
    fi
    
    # Create backup
    if [[ -f "$prefs_file" ]]; then
        cp "$prefs_file" "$prefs_file.backup.$(date +%Y%m%d-%H%M%S)"
        print_info "Created backup of Preferences file"
    else
        print_warning "Preferences file not found, creating new..."
        echo '{}' > "$prefs_file"
    fi
    
    # Create download directory
    if [[ ! -d "$download_path" ]]; then
        mkdir -p "$download_path"
        print_success "Created download folder: $download_path"
    fi
    
    print_info "Configuring settings from config.json..."
    
    local tmp_file
    tmp_file=$(mktemp)
    
    # Read settings from config and apply
    jq --arg download_path "$download_path" \
       --argjson blockThirdParty "$(get_config_value '.settings.cookies.blockThirdParty')" \
       --argjson cookieControlsMode "$(get_config_value '.settings.cookies.cookieControlsMode')" \
       --argjson doNotTrack "$(get_config_value '.settings.tracking.doNotTrack')" \
       --argjson metricsEnabled "$(get_config_value '.settings.tracking.metricsEnabled')" \
       --argjson scoutReportingEnabled "$(get_config_value '.settings.tracking.scoutReportingEnabled')" \
       --argjson safeBrowsingEnabled "$(get_config_value '.settings.safeBrowsing.enabled')" \
       --argjson safeBrowsingEnhanced "$(get_config_value '.settings.safeBrowsing.enhanced')" \
       --argjson topicsEnabled "$(get_config_value '.settings.privacySandbox.topicsEnabled')" \
       --argjson fledgeEnabled "$(get_config_value '.settings.privacySandbox.fledgeEnabled')" \
       --argjson adMeasurementEnabled "$(get_config_value '.settings.privacySandbox.adMeasurementEnabled')" \
       --argjson apisEnabled "$(get_config_value '.settings.privacySandbox.apisEnabled')" \
       --argjson autofillProfileEnabled "$(get_config_value '.settings.autofill.profileEnabled')" \
       --argjson autofillCreditCardEnabled "$(get_config_value '.settings.autofill.creditCardEnabled')" \
       --argjson passwordManagerEnabled "$(get_config_value '.settings.autofill.passwordManagerEnabled')" \
       --argjson paymentsEnabled "$(get_config_value '.settings.autofill.paymentsEnabled')" \
       --argjson suggestEnabled "$(get_config_value '.settings.search.suggestEnabled')" \
       --argjson predictionOptions "$(get_config_value '.settings.network.predictionOptions')" \
       --argjson restoreOnStartup "$(get_config_value '.settings.startup.restoreOnStartup')" \
       --argjson promptForDownload "$(get_config_value '.settings.downloads.promptForDownload')" \
       --arg acceptLanguages "$(get_config_value '.settings.languages.acceptLanguages')" \
       --arg selectedLanguages "$(get_config_value '.settings.languages.selectedLanguages')" \
       --argjson spellcheckDictionaries "$(jq '.settings.languages.spellcheckDictionaries' "$CONFIG_FILE")" \
       --argjson useSpellingService "$(get_config_value '.settings.languages.useSpellingService')" \
       --argjson highEfficiencyModeState "$(get_config_value '.settings.performance.highEfficiencyModeState')" \
       --argjson batterySaverModeState "$(get_config_value '.settings.performance.batterySaverModeState')" \
       --argjson hardwareAccelerationEnabled "$(get_config_value '.settings.performance.hardwareAccelerationEnabled')" \
       --argjson backgroundModeEnabled "$(get_config_value '.settings.performance.backgroundModeEnabled')" \
    '
    # Cookies and Tracking
    .profile.block_third_party_cookies = $blockThirdParty |
    .profile.cookie_controls_mode = $cookieControlsMode |
    .enable_do_not_track = $doNotTrack |
    .safebrowsing.metrics_enabled = $metricsEnabled |
    .safebrowsing.scout_reporting_enabled = $scoutReportingEnabled |
    .safebrowsing.enabled = $safeBrowsingEnabled |
    .safebrowsing.enhanced = $safeBrowsingEnhanced |
    
    # Privacy Sandbox APIs
    .privacy_sandbox.m1.topics_enabled = $topicsEnabled |
    .privacy_sandbox.m1.fledge_enabled = $fledgeEnabled |
    .privacy_sandbox.m1.ad_measurement_enabled = $adMeasurementEnabled |
    .privacy_sandbox.apis_enabled = $apisEnabled |
    .privacy_sandbox.apis_enabled_v2 = $apisEnabled |
    
    # Autofill
    .autofill.profile_enabled = $autofillProfileEnabled |
    .autofill.credit_card_enabled = $autofillCreditCardEnabled |
    .credentials_enable_service = $passwordManagerEnabled |
    .profile.password_manager_enabled = $passwordManagerEnabled |
    .payments.can_make_payment_enabled = $paymentsEnabled |
    
    # Other settings
    .search.suggest_enabled = $suggestEnabled |
    .net.network_prediction_options = $predictionOptions |
    .alternate_error_pages.enabled = false |
    .session.restore_on_startup = $restoreOnStartup |
    .download.prompt_for_download = $promptForDownload |
    .download.default_directory = $download_path |
    .savefile.default_directory = $download_path |
    
    # Languages
    .intl.accept_languages = $acceptLanguages |
    .intl.selected_languages = $selectedLanguages |
    .spellcheck.dictionaries = $spellcheckDictionaries |
    .spellcheck.use_spelling_service = $useSpellingService |
    
    # Performance
    .performance_tuning.high_efficiency_mode.state = $highEfficiencyModeState |
    .performance_tuning.battery_saver_mode.state = $batterySaverModeState |
    .hardware_acceleration_mode.enabled = $hardwareAccelerationEnabled |
    .background_mode.enabled = $backgroundModeEnabled |
    .browser.background_mode_enabled = $backgroundModeEnabled
    ' "$prefs_file" > "$tmp_file"
    
    if [[ $? -eq 0 ]] && [[ -s "$tmp_file" ]]; then
        mv "$tmp_file" "$prefs_file"
        print_success "Preferences saved for $profile_name"
    else
        print_error "Failed to update preferences"
        rm -f "$tmp_file"
        return 1
    fi
}

install_external_extensions() {
    local os="$1"
    
    print_step "Installing extensions via External Extensions method..."
    
    # Determine external extensions path based on OS
    local ext_path
    case "$os" in
        linux)
            # For Linux: system-wide or user-specific
            ext_path="/usr/share/google-chrome/extensions"
            if [[ ! -w "/usr/share/google-chrome" ]]; then
                # Try user-specific location
                ext_path="$HOME/.config/google-chrome/External Extensions"
            fi
            ;;
        macos)
            # For macOS: Library location
            ext_path="/Library/Application Support/Google/Chrome/External Extensions"
            if [[ ! -w "/Library/Application Support/Google/Chrome" ]]; then
                ext_path="$HOME/Library/Application Support/Google/Chrome/External Extensions"
            fi
            ;;
    esac
    
    # Create directory if needed
    if [[ ! -d "$ext_path" ]]; then
        mkdir -p "$ext_path" 2>/dev/null || {
            print_warning "Cannot create $ext_path - need sudo?"
            print_info "Trying with sudo..."
            sudo mkdir -p "$ext_path"
            sudo chmod 755 "$ext_path"
        }
    fi
    
    print_info "External extensions path: $ext_path"
    echo ""
    
    local count=0
    local total
    total=$(jq '.extensions | length' "$CONFIG_FILE")
    
    # Get extensions from config and create JSON files
    jq -r '.extensions | to_entries[] | "\(.key)|\(.value)"' "$CONFIG_FILE" | while IFS='|' read -r ext_name ext_id; do
        local json_file="$ext_path/$ext_id.json"
        local json_content='{"external_update_url": "https://clients2.google.com/service/update2/crx"}'
        
        ((count++)) || true
        echo -e "   ${CYAN}📦 [$count/$total] $ext_name${NC}"
        
        # Write JSON file (may need sudo)
        if [[ -w "$ext_path" ]]; then
            echo "$json_content" > "$json_file"
        else
            echo "$json_content" | sudo tee "$json_file" > /dev/null
        fi
    done
    
    echo ""
    print_success "Created external extension files"
    echo ""
    print_info "📋 What happens next:"
    echo "   1. Close and reopen Chrome"
    echo "   2. Chrome will detect the new extensions"
    echo "   3. A popup will appear asking to enable each extension"
    echo "   4. Click 'Enable' for each one"
    echo ""
    print_warning "Note: Extensions already installed will be skipped automatically."
}

open_extension_pages() {
    local os="$1"
    local chrome_binary="$2"
    
    print_step "Opening extension installation pages..."
    
    print_info "Extensions will be opened in Chrome for installation."
    print_warning "Please click 'Add to Chrome' for each extension."
    echo ""
    
    local count=0
    local total
    total=$(jq '.extensions | length' "$CONFIG_FILE")
    
    # Get extensions from config
    jq -r '.extensions | to_entries[] | "\(.key)|\(.value)"' "$CONFIG_FILE" | while IFS='|' read -r ext_name ext_id; do
        local url="https://chrome.google.com/webstore/detail/$ext_id"
        
        ((count++)) || true
        echo -e "   ${CYAN}📦 [$count/$total] $ext_name${NC}"
        
        case "$os" in
            linux)
                if [[ -n "$chrome_binary" ]]; then
                    "$chrome_binary" "$url" &>/dev/null &
                else
                    xdg-open "$url" &>/dev/null &
                fi
                ;;
            macos)
                open -a "Google Chrome" "$url" &>/dev/null &
                ;;
        esac
        
        sleep 1.5
    done
    
    echo ""
    print_success "Opened all extension pages in Chrome"
    print_info "Install each extension by clicking 'Add to Chrome'"
}

show_summary() {
    print_step "Configuration Summary"
    
    echo ""
    echo -e "${WHITE}📋 Settings Applied (from config.json):${NC}"
    echo "   ├─ Block third-party cookies: $(get_config_value '.settings.cookies.blockThirdParty')"
    echo "   ├─ Do Not Track: $(get_config_value '.settings.tracking.doNotTrack')"
    echo "   ├─ Telemetry/Metrics: $(get_config_value '.settings.tracking.metricsEnabled')"
    echo "   ├─ Safe Browsing: $(get_config_value '.settings.safeBrowsing.enabled')"
    echo "   ├─ Privacy Sandbox APIs: $(get_config_value '.settings.privacySandbox.apisEnabled')"
    echo "   ├─ Autofill: $(get_config_value '.settings.autofill.profileEnabled')"
    echo "   ├─ Password Manager: $(get_config_value '.settings.autofill.passwordManagerEnabled')"
    echo "   ├─ Search suggestions: $(get_config_value '.settings.search.suggestEnabled')"
    echo "   ├─ Languages: $(get_config_value '.settings.languages.acceptLanguages')"
    echo "   ├─ Memory Saver: State $(get_config_value '.settings.performance.highEfficiencyModeState')"
    echo "   ├─ Hardware acceleration: $(get_config_value '.settings.performance.hardwareAccelerationEnabled')"
    echo "   └─ Background apps: $(get_config_value '.settings.performance.backgroundModeEnabled')"
    echo ""
    
    if [[ "$SKIP_EXTENSIONS" == "false" ]]; then
        echo -e "${WHITE}📦 Extensions to install:${NC}"
        jq -r '.extensions | keys[]' "$CONFIG_FILE" | while read -r ext_name; do
            echo "   ├─ $ext_name"
        done
        echo ""
    fi
}

check_chrome_running() {
    if pgrep -x "chrome" &>/dev/null || pgrep -x "Google Chrome" &>/dev/null || pgrep -x "chromium" &>/dev/null; then
        return 0
    fi
    return 1
}

# ============================================================================
# Main
# ============================================================================

main() {
    parse_args "$@"
    
    echo ""
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║     🔒 Chrome Security & Privacy Configuration Tool          ║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    # Check jq
    check_jq
    
    # Load configuration
    load_configuration "$CONFIG_PATH"
    
    # Detect OS
    local os
    os=$(detect_os)
    print_info "Detected OS: $os"
    
    if [[ "$os" == "unknown" ]]; then
        print_error "Unsupported operating system"
        exit 1
    fi
    
    # Get Chrome paths
    local chrome_path
    chrome_path=$(get_chrome_path "$os")
    
    if [[ -z "$chrome_path" ]] || [[ ! -d "$chrome_path" ]]; then
        print_error "Chrome installation not found"
        exit 1
    fi
    
    print_info "Chrome path: $chrome_path"
    
    local chrome_binary
    chrome_binary=$(get_chrome_binary "$os")
    
    # Check if Chrome is running
    if check_chrome_running && [[ "$FORCE" == "false" ]]; then
        print_warning "Chrome is currently running!"
        echo ""
        read -p "Close Chrome to continue? (y/n) " -n 1 -r
        echo ""
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            print_info "Closing Chrome..."
            pkill -x "chrome" 2>/dev/null || true
            pkill -x "Google Chrome" 2>/dev/null || true
            pkill -x "chromium" 2>/dev/null || true
            sleep 2
        else
            print_warning "Some settings may not be applied while Chrome is running."
        fi
    fi
    
    # Get profiles
    CHROME_PROFILES=()
    get_chrome_profiles "$chrome_path"
    
    if [[ ${#CHROME_PROFILES[@]} -eq 0 ]]; then
        print_error "No Chrome profiles found!"
        exit 1
    fi
    
    # Apply settings
    if [[ "$SKIP_SETTINGS" == "false" ]]; then
        for profile in "${CHROME_PROFILES[@]}"; do
            set_chrome_preferences "$chrome_path" "$profile" "$os"
        done
    fi
    
    # Show summary
    show_summary
    
    # Install extensions
    if [[ "$SKIP_EXTENSIONS" == "false" ]]; then
        echo ""
        echo -e "${YELLOW}📦 Extension Installation Options:${NC}"
        echo "   [1] External Extensions (recommended - works for all profiles)"
        echo "   [2] Open Chrome Web Store pages (manual install)"
        echo "   [3] Skip extension installation"
        echo ""
        read -p "Choose option (1/2/3): " -n 1 -r choice
        echo ""
        
        case "$choice" in
            1)
                install_external_extensions "$os"
                ;;
            2)
                open_extension_pages "$os" "$chrome_binary"
                ;;
            *)
                print_info "Skipping extension installation. You can run again later."
                ;;
        esac
    fi
    
    echo ""
    print_success "Configuration complete!"
    echo ""
    print_info "💡 Tip: Restart Chrome to apply all settings"
}

main "$@"
