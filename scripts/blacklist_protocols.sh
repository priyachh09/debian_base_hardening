#!/bin/bash

# -------------------------------------------------------------------
# Script: blacklist_protocols.sh
# Description: Disable insecure or deprecated network protocols
# -------------------------------------------------------------------

set -euo pipefail

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root. Exiting."
   exit 1
fi

LOGFILE="/var/log/hardening/blacklist_protocols.log"
mkdir -p /var/log/hardening
echo "[*] Starting protocol blacklisting at $(date)" | tee -a "$LOGFILE"

# Create modprobe blacklist config file
BLACKLIST_FILE="/etc/modprobe.d/blacklist-insecure.conf"

echo "[*] Writing blacklist entries to $BLACKLIST_FILE" | tee -a "$LOGFILE"
cat <<EOF > "$BLACKLIST_FILE"
# Disable uncommon and insecure networking protocols
blacklist dccp
blacklist sctp
blacklist rds
blacklist tipc
blacklist bluetooth
blacklist usb-storage
install cramfs /bin/true
install freevxfs /bin/true
install jffs2 /bin/true
install hfs /bin/true
install hfsplus /bin/true
install squashfs /bin/true
install udf /bin/true
install vfat /bin/true
EOF

echo "[*] Updating initramfs to apply blacklist..." | tee -a "$LOGFILE"
update-initramfs -u >> "$LOGFILE" 2>&1

echo "[*] Protocol blacklisting complete." | tee -a "$LOGFILE"
