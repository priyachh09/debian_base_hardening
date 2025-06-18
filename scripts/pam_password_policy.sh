#!/bin/bash

# -------------------------------------------------------------------
# Script: pam_password_policy.sh
# Description: Configure PAM password quality and complexity policies,
#              stronger password hashing rounds, and stricter umask
# -------------------------------------------------------------------

set -euo pipefail

LOGFILE="/var/log/hardening/pam_password_policy.log"
mkdir -p /var/log/hardening
echo "[*] Starting PAM password policy hardening at $(date)" | tee -a "$LOGFILE"

echo "[*] Installing required packages: libpam-pwquality..." | tee -a "$LOGFILE"
apt-get update -y >> "$LOGFILE" 2>&1
apt-get install -y libpam-pwquality >> "$LOGFILE" 2>&1

PAM_PASSWORD_FILE="/etc/pam.d/common-password"
BACKUP_FILE="/etc/pam.d/common-password.bak.$(date +%F_%T)"
cp "$PAM_PASSWORD_FILE" "$BACKUP_FILE"
echo "[*] Backup of $PAM_PASSWORD_FILE saved as $BACKUP_FILE" | tee -a "$LOGFILE"

# Remove existing pam_pwquality lines to avoid duplicates
sed -i '/pam_pwquality.so/d' "$PAM_PASSWORD_FILE"

# Add pam_pwquality.so line with strict options
echo "password requisite pam_pwquality.so retry=3 minlen=12 dcredit=-1 ucredit=-1 ocredit=-1 lcredit=-1 enforce_for_root" >> "$PAM_PASSWORD_FILE"

echo "[*] PAM password policy updated:" | tee -a "$LOGFILE"
tail -n 3 "$PAM_PASSWORD_FILE" | tee -a "$LOGFILE"

# ---------------------------
# Additional Lynis recommendations:
# ---------------------------

echo "[*] Configuring stronger password hashing rounds and stricter umask..." | tee -a "$LOGFILE"

LOGIN_DEFS="/etc/login.defs"
cp "$LOGIN_DEFS" "${LOGIN_DEFS}.bak.$(date +%F_%T)"

# Ensure SHA512 hashing method
sed -i 's/^#*\s*ENCRYPT_METHOD\s*=.*/ENCRYPT_METHOD SHA512/' "$LOGIN_DEFS"

# Set password hashing rounds (e.g. 5000)
if grep -q "^PASS_MIN_ROUNDS" "$LOGIN_DEFS"; then
    sed -i 's/^PASS_MIN_ROUNDS.*/PASS_MIN_ROUNDS 5000/' "$LOGIN_DEFS"
else
    echo "PASS_MIN_ROUNDS 5000" >> "$LOGIN_DEFS"
fi

# Set default UMASK to 027 (more restrictive)
if grep -q "^UMASK" "$LOGIN_DEFS"; then
    sed -i 's/^UMASK.*/UMASK 027/' "$LOGIN_DEFS"
else
    echo "UMASK 027" >> "$LOGIN_DEFS"
fi

echo "[*] Password hashing rounds and umask configured." | tee -a "$LOGFILE"
echo "[*] PAM password policy hardening complete." | tee -a "$LOGFILE"
