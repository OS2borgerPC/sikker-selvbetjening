#!/bin/bash

set -euo pipefail

LOGOUT_TITLE="Log ud?"
LOGOUT_MESSAGE="Er du sikker på, at du vil logge ud?\n\nAlt du har gjort bliver slettet, og du vender tilbage til login-skærmen."
OK_LABEL="Ja, log mig ud"
CANCEL_LABEL="Nej, arbejd videre"

echo "[+] Kiosk Manual Logout Triggered."

zenity --question \
  --title="$LOGOUT_TITLE" \
  --text="$LOGOUT_MESSAGE" \
  --ok-label="$OK_LABEL" \
  --cancel-label="$CANCEL_LABEL" \
  --width=420 \
  --modal

RESPONSE=$?

if [[ "$RESPONSE" -eq 0 ]]; then
    echo "[+] User confirmed logout"

    # Preferred safe GNOME method
    loginctl terminate-session "${XDG_SESSION_ID:-}"

    # Fallback if session ID is missing
    if [[ $? -ne 0 ]]; then
        loginctl terminate-user "$USER"
    fi

else
    echo "[~] Logout canceled"
    exit 0
fi