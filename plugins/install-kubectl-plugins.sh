#!/usr/bin/env bash
# Installs kubectl plugins from the plugins/ directory to /usr/local/bin

set -euo pipefail

INSTALL_DIR="/usr/local/bin"

echo "Installing kubectl plugins..."

for plugin in k8s/*; do
    name=$(basename "$plugin")
    sudo cp "$plugin" "$INSTALL_DIR/$name"
    sudo chmod +x "$INSTALL_DIR/$name"
    echo "Installed $name"
done

echo ""
echo "Installation complete"
echo "Run plugins using: kubectl <plugin>"
