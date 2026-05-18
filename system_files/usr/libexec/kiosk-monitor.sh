#!/bin/bash

# Configuration (Time in milliseconds)
# 2 minutes = 120000 ms
IDLE_THRESHOLD=120000 
PROMPT_TIMEOUT=30

# State Tracker: Starts as false so we don't reboot an empty computer
has_interacted=false

echo "[+] Kiosk Data Protection Monitor Started."
echo "[+] Status: UNARMED (Waiting for first user interaction...)"

while true; do
    # Query GNOME's Mutter IdleMonitor via D-Bus
    raw_idle=$(gdbus call --session \
                         --dest org.gnome.Mutter.IdleMonitor \
                         --object-path /org/gnome/Mutter/IdleMonitor/Core \
                         --method org.gnome.Mutter.IdleMonitor.GetIdletime)
    
    # Extract the raw millisecond integer
    idle_ms=$(echo "$raw_idle" | awk '{print $2}' | tr -d ',)')

    # SAFEGUARD: Validate that idle_ms is strictly a non-empty integer
    if [[ ! "$idle_ms" =~ ^[0-9]+$ ]]; then
        echo "[!] Warning: Invalid D-Bus response received. Retrying in next cycle..."
        sleep 2
        continue
    fi

    # STATE 1: Unarmed. Wait for the idle time to drop near 0 (signaling a human arrived)
    if [ "$has_interacted" = false ]; then
        if [ "$idle_ms" -lt 2000 ]; then
            has_interacted=true
            echo "[+] User interaction detected! Monitor is now ARMED."
        fi
    
    # STATE 2: Armed. Monitor for 2 minutes of complete inactivity
    else
        if [ "$idle_ms" -ge "$IDLE_THRESHOLD" ]; then
            echo "[!] 2 minutes of inactivity reached. Displaying single-button warning..."

            # Launch the single-button Zenity warning dialog box
            zenity --warning \
                   --title="Inactivity Warning" \
                   --text="Are you still there?\n\nClick the button below to keep working. Otherwise, this computer will automatically restart and wipe all session data in 30 seconds." \
                   --ok-label="I'm still here!" \
                   --timeout=$PROMPT_TIMEOUT \
                   --width=450 \
                   --modal

            # Capture Zenity's exit status
            RESPONSE=$?

            # 0 = User clicked "I'm still here!"
            # 5 = The 30-second timeout expired
            # 1 = User clicked the window "X" close button
            if [ "$RESPONSE" -eq 0 ]; then
                echo "[+] User confirmed presence. Resetting idle tracker."
                # The physical click resets GNOME's idle timer to 0 automatically.
            else
                echo "[-] Timeout reached or dialog closed ($RESPONSE). Executing secure reboot..."
                /usr/bin/systemctl reboot
            fi
        fi
    fi

    # Poll every 2 seconds to keep CPU overhead practically zero
    sleep 2
done