#!/bin/bash

set -ouex pipefail

# Install build entrypoint used by downstream config/image builds.
install -Dm0755 \
	/tmp/features/sikker-overlay-engine/system_files/usr/libexec/sikker-build-image \
	/usr/libexec/sikker-build-image

# Install post-steps entrypoint used by downstream config/image builds.
install -Dm0755 \
	/tmp/features/sikker-overlay-engine/system_files/usr/libexec/sikker-run-post-steps \
	/usr/libexec/sikker-run-post-steps

# Install overlay playbook tree consumed by sikker-build-image.
install -d /usr/libexec/sikker-overlay
cp -a /tmp/features/sikker-overlay-engine/system_files/usr/libexec/sikker-overlay/. /usr/libexec/sikker-overlay/
