#!/bin/bash

# ---------------------------------------------------
# disable_unused_accounts.sh
# Disables known unused or system accounts
# ---------------------------------------------------

set -euo pipefail

LOGFILE="/var/log/hardening/disable_unused_accounts.log"
mkdir -p "$(dirname "$LOGFILE")"
echo "[*] Starting unused account disabling at $(date)" | tee -a "$LOGFILE"

ACCOUNTS=(
  sync games lp mail news uucp proxy www-data
  backup list irc gnats nobody
)

for user in "${ACCOUNTS[@]}"; do
  if id "$user" &>/dev/null; then
    echo "[*] Locking: $user" | tee -a "$LOGFILE"
    usermod -L "$user" 2>>"$LOGFILE" || true
  else
    echo "[*] Skipping nonexistent: $user" | tee -a "$LOGFILE"
  fi
done

echo "[+] Finished disabling unused accounts." | tee -a "$LOGFILE"
