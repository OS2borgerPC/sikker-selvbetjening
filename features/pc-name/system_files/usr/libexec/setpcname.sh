#!/bin/bash

# Check if the hostname file does not exist
if [ ! -f /etc/hostname ]; then

    # Read the system serial number using the dmidecode command
    SERIAL=$(dmidecode -s system-serial-number 2>/dev/null | tr -d '[:space:]')

    # If the serial number is empty, missing, or contains generic OEM text
    if [ -z "$SERIAL" ] || [[ "$SERIAL" =~ [Oo][Ee][Mm] ]] || [ "$SERIAL" = "NotSpecified" ]; then
        # Fallback: Get the MAC address of the first active Ethernet/Wi-Fi interface
        # We strip the colons (:) because hostnames cannot legally contain them
        FINAL_STRING=$(ip link | grep -m1 'link/ether' | awk '{print $2}' | tr -d ':' | tr -d '[:space:]')
        
        # Absolute safety net: if even the MAC address fails, use a generic timestamped string
        if [ -z "$FINAL_STRING" ]; then
            FINAL_STRING="unknown-device"
        fi
    else
        FINAL_STRING="$SERIAL"
    fi

    # Create the missing file with the final string as content
    echo "$FINAL_STRING" > /etc/hostname
    echo "Created /etc/hostname with value: $FINAL_STRING"
else
    echo "/etc/hostname already exists. No action taken."
fi