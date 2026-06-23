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
useradd -u 1001 -m -s /bin/bash -c "Super User" superuser

echo "superuser:superuser" | chpasswd

# Give sudo access (clean file, not append)
cat > /etc/sudoers.d/superuser <<EOF
superuser ALL=(ALL) ALL
EOF

chmod 0440 /etc/sudoers.d/superuser