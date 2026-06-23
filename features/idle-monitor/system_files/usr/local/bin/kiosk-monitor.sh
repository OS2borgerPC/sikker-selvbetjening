#!/bin/bash

set -euo pipefail

# 2 minutes
IDLE_THRESHOLD=120000
PROMPT_TIMEOUT=30

WARNING_TITLE="Inaktivitet opdaget"
WARNING_MESSAGE="Er du der stadig?\n\nHvis du ikke reagerer, bliver du logget ud."
BUTTON_LABEL="Jeg er her stadig"

echo "[+] Kiosk idle monitor started"

while true; do

    # Get idle time (ms)
    raw_idle=$(gdbus call --session \
        --dest org.gnome.Mutter.IdleMonitor \
        --object-path /org/gnome/Mutter/IdleMonitor/Core \
        --method org.gnome.Mutter.IdleMonitor.GetIdletime)

    idle_ms=$(echo "$raw_idle" | grep -oE '[0-9]+' | head -n1)
    
    # Validate
    [[ "$idle_ms" =~ ^[0-9]+$ ]] || { sleep 2; continue; }

    # Only act when threshold is reached
    if (( idle_ms >= IDLE_THRESHOLD )); then

        echo "[!] Idle threshold reached"

        zenity --warning \
            --title="$WARNING_TITLE" \
            --text="$WARNING_MESSAGE" \
            --ok-label="$BUTTON_LABEL" \
            --timeout="$PROMPT_TIMEOUT" \
            --width=450 \
            --modal

        RESPONSE=$?

        if (( RESPONSE == 0 )); then
            echo "[+] User active → logging out"
            loginctl terminate-user "$USER"
        else
            echo "[~] No response → continuing session"
        fi

        # prevent immediate retrigger spam
        sleep $PROMPT_TIMEOUT
    fi

    sleep 2
done