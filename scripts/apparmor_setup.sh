#!/bin/bash

# -------------------------------------------------------------------
# Script: apparmor_setup.sh
# Description: Install and enable AppArmor for process isolation
# -------------------------------------------------------------------

set -euo pipefail

LOGFILE="/var/log/hardening/apparmor_setup.log"
mkdir -p /var/log/hardening
echo "[*] Starting AppArmor setup at $(date)" | tee -a "$LOGFILE"

echo "[*] Installing AppArmor and utilities..." | tee -a "$LOGFILE"
apt-get update -y >> "$LOGFILE" 2>&1
apt-get install -y apparmor apparmor-utils apparmor-profiles apparmor-profiles-extra >> "$LOGFILE" 2>&1

echo "[*] Enabling AppArmor service..." | tee -a "$LOGFILE"
systemctl enable apparmor >> "$LOGFILE" 2>&1
systemctl start apparmor >> "$LOGFILE" 2>&1

echo "[*] Ensuring AppArmor is in enforce mode for loaded profiles..." | tee -a "$LOGFILE"
aa-enforce /etc/apparmor.d/* 2>/dev/null | tee -a "$LOGFILE"

echo "[*] AppArmor setup complete." | tee -a "$LOGFILE"
