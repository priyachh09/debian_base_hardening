#!/bin/bash

# -------------------------------------------------------------------
# Script: unattended_upgrades_setup.sh
# Description: Install and configure unattended-upgrades for automatic security updates
# -------------------------------------------------------------------

set -euo pipefail

LOGFILE="/var/log/hardening/unattended_upgrades_setup.log"
mkdir -p /var/log/hardening
echo "[*] Starting unattended-upgrades installation and setup at $(date)" | tee -a "$LOGFILE"

echo "[*] Installing unattended-upgrades package..." | tee -a "$LOGFILE"
apt-get update -y >> "$LOGFILE" 2>&1
apt-get install -y unattended-upgrades apt-listchanges >> "$LOGFILE" 2>&1

echo "[*] Enabling unattended-upgrades service..." | tee -a "$LOGFILE"
dpkg-reconfigure -f noninteractive unattended-upgrades

# Configure to allow only security updates
CONFIG_FILE="/etc/apt/apt.conf.d/50unattended-upgrades"

# Backup existing config
if [ -f "$CONFIG_FILE" ]; then
    cp "$CONFIG_FILE" "${CONFIG_FILE}.bak.$(date +%F_%T)"
    echo "[*] Backup of $CONFIG_FILE saved." | tee -a "$LOGFILE"
fi

# Modify config to ensure only security updates get installed automatically
sed -i 's|//\s*"\${distro_id}:\${distro_codename}-security";|"\${distro_id}:\${distro_codename}-security";|' "$CONFIG_FILE"
sed -i 's|//\s*"${distro_id}ESMApps:${distro_codename}-apps-security";|// "${distro_id}ESMApps:${distro_codename}-apps-security";|' "$CONFIG_FILE"
sed -i 's|//\s*"${distro_id}ESM:${distro_codename}-infra-security";|// "${distro_id}ESM:${distro_codename}-infra-security";|' "$CONFIG_FILE"

# Enable automatic reboot if required
REBOOT_CONFIG="/etc/apt/apt.conf.d/20auto-upgrades"
cat > "$REBOOT_CONFIG" <<EOF
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Download-Upgradeable-Packages "1";
APT::Periodic::AutocleanInterval "7";
APT::Periodic::Unattended-Upgrade "1";
Unattended-Upgrade::Automatic-Reboot "true";
Unattended-Upgrade::Automatic-Reboot-Time "03:00";
EOF

echo "[*] unattended-upgrades configuration complete." | tee -a "$LOGFILE"
