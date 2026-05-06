#!/bin/bash

set -ouex pipefail

# Enable the Bruger home reset service
systemctl enable sikker-reset-bruger-home.service