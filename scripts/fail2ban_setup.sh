#!/bin/bash

# -------------------------------------------------------------------
# Script: fail2ban_setup.sh
# Description: Install and configure Fail2Ban for SSH brute-force protection
# -------------------------------------------------------------------

set -euo pipefail

LOGFILE="/var/log/hardening/fail2ban_setup.log"
mkdir -p /var/log/hardening
echo "[*] Starting Fail2Ban installation and setup at $(date)" | tee -a "$LOGFILE"

echo "[*] Installing fail2ban package..." | tee -a "$LOGFILE"
apt-get update -y >> "$LOGFILE" 2>&1
apt-get install -y fail2ban >> "$LOGFILE" 2>&1

FAIL2BAN_JAIL_LOCAL="/etc/fail2ban/jail.local"

# Backup existing jail.local if exists
if [ -f "$FAIL2BAN_JAIL_LOCAL" ]; then
    cp "$FAIL2BAN_JAIL_LOCAL" "${FAIL2BAN_JAIL_LOCAL}.bak.$(date +%F_%T)"
    echo "[*] Backup of $FAIL2BAN_JAIL_LOCAL saved." | tee -a "$LOGFILE"
fi

# Create or overwrite jail.local with basic SSH protection config
cat > "$FAIL2BAN_JAIL_LOCAL" <<EOF
[DEFAULT]
bantime  = 3600
findtime  = 600
maxretry = 5
destemail = root@localhost
sender = fail2ban@$(hostname)
mta = sendmail
action = %(action_mwl)s

[sshd]
enabled = true
port    = ssh
logpath = /var/log/auth.log
maxretry = 5
EOF

echo "[*] Restarting Fail2Ban service..." | tee -a "$LOGFILE"
systemctl restart fail2ban
systemctl enable fail2ban

echo "[*] Fail2Ban installation and configuration complete." | tee -a "$LOGFILE"
