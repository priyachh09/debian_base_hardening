#!/bin/bash

# -------------------------------------------------------------------
# Script: ufw_setup.sh
# Description: Install and configure UFW firewall with strict default rules
# -------------------------------------------------------------------

set -euo pipefail

LOGFILE="/var/log/hardening/ufw_setup.log"
mkdir -p /var/log/hardening
echo "[*] Starting UFW installation and configuration at $(date)" | tee -a "$LOGFILE"

SSH_PORT=2222

echo "[*] Installing ufw package..." | tee -a "$LOGFILE"
apt-get update -y >> "$LOGFILE" 2>&1
apt-get install -y ufw >> "$LOGFILE" 2>&1

echo "[*] Resetting UFW to default state..." | tee -a "$LOGFILE"
ufw --force reset >> "$LOGFILE" 2>&1

echo "[*] Setting default policies: deny incoming, allow outgoing..." | tee -a "$LOGFILE"
ufw default deny incoming >> "$LOGFILE" 2>&1
ufw default allow outgoing >> "$LOGFILE" 2>&1

echo "[*] Allowing SSH on port $SSH_PORT/tcp..." | tee -a "$LOGFILE"
ufw allow "$SSH_PORT/tcp" >> "$LOGFILE" 2>&1

echo "[*] Enabling UFW firewall..." | tee -a "$LOGFILE"
ufw --force enable >> "$LOGFILE" 2>&1

echo "[*] Current UFW status:" | tee -a "$LOGFILE"
ufw status verbose | tee -a "$LOGFILE"

echo "[*] UFW setup complete." | tee -a "$LOGFILE"
