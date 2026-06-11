#!/bin/bash

set -ouex pipefail

# this is the default admin user, created once during image build. 
# used in development

useradd -u 1000 -m -s /bin/bash -c "Super User" superuser

# Set password
echo "superuser:superuser" | chpasswd

# Allow sudo with password required
echo "superuser ALL=(ALL) ALL" >> /etc/sudoers.d/superuser
chmod 0440 /etc/sudoers.d/superuser
