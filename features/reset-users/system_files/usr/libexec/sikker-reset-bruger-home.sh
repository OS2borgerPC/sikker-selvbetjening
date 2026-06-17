#!/usr/bin/env bash
set -euo pipefail

USERNAME="Bruger"
BRUGER_HOME="/var/home/$USERNAME"
TEMPLATE_DIR="/usr/Home"

echo "Resetting user: $USERNAME"

# Kill any remaining processes just in case
if id "$USERNAME" &>/dev/null; then
    loginctl terminate-user "$USERNAME" || true
    pkill -u "$USERNAME" || true
    
    # Give systemd a brief moment to clear the user session bus
    sleep 1

    # Remove user and home directory
    userdel -r "$USERNAME" || true
fi

# Recreate the user
useradd \
    --create-home \
    --home-dir "$BRUGER_HOME" \
    --shell /bin/bash \
    "$USERNAME"

# Fix ownership
chown -R "$USERNAME:$USERNAME" "$BRUGER_HOME"

# Restore correct SELinux labels if available
if command -v restorecon &>/dev/null; then
    restorecon -RF "$BRUGER_HOME" || true
fi

echo "User $USERNAME recreated successfully."

# Force GDM to restart and trigger autologin for the fresh user
echo "Restarting GNOME Display Manager..."
systemctl restart gdm