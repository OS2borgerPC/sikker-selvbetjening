#!/bin/bash

set -ouex pipefail

# Install overlay entrypoint used by downstream config/image builds.
install -Dm0755 \
	/tmp/features/sikker-overlay-engine/system_files/usr/libexec/sikker-create-overlay \
	/usr/libexec/sikker-create-overlay

# Install overlay playbook tree consumed by sikker-create-overlay.
install -d /usr/libexec/sikker-overlay
cp -a /tmp/features/sikker-overlay-engine/system_files/usr/libexec/sikker-overlay/. /usr/libexec/sikker-overlay/
