#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ZSHRC_TARGET="$HOME/.zshrc"

# Backup .zshrc if existing
if [ -f "$ZSHRC_TARGET" ] || [ -L "$ZSHRC_TARGET" ]; then
    mv "$ZSHRC_TARGET" "$ZSHRC_TARGET.backup"
    echo "Save existing ~/.zshrc file as ~/.zshrc.backup for backup"
fi

# Create symlink
ln -s "$SCRIPT_DIR/.zshrc" "$ZSHRC_TARGET"
echo "New symlink: ~/.zshrc → $SCRIPT_DIR/.zshrc"
