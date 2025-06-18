#!/bin/bash

# -------------------------------------------------------------------
# Script: aide_setup.sh
# Description: Install and configure AIDE for filesystem integrity monitoring
# -------------------------------------------------------------------

set -euo pipefail

LOGFILE="/var/log/hardening/aide_setup.log"
mkdir -p /var/log/hardening
echo "[*] Starting AIDE setup at $(date)" | tee -a "$LOGFILE"

echo "[*] Installing AIDE..." | tee -a "$LOGFILE"
apt-get update -y >> "$LOGFILE" 2>&1
apt-get install -y aide >> "$LOGFILE" 2>&1

echo "[*] Configuring AIDE to use SHA512 checksums for stronger integrity..." | tee -a "$LOGFILE"
# Backup original config before modification
cp /etc/aide/aide.conf /etc/aide/aide.conf.bak.$(date +%F_%T)

# Set Checksums = sha512 (replace existing Checksums line or add if missing)
if grep -q "^Checksums" /etc/aide/aide.conf; then
    sed -i 's/^Checksums.*/Checksums = sha512/' /etc/aide/aide.conf
else
    echo "Checksums = sha512" >> /etc/aide/aide.conf
fi

echo "[*] Initializing AIDE database..." | tee -a "$LOGFILE"
aideinit >> "$LOGFILE" 2>&1

echo "[*] Replacing old database with the new one..." | tee -a "$LOGFILE"
mv /var/lib/aide/aide.db.new /var/lib/aide/aide.db

echo "[*] Adding daily cron job for AIDE check..." | tee -a "$LOGFILE"
CRON_FILE="/etc/cron.daily/aide"
cat <<EOF > "$CRON_FILE"
#!/bin/sh
/usr/bin/aide --check
EOF
chmod +x "$CRON_FILE"

echo "[*] AIDE setup complete." | tee -a "$LOGFILE"
