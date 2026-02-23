#!/bin/bash
# Shared functions for sync scripts

load_env() {
    local script_dir="$1"
    if [ -f "$script_dir/.env" ]; then
        export $(grep -v '^#' "$script_dir/.env" | grep -v '^\s*$' | xargs)
    fi
}

# Resolve storage path for each edition (Linux side)
get_storage_path_linux() {
    local edition="$1"
    case "$edition" in
        stable)
            local p="${VSCODE_STORAGE_PATH_STABLE:-$HOME/.config/Code/User/workspaceStorage}"
            [ -d "$p" ] && echo "$p"
            ;;
        insiders)
            local p="${VSCODE_STORAGE_PATH_INSIDERS:-$HOME/.config/Code - Insiders/User/workspaceStorage}"
            [ -d "$p" ] && echo "$p"
            ;;
        ssh)
            local p="${VSCODE_STORAGE_PATH_SSH:-$HOME/.vscode-server/data/User/workspaceStorage}"
            [ -d "$p" ] && echo "$p"
            ;;
    esac
}

get_global_storage_linux() {
    local edition="$1"
    local ws_path
    ws_path=$(get_storage_path_linux "$edition")
    [ -z "$ws_path" ] && return

    local global_dir
    case "$edition" in
        ssh)
            global_dir="$HOME/.vscode-server/data/User/globalStorage/GitHub.copilot-chat"
            ;;
        *)
            global_dir="$(dirname "$ws_path")/globalStorage/GitHub.copilot-chat"
            ;;
    esac
    [ -d "$global_dir" ] && echo "$global_dir"
}

get_workspace_name() {
    local ws_dir="$1"
    local ws_json="$ws_dir/workspace.json"
    if [ -f "$ws_json" ]; then
        python3 -c "
import json, urllib.parse, os
with open('$ws_json') as f:
    data = json.load(f)
uri = data.get('folder', '')
decoded = urllib.parse.unquote(uri)
path = decoded.replace('file:///', '').replace('file://', '')
print(os.path.basename(path.rstrip('/')))
" 2>/dev/null || echo "unknown"
    else
        echo "unknown"
    fi
}

# Collect all active storage paths into STORAGE_PATHS associative array
collect_storage_paths_linux() {
    declare -gA STORAGE_PATHS
    local editions="${VSCODE_EDITIONS:-stable,insiders}"

    IFS=',' read -ra EDITIONS_ARR <<< "$editions"
    for edition in "${EDITIONS_ARR[@]}"; do
        edition=$(echo "$edition" | tr -d ' ')
        [ "$edition" = "wsl" ] && continue
        local path
        path=$(get_storage_path_linux "$edition")
        if [ -n "$path" ] && [ -d "$path" ]; then
            STORAGE_PATHS["$edition"]="$path"
        fi
    done
}

# Sync entire workspace to repo
sync_workspace_to_repo() {
    local ws_id="$1"
    local ws_src="$2"
    local data_dir="$3"
    local force="${FORCE_SYNC:-0}"
    local ws_dest="$data_dir/$ws_id"

    # Skip empty directories
    if [ -z "$(ls -A "$ws_src" 2>/dev/null)" ]; then
        return 1
    fi

    if [ "$force" = "1" ]; then
        mkdir -p "$ws_dest"
        rsync -a --delete "$ws_src/" "$ws_dest/"
        return 0
    fi

    # Last-write-wins: compare newest file timestamps
    local src_ts dest_ts
    src_ts=$(find "$ws_src" -type f -printf '%T@\n' 2>/dev/null | sort -rn | head -1 | cut -d. -f1)
    dest_ts=$(find "$ws_dest" -type f -printf '%T@\n' 2>/dev/null | sort -rn | head -1 | cut -d. -f1)
    src_ts="${src_ts:-0}"
    dest_ts="${dest_ts:-0}"

    if [ "$src_ts" -ge "$dest_ts" ]; then
        mkdir -p "$ws_dest"
        rsync -a --delete "$ws_src/" "$ws_dest/"
        return 0
    fi

    return 1
}
