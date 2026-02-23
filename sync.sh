#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$SCRIPT_DIR"
DATA_DIR="$REPO_DIR/data"

# Load .env
if [ -f "$REPO_DIR/.env" ]; then
    export $(grep -v '^#' "$REPO_DIR/.env" | grep -v '^\s*$' | xargs)
fi

GIT_BRANCH="${GIT_BRANCH:-main}"
COMMIT_PREFIX="${COMMIT_PREFIX:-chatsync}"
VSCODE_EDITIONS="${VSCODE_EDITIONS:-stable,insiders}"

# Resolve storage paths for each edition
get_storage_path() {
    local edition="$1"
    case "$edition" in
        stable)
            if [ -n "${VSCODE_STORAGE_PATH_STABLE:-}" ]; then
                echo "$VSCODE_STORAGE_PATH_STABLE"
            elif [ -d "$HOME/.config/Code/User/workspaceStorage" ]; then
                echo "$HOME/.config/Code/User/workspaceStorage"
            fi
            ;;
        insiders)
            if [ -n "${VSCODE_STORAGE_PATH_INSIDERS:-}" ]; then
                echo "$VSCODE_STORAGE_PATH_INSIDERS"
            elif [ -d "$HOME/.config/Code - Insiders/User/workspaceStorage" ]; then
                echo "$HOME/.config/Code - Insiders/User/workspaceStorage"
            fi
            ;;
    esac
}

get_global_storage_path() {
    local edition="$1"
    local ws_path
    ws_path=$(get_storage_path "$edition")
    [ -z "$ws_path" ] && return
    local parent
    parent=$(dirname "$ws_path")
    local global_dir="$parent/globalStorage/GitHub.copilot-chat"
    [ -d "$global_dir" ] && echo "$global_dir"
}

# Collect all active storage paths
declare -A STORAGE_PATHS
IFS=',' read -ra EDITIONS <<< "$VSCODE_EDITIONS"
for edition in "${EDITIONS[@]}"; do
    edition=$(echo "$edition" | tr -d ' ')
    path=$(get_storage_path "$edition")
    if [ -n "$path" ] && [ -d "$path" ]; then
        STORAGE_PATHS["$edition"]="$path"
    fi
done

if [ ${#STORAGE_PATHS[@]} -eq 0 ]; then
    echo "ERROR: No VS Code storage paths found."
    echo "Check VSCODE_EDITIONS and storage path settings in .env"
    exit 1
fi

echo "Active editions: ${!STORAGE_PATHS[*]}"

# Resolve workspace name from workspace.json
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

sync_workspace_to_repo() {
    local ws_id="$1"
    local ws_src="$2"
    local ws_dest="$DATA_DIR/$ws_id"

    local copilot_dir="$ws_src/GitHub.copilot-chat"
    local workspace_json="$ws_src/workspace.json"

    if [ -d "$copilot_dir" ] || [ -f "$workspace_json" ]; then
        mkdir -p "$ws_dest"
        [ -f "$workspace_json" ] && cp "$workspace_json" "$ws_dest/"
        if [ -d "$copilot_dir" ]; then
            # Last-write-wins: only overwrite if source is newer
            local src_ts dest_ts
            src_ts=$(find "$copilot_dir" -type f -printf '%T@\n' 2>/dev/null | sort -rn | head -1 | cut -d. -f1)
            dest_ts=$(find "$ws_dest/GitHub.copilot-chat" -type f -printf '%T@\n' 2>/dev/null | sort -rn | head -1 | cut -d. -f1)
            src_ts="${src_ts:-0}"
            dest_ts="${dest_ts:-0}"

            if [ "$src_ts" -ge "$dest_ts" ]; then
                rsync -a --delete "$copilot_dir/" "$ws_dest/GitHub.copilot-chat/"
            fi
        fi
        return 0
    fi
    return 1
}

do_push() {
    mkdir -p "$DATA_DIR"
    cd "$REPO_DIR"

    local pushed=0
    local TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
    local HOSTNAME=$(hostname)

    # Collect from all editions into unified data/
    for edition in "${!STORAGE_PATHS[@]}"; do
        local storage="${STORAGE_PATHS[$edition]}"

        for ws_dir in "$storage"/*/; do
            [ -d "$ws_dir" ] || continue
            local ws_id=$(basename "$ws_dir")

            sync_workspace_to_repo "$ws_id" "$ws_dir" || continue

            git add "data/$ws_id/" 2>/dev/null || continue

            if ! git diff --cached --quiet -- "data/$ws_id/"; then
                local ws_name=$(get_workspace_name "$DATA_DIR/$ws_id")
                git commit -m "$COMMIT_PREFIX: $HOSTNAME | $ws_name | $TIMESTAMP"
                pushed=1
            fi
        done

        # Global storage
        local global_path
        global_path=$(get_global_storage_path "$edition")
        if [ -n "$global_path" ]; then
            mkdir -p "$DATA_DIR/_globalStorage"
            rsync -a --update "$global_path/" "$DATA_DIR/_globalStorage/"
        fi
    done

    # Commit global storage if changed
    if [ -d "$DATA_DIR/_globalStorage" ]; then
        git add "data/_globalStorage/" 2>/dev/null || true
        if ! git diff --cached --quiet -- "data/_globalStorage/"; then
            git commit -m "$COMMIT_PREFIX: $HOSTNAME | globalStorage | $TIMESTAMP"
            pushed=1
        fi
    fi

    if [ "$pushed" -eq 1 ]; then
        git push origin "$GIT_BRANCH"
        echo "Pushed changes successfully."
    else
        echo "No changes to sync."
    fi
}

sync_from_repo() {
    if [ ! -d "$DATA_DIR" ]; then
        echo "ERROR: No data directory found. Run 'push' first on the source machine."
        exit 1
    fi

    # Restore to ALL active editions
    for edition in "${!STORAGE_PATHS[@]}"; do
        local storage="${STORAGE_PATHS[$edition]}"
        echo "Restoring to $edition ($storage)..."

        for ws_data_dir in "$DATA_DIR"/*/; do
            [ -d "$ws_data_dir" ] || continue
            local ws_id=$(basename "$ws_data_dir")
            [ "$ws_id" = "_globalStorage" ] && continue

            local dest_dir="$storage/$ws_id"
            mkdir -p "$dest_dir"

            local workspace_json="$ws_data_dir/workspace.json"
            [ -f "$workspace_json" ] && cp "$workspace_json" "$dest_dir/"

            local copilot_dir="$ws_data_dir/GitHub.copilot-chat"
            if [ -d "$copilot_dir" ]; then
                rsync -a "$copilot_dir/" "$dest_dir/GitHub.copilot-chat/"
            fi
        done

        # Restore global storage
        if [ -d "$DATA_DIR/_globalStorage" ]; then
            local global_dest
            global_dest="$(dirname "$storage")/globalStorage/GitHub.copilot-chat"
            mkdir -p "$global_dest"
            rsync -a "$DATA_DIR/_globalStorage/" "$global_dest/"
        fi
    done
}

do_pull() {
    cd "$REPO_DIR"
    local before=$(git rev-parse HEAD 2>/dev/null || echo "none")
    git pull origin "$GIT_BRANCH" --rebase
    local after=$(git rev-parse HEAD 2>/dev/null || echo "none")

    if [ "$before" != "$after" ]; then
        echo "New changes found, applying..."
        sync_from_repo
        echo "Pulled and applied changes successfully."
    else
        echo "Already up to date."
    fi
}

do_status() {
    mkdir -p "$DATA_DIR"

    for edition in "${!STORAGE_PATHS[@]}"; do
        local storage="${STORAGE_PATHS[$edition]}"
        for ws_dir in "$storage"/*/; do
            [ -d "$ws_dir" ] || continue
            sync_workspace_to_repo "$(basename "$ws_dir")" "$ws_dir" 2>/dev/null || true
        done
    done

    cd "$REPO_DIR"
    echo "=== Active Editions ==="
    for edition in "${!STORAGE_PATHS[@]}"; do
        echo "  $edition: ${STORAGE_PATHS[$edition]}"
    done
    echo ""
    echo "=== Git Status ==="
    git status --short
    echo ""
    echo "=== Workspace Mappings ==="
    find "$DATA_DIR" -name "workspace.json" 2>/dev/null | sort | while read -r wsfile; do
        local id=$(basename "$(dirname "$wsfile")")
        local name=$(get_workspace_name "$(dirname "$wsfile")")
        local uri=$(cat "$wsfile" 2>/dev/null)
        printf "  %-36s  %-20s  %s\n" "$id" "[$name]" "$uri"
    done
}

case "${1:-help}" in
    push)   do_push ;;
    pull)   do_pull ;;
    status) do_status ;;
    *)
        echo "Usage: $0 {push|pull|status}"
        echo ""
        echo "  push   - Sync local chats to repo and push (one commit per workspace)"
        echo "  pull   - Pull from repo and apply to ALL active VS Code editions"
        echo "  status - Show pending changes and workspace mappings"
        exit 1
        ;;
esac
