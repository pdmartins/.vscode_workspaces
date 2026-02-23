#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=== VS Code Chat Sync - Linux Setup ==="

# Make scripts executable
chmod +x "$SCRIPT_DIR/sync.sh"
chmod +x "$SCRIPT_DIR/watcher.sh"
chmod +x "$SCRIPT_DIR/remap.sh"

# Copy .env if not exists
if [ ! -f "$SCRIPT_DIR/.env" ]; then
    cp "$SCRIPT_DIR/.env.example" "$SCRIPT_DIR/.env"
    echo "Created .env from .env.example - edit if needed."
fi

# Check dependencies
if ! command -v inotifywait &>/dev/null; then
    echo "Installing inotify-tools..."
    sudo apt-get update && sudo apt-get install -y inotify-tools
fi

if ! command -v rsync &>/dev/null; then
    echo "Installing rsync..."
    sudo apt-get install -y rsync
fi

# Show detected editions
echo ""
echo "Detected VS Code editions:"
[ -d "$HOME/.config/Code/User/workspaceStorage" ] && echo "  - Stable"
[ -d "$HOME/.config/Code - Insiders/User/workspaceStorage" ] && echo "  - Insiders"

# Create systemd user service
SERVICE_DIR="$HOME/.config/systemd/user"
mkdir -p "$SERVICE_DIR"

cat > "$SERVICE_DIR/vscode-chat-sync.service" << EOF
[Unit]
Description=VS Code Chat Sync Watcher
After=network-online.target

[Service]
Type=simple
WorkingDirectory=$SCRIPT_DIR
ExecStart=$SCRIPT_DIR/watcher.sh
Restart=on-failure
RestartSec=10

[Install]
WantedBy=default.target
EOF

systemctl --user daemon-reload
systemctl --user enable vscode-chat-sync.service
systemctl --user start vscode-chat-sync.service

echo ""
echo "Service installed and started!"
echo ""
echo "Commands:"
echo "  systemctl --user status vscode-chat-sync   # Check status"
echo "  systemctl --user stop vscode-chat-sync      # Stop"
echo "  systemctl --user restart vscode-chat-sync   # Restart"
echo "  journalctl --user -u vscode-chat-sync -f    # View logs"
