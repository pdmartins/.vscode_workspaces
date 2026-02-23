#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Load .env
if [ -f "$SCRIPT_DIR/.env" ]; then
    export $(grep -v '^#' "$SCRIPT_DIR/.env" | grep -v '^\s*$' | xargs)
fi

SYNC_INTERVAL="${SYNC_INTERVAL:-30}"
PULL_INTERVAL="${PULL_INTERVAL:-5}"
PULL_INTERVAL_SEC=$((PULL_INTERVAL * 60))
VSCODE_EDITIONS="${VSCODE_EDITIONS:-stable,insiders}"

# Collect watch paths
WATCH_PATHS=()

IFS=',' read -ra EDITIONS <<< "$VSCODE_EDITIONS"
for edition in "${EDITIONS[@]}"; do
    edition=$(echo "$edition" | tr -d ' ')
    case "$edition" in
        stable)
            p="${VSCODE_STORAGE_PATH_STABLE:-$HOME/.config/Code/User/workspaceStorage}"
            ;;
        insiders)
            p="${VSCODE_STORAGE_PATH_INSIDERS:-$HOME/.config/Code - Insiders/User/workspaceStorage}"
            ;;
    esac
    if [ -d "$p" ]; then
        WATCH_PATHS+=("$p")
    fi
done

if [ ${#WATCH_PATHS[@]} -eq 0 ]; then
    echo "ERROR: No VS Code storage paths found to watch."
    exit 1
fi

# Check for inotifywait
if ! command -v inotifywait &>/dev/null; then
    echo "Installing inotify-tools..."
    sudo apt-get install -y inotify-tools
fi

echo "=== VS Code Chat Sync Watcher ==="
for p in "${WATCH_PATHS[@]}"; do
    echo "Watching: $p"
done
echo "Push debounce: ${SYNC_INTERVAL}s"
echo "Pull interval: ${PULL_INTERVAL}min"
echo "Press Ctrl+C to stop"

LAST_PUSH=0
LAST_PULL=0

# Initial pull on startup
echo "[$(date '+%H:%M:%S')] Startup pull..."
bash "$SCRIPT_DIR/sync.sh" pull 2>&1 | tail -1
LAST_PULL=$(date +%s)

while true; do
    # Watch all paths simultaneously
    inotifywait -r -q -t "$SYNC_INTERVAL" \
        --include '(GitHub\.copilot-chat|workspace\.json)' \
        -e modify,create,delete,move \
        "${WATCH_PATHS[@]}" 2>/dev/null && FILE_CHANGED=true || FILE_CHANGED=false

    NOW=$(date +%s)

    # Push on local changes (with debounce)
    if [ "$FILE_CHANGED" = true ]; then
        ELAPSED_PUSH=$((NOW - LAST_PUSH))
        if [ "$ELAPSED_PUSH" -ge "$SYNC_INTERVAL" ]; then
            echo "[$(date '+%H:%M:%S')] Local changes detected, pushing..."
            bash "$SCRIPT_DIR/sync.sh" push 2>&1 | tail -1
            LAST_PUSH=$(date +%s)
        fi
    fi

    # Periodic pull
    ELAPSED_PULL=$((NOW - LAST_PULL))
    if [ "$ELAPSED_PULL" -ge "$PULL_INTERVAL_SEC" ]; then
        echo "[$(date '+%H:%M:%S')] Periodic pull..."
        bash "$SCRIPT_DIR/sync.sh" pull 2>&1 | tail -1
        LAST_PULL=$(date +%s)
    fi
done
