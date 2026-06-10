#!/bin/bash
set -euo pipefail

TARGET_USER="Bruger"

# Forcefully log out the user and kill all processes
pkill -KILL -u "$TARGET_USER" || true
sleep 1

# Delete the user and completely wipe data
userdel -r "$TARGET_USER" || true
rm -rf "/home/$TARGET_USER"

# Recreate a fresh kiosk account
useradd -m -s /bin/bash "$TARGET_USER"

# Restart the login screen to trigger the custom.conf autologin
systemctl restart display-manager
