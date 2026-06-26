#!/bin/bash

set -euo pipefail

# 1 hour (in milliseconds)
IDLE_THRESHOLD=3600000
PROMPT_TIMEOUT=30

WARNING_TITLE="Inaktivitet opdaget"
WARNING_MESSAGE="Er du der stadig?\n\nHvis du ikke reagerer, bliver du logget ud."
BUTTON_LABEL="Jeg er her stadig"

# Get current idle time (ms) from GNOME Mutter
raw_idle=$(gdbus call --session \
    --dest org.gnome.Mutter.IdleMonitor \
    --object-path /org/gnome/Mutter/IdleMonitor/Core \
    --method org.gnome.Mutter.IdleMonitor.GetIdletime)

idle_ms=$(echo "$raw_idle" | grep -oE '[0-9]+' | head -n1)

# Validate we got a number back
[[ "$idle_ms" =~ ^[0-9]+$ ]] || exit 0

# Convert metrics to seconds for clean comparison
idle_sec=$(( idle_ms / 1000 ))
threshold_sec=$(( IDLE_THRESHOLD / 1000 ))

# Calculate exactly how many seconds this user session has been alive
session_start=$(stat -c %Y "$XDG_RUNTIME_DIR")
now=$(date +%s)
session_sec=$(( now - session_start ))

# CRITICAL KIOSK CHECK: If idle time is equal to (or within 5s of) the session age,
# it means the mouse/keyboard has NEVER been touched since the browser opened.
# Exit immediately and let the browser stand open.
if (( idle_sec >= (session_sec - 5) )); then
    exit 0
fi

# If the user is currently active, exit immediately
if (( idle_sec < threshold_sec )); then
    exit 0
fi

echo "[!] Active session has gone idle. Displaying warning prompt..."

zenity --warning \
    --title="$WARNING_TITLE" \
    --text="$WARNING_MESSAGE" \
    --ok-label="$BUTTON_LABEL" \
    --timeout="$PROMPT_TIMEOUT" \
    --width=450 \
    --modal

RESPONSE=$?

if (( RESPONSE == 0 )); then
    echo "[+] User clicked button → continuing session"
    # GNOME automatically resets its idle counter to 0 because the user clicked OK.
else
    echo "[!] No response or timeout → logging out user"
    loginctl terminate-user "$USER"
fi