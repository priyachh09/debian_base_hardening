#!/bin/bash

# -------------------------------------------------------------------
# Script: rsyslog_logrotate_setup.sh
# Description: Configure rsyslog and logrotate for log management
# -------------------------------------------------------------------

set -euo pipefail

LOGFILE="/var/log/hardening/rsyslog_logrotate_setup.log"
mkdir -p /var/log/hardening
echo "[*] Starting rsyslog and logrotate configuration at $(date)" | tee -a "$LOGFILE"

echo "[*] Installing rsyslog and logrotate packages..." | tee -a "$LOGFILE"
apt-get update -y >> "$LOGFILE" 2>&1
apt-get install -y rsyslog logrotate >> "$LOGFILE" 2>&1

echo "[*] Ensuring rsyslog service is enabled and started..." | tee -a "$LOGFILE"
systemctl enable rsyslog
systemctl restart rsyslog

# Basic logrotate config for /var/log/syslog and auth.log (Debian defaults are usually sufficient)
LOGROTATE_CONF="/etc/logrotate.d/rsyslog"

# Backup existing config if present
if [ -f "$LOGROTATE_CONF" ]; then
    cp "$LOGROTATE_CONF" "${LOGROTATE_CONF}.bak.$(date +%F_%T)"
    echo "[*] Backup of $LOGROTATE_CONF saved." | tee -a "$LOGFILE"
fi

cat > "$LOGROTATE_CONF" <<EOF
/var/log/syslog
{
    rotate 7
    daily
    missingok
    notifempty
    delaycompress
    compress
    postrotate
        /usr/lib/rsyslog/rsyslog-rotate
    endscript
}

/var/log/auth.log
{
    rotate 7
    weekly
    missingok
    notifempty
    delaycompress
    compress
    postrotate
        /usr/lib/rsyslog/rsyslog-rotate
    endscript
}
EOF

echo "[*] Logrotate configuration for rsyslog created." | tee -a "$LOGFILE"

echo "[*] Forcing logrotate run to test configuration..." | tee -a "$LOGFILE"
logrotate -f "$LOGROTATE_CONF" >> "$LOGFILE" 2>&1

# Add legal banners as Lynis recommends
echo "[*] Adding legal login banners..." | tee -a "$LOGFILE"

cat > /etc/issue <<EOF
Unauthorized access to this system is prohibited.
All activities may be monitored and reported.
EOF

cat > /etc/issue.net <<EOF
Unauthorized access to this system is prohibited.
All activities may be monitored and reported.
EOF

echo "[*] Legal banners added." | tee -a "$LOGFILE"

echo "[*] rsyslog and logrotate setup complete." | tee -a "$LOGFILE"
