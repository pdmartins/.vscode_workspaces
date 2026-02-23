#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$SCRIPT_DIR"
DATA_DIR="$REPO_DIR/data"

source "$SCRIPT_DIR/lib.sh"
load_env "$SCRIPT_DIR"

GIT_BRANCH="${GIT_BRANCH:-main}"
COMMIT_PREFIX="${COMMIT_PREFIX:-chatsync}"

collect_storage_paths_linux

if [ ${#STORAGE_PATHS[@]} -eq 0 ]; then
    echo "ERROR: No VS Code storage paths found."
    echo "Check VSCODE_EDITIONS and storage path settings in .env"
    exit 1
fi

echo "Active editions: ${!STORAGE_PATHS[*]}"

do_push() {
    mkdir -p "$DATA_DIR"
    cd "$REPO_DIR"

    local pushed=0
    local TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
    local HOSTNAME=$(hostname)

    for edition in "${!STORAGE_PATHS[@]}"; do
        local storage="${STORAGE_PATHS[$edition]}"

        for ws_dir in "$storage"/*/; do
            [ -d "$ws_dir" ] || continue
            local ws_id=$(basename "$ws_dir")

            sync_workspace_to_repo "$ws_id" "$ws_dir" "$DATA_DIR" || continue

            git add "data/$ws_id/" 2>/dev/null || continue

            if ! git diff --cached --quiet -- "data/$ws_id/"; then
                local ws_name=$(get_workspace_name "$DATA_DIR/$ws_id")
                git commit -m "$COMMIT_PREFIX: $HOSTNAME | $ws_name | $TIMESTAMP"
                pushed=1
            fi
        done

        # Global storage
        local global_path
        global_path=$(get_global_storage_linux "$edition")
        if [ -n "$global_path" ]; then
            mkdir -p "$DATA_DIR/_globalStorage"
            rsync -a --update "$global_path/" "$DATA_DIR/_globalStorage/"
        fi
    done

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

    for edition in "${!STORAGE_PATHS[@]}"; do
        local storage="${STORAGE_PATHS[$edition]}"
        echo "Restoring to $edition ($storage)..."

        for ws_data_dir in "$DATA_DIR"/*/; do
            [ -d "$ws_data_dir" ] || continue
            local ws_id=$(basename "$ws_data_dir")
            [ "$ws_id" = "_globalStorage" ] && continue

            local dest_dir="$storage/$ws_id"
            mkdir -p "$dest_dir"
            rsync -a "$ws_data_dir/" "$dest_dir/"
        done

        # Global storage
        if [ -d "$DATA_DIR/_globalStorage" ]; then
            local global_dest
            global_dest=$(get_global_storage_linux "$edition")
            if [ -z "$global_dest" ]; then
                case "$edition" in
                    ssh) global_dest="$HOME/.vscode-server/data/User/globalStorage/GitHub.copilot-chat" ;;
                    *)   global_dest="$(dirname "$storage")/globalStorage/GitHub.copilot-chat" ;;
                esac
            fi
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

do_force_push() {
    echo "Force sync: copying ALL workspaces (ignoring timestamps)..."
    FORCE_SYNC=1 do_push
}

do_status() {
    mkdir -p "$DATA_DIR"

    for edition in "${!STORAGE_PATHS[@]}"; do
        local storage="${STORAGE_PATHS[$edition]}"
        for ws_dir in "$storage"/*/; do
            [ -d "$ws_dir" ] || continue
            sync_workspace_to_repo "$(basename "$ws_dir")" "$ws_dir" "$DATA_DIR" 2>/dev/null || true
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
    push)       do_push ;;
    force-push) do_force_push ;;
    pull)       do_pull ;;
    status)     do_status ;;
    *)
        echo "Usage: $0 {push|force-push|pull|status}"
        echo ""
        echo "  push       - Sync changed workspaces to repo and push"
        echo "  force-push - Sync ALL workspaces ignoring timestamps (for initial sync)"
        echo "  pull       - Pull from repo and apply to ALL active editions"
        echo "  status     - Show pending changes and workspace mappings"
        exit 1
        ;;
esac
