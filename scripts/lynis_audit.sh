#!/bin/bash

# -------------------------------------------------------------------
# Script: lynis_audit.sh
# Description: Install Lynis and perform a security audit scan (simple)
# -------------------------------------------------------------------

set -euo pipefail

LOGFILE="/var/log/hardening/lynis_audit.log"
mkdir -p /var/log/hardening
echo "[*] Starting Lynis installation and audit at $(date)" | tee -a "$LOGFILE"

echo "[*] Updating package list and installing lynis..." | tee -a "$LOGFILE"
apt-get update -y >> "$LOGFILE" 2>&1
apt-get install -y lynis >> "$LOGFILE" 2>&1

echo "[*] Running Lynis audit..." | tee -a "$LOGFILE"
lynis audit system >> "$LOGFILE" 2>&1

echo "[*] Lynis audit complete. Review log at $LOGFILE" | tee -a "$LOGFILE"
