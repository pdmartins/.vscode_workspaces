#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/lib.sh"
load_env "$SCRIPT_DIR"

SYNC_INTERVAL="${SYNC_INTERVAL:-30}"
PULL_INTERVAL="${PULL_INTERVAL:-5}"
PULL_INTERVAL_SEC=$((PULL_INTERVAL * 60))

collect_storage_paths_linux

WATCH_PATHS=()
for edition in "${!STORAGE_PATHS[@]}"; do
    WATCH_PATHS+=("${STORAGE_PATHS[$edition]}")
done

if [ ${#WATCH_PATHS[@]} -eq 0 ]; then
    echo "ERROR: No VS Code storage paths found to watch."
    exit 1
fi

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

# Initial pull
echo "[$(date '+%H:%M:%S')] Startup pull..."
bash "$SCRIPT_DIR/sync.sh" pull 2>&1 | tail -1
LAST_PULL=$(date +%s)

while true; do
    inotifywait -r -q -t "$SYNC_INTERVAL" \
        -e modify,create,delete,move \
        "${WATCH_PATHS[@]}" 2>/dev/null && FILE_CHANGED=true || FILE_CHANGED=false

    NOW=$(date +%s)

    if [ "$FILE_CHANGED" = true ]; then
        ELAPSED_PUSH=$((NOW - LAST_PUSH))
        if [ "$ELAPSED_PUSH" -ge "$SYNC_INTERVAL" ]; then
            echo "[$(date '+%H:%M:%S')] Local changes detected, pushing..."
            bash "$SCRIPT_DIR/sync.sh" push 2>&1 | tail -1
            LAST_PUSH=$(date +%s)
        fi
    fi

    ELAPSED_PULL=$((NOW - LAST_PULL))
    if [ "$ELAPSED_PULL" -ge "$PULL_INTERVAL_SEC" ]; then
        echo "[$(date '+%H:%M:%S')] Periodic pull..."
        bash "$SCRIPT_DIR/sync.sh" pull 2>&1 | tail -1
        LAST_PULL=$(date +%s)
    fi
done
