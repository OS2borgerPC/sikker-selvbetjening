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


echo "[4/4] Generating language-aware XDG home directory with system skeleton..."
# 1. Recreate a completely empty home directory base
mkdir -p "$HOME_DIR"

# 2. Copy the system skeleton files (.bashrc, .bash_profile, etc.)
# This restores your normal prompt and fixes the terminal environment variables
if [ -d /etc/skel ]; then
    cp -a /etc/skel/. "$HOME_DIR/"
fi

# 3. Read the actual system language configured in the OS
SYSTEM_LANG="en_US.UTF-8" # Fallback default
if [ -f /etc/locale.conf ]; then
    source /etc/locale.conf
    SYSTEM_LANG=$LANG
fi

# 4. Force runuser to execute XDG with the exact system language injected
# XDG will look at $SYSTEM_LANG and generate perfectly localized folders
runuser -l "$USER" -c "export LANG=$SYSTEM_LANG; xdg-user-dirs-update" || true

# 5. Securely fix ownership across the entire newly generated tree
chown -R "$USER:$USER" "$HOME_DIR"

echo "Reset complete."