#!/bin/bash

# Read the system serial number using the dmidecode command
SERIAL=$(dmidecode -s system-serial-number 2>/dev/null | tr -d '[:space:]')

# If the serial number is empty, missing, or contains generic OEM text
if [ -z "$SERIAL" ] || [[ "$SERIAL" =~ [Oo][Ee][Mm] ]] || [ "$SERIAL" = "NotSpecified" ]; then
    # Fallback: Get the MAC address of the first active Ethernet/Wi-Fi interface
    FINAL_STRING=$(ip link | grep -m1 'link/ether' | awk '{print $2}' | tr -d ':' | tr -d '[:space:]')
    
    # Absolute safety net: if even the MAC address fails, use a generic fallback
    if [ -z "$FINAL_STRING" ]; then
        FINAL_STRING="unknown-device"
    fi
else
    FINAL_STRING="$SERIAL"
fi

# Sanitize: Enforce lowercase to comply with strict DNS hostname RFC standards
FINAL_STRING="${FINAL_STRING,,}"

# Get the current static hostname
CURRENT_HOSTNAME=$(hostnamectl --static status 2>/dev/null || hostname)

# If the current hostname doesn't match our target string, update it
if [ "$CURRENT_HOSTNAME" != "$FINAL_STRING" ]; then
    echo "Hostname mismatch detected (Current: '$CURRENT_HOSTNAME' vs Target: '$FINAL_STRING')."
    echo "Setting hostname to: $FINAL_STRING"
    hostnamectl set-hostname "$FINAL_STRING"
else
    echo "Hostname is already up to date ('$CURRENT_HOSTNAME'). No action taken."
fi

# 🔑 Stamp the filesystem so the systemd service skips all future boots
touch /etc/.hostname-initialized
echo "First-boot initialization flag created."