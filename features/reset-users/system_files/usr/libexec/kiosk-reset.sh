#!/bin/bash
set -euo pipefail

USER="bruger"
HOME_DIR="/var/home/$USER"

echo "[1/4] Terminating user session..."

# Kill systemd user session cleanly first
loginctl terminate-user "$USER" || true

# Hard kill any remaining processes
pkill -KILL -u "$USER" || true


echo "[2/4] Clearing runtime state..."

# Runtime/session data (DBus, keyring sockets, etc.)
rm -rf /run/user/* || true


echo "[3/4] Wiping home directory..."

# Safety check (prevents catastrophic deletes if variable is empty)
if [[ -d "$HOME_DIR" && "$HOME_DIR" == /var/home/* ]]; then
    rm -rf "$HOME_DIR"
else
    echo "ERROR: unsafe HOME_DIR: $HOME_DIR"
    exit 1
fi


echo "[4/4] Restoring clean home skeleton..."

# Recreate empty home
mkdir -p "$HOME_DIR"

# Restore system language-aware directories
runuser -u "$USER" -- xdg-user-dirs-update || true

# Fix ownership
chown -R "$USER:$USER" "$HOME_DIR"


echo "Reset complete."