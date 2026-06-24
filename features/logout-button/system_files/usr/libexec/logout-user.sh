#!/bin/bash

set -euo pipefail

LOGOUT_TITLE="Log ud?"
LOGOUT_MESSAGE="Er du sikker på, at du vil logge ud?\n\nAlt du har gjort bliver slettet, og du vender tilbage til login-skærmen."
OK_LABEL="Ja, log mig ud"
CANCEL_LABEL="Nej, arbejd videre"

echo "[+] Kiosk Manual Logout Triggered."

# Use Zenity to prompt the user
if zenity --question \
  --title="$LOGOUT_TITLE" \
  --text="$LOGOUT_MESSAGE" \
  --ok-label="$OK_LABEL" \
  --cancel-label="$CANCEL_LABEL" \
  --width=420 \
  --modal; then

    echo "[+] User confirmed logout. Requesting GNOME session termination..."
    gnome-session-quit --logout --no-prompt

else
    echo "[~] Logout canceled"
    exit 0
fi