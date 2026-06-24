#!/bin/bash
set -euo pipefail

USER="bruger"
HOME_DIR="/var/home/$USER"

echo "[1/4] Terminating user session..."
loginctl terminate-user "$USER" || true
pkill -KILL -u "$USER" || true


echo "[2/4] Clearing runtime state..."
if USER_UID=$(id -u "$USER" 2>/dev/null); then
    rm -rf "/run/user/$USER_UID" || true
fi


echo "[3/4] Wiping home directory..."
if [[ -d "$HOME_DIR" && "$HOME_DIR" == /var/home/* ]]; then
    rm -rf "$HOME_DIR"
else
    echo "ERROR: unsafe HOME_DIR: $HOME_DIR"
    exit 1
fi


echo "[4/4] Generating language-aware XDG home directory..."
# Recreate a completely empty home directory
mkdir -p "$HOME_DIR"

# 1. Read the actual system language configured in the OS
SYSTEM_LANG="en_US.UTF-8" # Fallback default
if [ -f /etc/locale.conf ]; then
    # This reads the actual lines like LANG="da_DK.UTF-8" or LANG="de_DE.UTF-8"
    source /etc/locale.conf
    SYSTEM_LANG=$LANG
fi

# 2. Force runuser to execute XDG with the exact system language injected
runuser -l "$USER" -c "export LANG=$SYSTEM_LANG; xdg-user-dirs-update" || true

# Fix ownership so the user can actually write to their new localized folders
chown -R "$USER:$USER" "$HOME_DIR"

echo "Reset complete."