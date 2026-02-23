#!/bin/bash
set -euo pipefail

# Remaps workspace IDs when project paths differ between machines.
# Example: Your project is at /home/pedro/projects/app on Linux
#          but at C:\Users\Pedro\projects\app on Windows
#
# Usage: ./remap.sh "/old/path/prefix" "/new/path/prefix"
#   or:  ./remap.sh  (interactive mode)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DATA_DIR="$SCRIPT_DIR/data"

if [ ! -d "$DATA_DIR" ]; then
    echo "ERROR: No data directory. Run 'sync.sh pull' first."
    exit 1
fi

if [ $# -ge 2 ]; then
    OLD_PREFIX="$1"
    NEW_PREFIX="$2"
else
    echo "=== Workspace Path Remapper ==="
    echo ""
    echo "Current workspace mappings:"
    echo ""
    find "$DATA_DIR" -name "workspace.json" -exec sh -c '
        id=$(basename "$(dirname "{}")")
        content=$(cat "{}")
        printf "  %-36s → %s\n" "$id" "$content"
    ' \;
    echo ""
    read -p "Old path prefix (e.g., /home/pedro): " OLD_PREFIX
    read -p "New path prefix (e.g., C:/Users/Pedro): " NEW_PREFIX
fi

echo ""
echo "Remapping: $OLD_PREFIX → $NEW_PREFIX"
echo ""

# URL-encode the prefixes for URI matching
old_encoded=$(python3 -c "import urllib.parse; print(urllib.parse.quote('$OLD_PREFIX', safe='/:'))")
new_encoded=$(python3 -c "import urllib.parse; print(urllib.parse.quote('$NEW_PREFIX', safe='/:'))")

count=0
find "$DATA_DIR" -name "workspace.json" | while read -r wsfile; do
    content=$(cat "$wsfile")
    if echo "$content" | grep -q "$old_encoded"; then
        new_content=$(echo "$content" | sed "s|$old_encoded|$new_encoded|g")
        
        old_id=$(basename "$(dirname "$wsfile")")
        echo "  Remapped: $content"
        echo "       To:  $new_content"
        
        echo "$new_content" > "$wsfile"
        count=$((count + 1))
    fi
done

echo ""
echo "Remapped $count workspace(s)."
echo "Run 'sync.sh push' to save, or 'sync.sh pull' on the target machine."
