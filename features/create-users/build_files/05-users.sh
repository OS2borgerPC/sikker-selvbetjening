#!/bin/bash

set -ouex pipefail

# ----------------------------
# Kiosk user (public session)
# ----------------------------
useradd -u 1000 -m -s /bin/bash -c "Bruger" bruger

# Passwordless login (required for auto-login setups)
passwd -d bruger

# ----------------------------
# Admin user (maintenance)
# ----------------------------
# Added -G wheel,sudo to attach the user to secondary administrative groups
useradd -u 1001 -m -s /bin/bash -G wheel,sudo -c "Super User" superuser

echo "superuser:superuser" | chpasswd

# Give explicit passwordless sudo access for development convenience
cat > /etc/sudoers.d/superuser <<EOF
superuser ALL=(ALL) NOPASSWD: ALL
EOF

chmod 0440 /etc/sudoers.d/superuser