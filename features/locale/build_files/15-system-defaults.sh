#!/bin/bash
set -ouex pipefail

# Note: Static configuration files, payloads, and the firstboot systemd service 
# are now distributed automatically by the Containerfile step.

# Suppress GNOME Initial Setup on both system and user levels
install -d /etc/systemd/system /etc/systemd/user
ln -snf /dev/null /etc/systemd/system/gnome-initial-setup.service
ln -snf /dev/null /etc/systemd/user/gnome-initial-setup-first-login.service