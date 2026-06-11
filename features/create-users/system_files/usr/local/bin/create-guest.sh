#!/bin/bash
set -euo pipefail

# 1. Load the global guest username config
if [ -f /etc/guest-user.conf ]; then 
    source /etc/guest-user.conf 
else 
    GUEST_USER="Bruger" 
fi

echo "[!] Boot sequence: Cleaning up any old data for $GUEST_USER..."

# 2. Hard purge if the user somehow left data from a crash
if id "$GUEST_USER" >/dev/null 2>&1; then
    userdel -r "$GUEST_USER" || true
    rm -rf "/home/$GUEST_USER"
fi

# 3. Recreate the user assigned to the immutable passwordless login group
getent group nopasswdlogin >/dev/null || groupadd -r nopasswdlogin
useradd -m -s /bin/bash -G "nopasswdlogin" "$GUEST_USER"
passwd -d "$GUEST_USER"