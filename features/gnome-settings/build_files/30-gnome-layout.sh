#!/bin/bash
set -ouex pipefail

# Note: The configuration files under etc/dconf/db/local.d/ 
# are already copied into place automatically by the Containerfile.

# Compile the dconf database so the system recognizes the new settings
dconf update