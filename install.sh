#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_DIR="${HOME}/.local/bin"
HOOKS_DIR="${HOME}/.claude/hooks"

# Check dependencies
for cmd in python3 jq; do
    if ! command -v "$cmd" &>/dev/null; then
        echo "Error: $cmd is required but not installed." >&2
        exit 1
    fi
done

echo "Installing claude-waybar-status..."

# Create directories
mkdir -p "$BIN_DIR"
mkdir -p "$HOOKS_DIR"

# Install scripts
install -m 755 "$SCRIPT_DIR/waybar-claude-status.py" "$BIN_DIR/"
install -m 755 "$SCRIPT_DIR/hooks/waybar-status.sh" "$HOOKS_DIR/"

echo ""
echo "Installation complete."
echo ""
echo "Next steps:"
echo ""
echo "1. Add hooks to ~/.claude/settings.json (see README.md for config)"
echo ""
echo "2. Add this to your waybar config:"
echo '   "custom/claude-status": {'
echo '     "exec": "~/.local/bin/waybar-claude-status.py",'
echo '     "return-type": "json",'
echo '     "interval": 1'
echo '   }'
