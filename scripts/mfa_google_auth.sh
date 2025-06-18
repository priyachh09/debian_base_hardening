#!/bin/bash

# -------------------------------------------------------------------
# Script: mfa_google_auth.sh
# Description: Install and configure Google Authenticator PAM for SSH MFA
# -------------------------------------------------------------------

set -euo pipefail

LOGFILE="/var/log/hardening/mfa_google_auth.log"
mkdir -p /var/log/hardening
echo "[*] Starting Google Authenticator MFA setup at $(date)" | tee -a "$LOGFILE"

echo "[*] Installing google-authenticator-libpam package..." | tee -a "$LOGFILE"
apt-get update -y >> "$LOGFILE" 2>&1
apt-get install -y libpam-google-authenticator >> "$LOGFILE" 2>&1

PAM_SSH_FILE="/etc/pam.d/sshd"
BACKUP_FILE="/etc/pam.d/sshd.bak.$(date +%F_%T)"
cp "$PAM_SSH_FILE" "$BACKUP_FILE"
echo "[*] Backup of $PAM_SSH_FILE saved as $BACKUP_FILE" | tee -a "$LOGFILE"

# Add Google Authenticator PAM line if not already present
if ! grep -q "pam_google_authenticator.so" "$PAM_SSH_FILE"; then
    echo "auth required pam_google_authenticator.so nullok" >> "$PAM_SSH_FILE"
    echo "[*] Added pam_google_authenticator to $PAM_SSH_FILE" | tee -a "$LOGFILE"
else
    echo "[*] pam_google_authenticator already configured in $PAM_SSH_FILE" | tee -a "$LOGFILE"
fi

# Configure SSH to use challenge-response authentication
SSHD_CONFIG="/etc/ssh/sshd_config"
SSHD_BACKUP="/etc/ssh/sshd_config.bak.$(date +%F_%T)"
cp "$SSHD_CONFIG" "$SSHD_BACKUP"
echo "[*] Backup of $SSHD_CONFIG saved as $SSHD_BACKUP" | tee -a "$LOGFILE"

# Modify sshd_config settings
sed -i 's/^#\?\s*ChallengeResponseAuthentication.*/ChallengeResponseAuthentication yes/' "$SSHD_CONFIG"
sed -i 's/^#\?\s*UsePAM.*/UsePAM yes/' "$SSHD_CONFIG"

echo "[*] SSHD config updated to allow MFA." | tee -a "$LOGFILE"

# Restart SSH to apply changes
systemctl restart ssh

echo "[*] Google Authenticator PAM configuration complete." | tee -a "$LOGFILE"
echo "[*] Each user must now run 'google-authenticator' to generate their MFA secret." | tee -a "$LOGFILE"
