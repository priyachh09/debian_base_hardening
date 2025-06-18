#!/bin/bash

# -------------------------------------------------------------------
# Script: password_aging_lockout.sh
# Description: Set password aging and account lockout policies for users
# -------------------------------------------------------------------

set -euo pipefail

LOGFILE="/var/log/hardening/password_aging_lockout.log"
mkdir -p /var/log/hardening
echo "[*] Starting password aging and lockout setup at $(date)" | tee -a "$LOGFILE"

echo "[*] Installing necessary packages (if not installed)..." | tee -a "$LOGFILE"
apt-get update -y >> "$LOGFILE" 2>&1
apt-get install -y libpam-modules libpam-modules-bin >> "$LOGFILE" 2>&1

# Set password aging defaults for all users
echo "[*] Configuring password aging defaults in /etc/login.defs" | tee -a "$LOGFILE"
sed -i 's/^PASS_MAX_DAYS.*/PASS_MAX_DAYS   90/' /etc/login.defs
sed -i 's/^PASS_MIN_DAYS.*/PASS_MIN_DAYS   7/' /etc/login.defs
sed -i 's/^PASS_WARN_AGE.*/PASS_WARN_AGE   14/' /etc/login.defs

echo "[*] Updating existing user accounts to enforce aging policy..." | tee -a "$LOGFILE"
getent passwd | cut -d: -f1 | while read -r user; do
    if [[ "$user" != "root" ]]; then
        echo "[*] Setting aging policy for user: $user" | tee -a "$LOGFILE"
        chage --maxdays 90 --mindays 7 --warndays 14 "$user" >> "$LOGFILE" 2>&1 || true
    fi
done

# PAM lockout setup: Fail authentication after 5 attempts, unlock after 15 minutes
PAM_AUTH_FILE="/etc/pam.d/common-auth"
BACKUP_FILE="/etc/pam.d/common-auth.bak.$(date +%F_%T)"
cp "$PAM_AUTH_FILE" "$BACKUP_FILE"
echo "[*] Backup of $PAM_AUTH_FILE saved as $BACKUP_FILE" | tee -a "$LOGFILE"

# Remove any existing pam_tally2 or pam_faillock lines to avoid duplicates
sed -i '/pam_tally2.so/d' "$PAM_AUTH_FILE"
sed -i '/pam_faillock.so/d' "$PAM_AUTH_FILE"

# Insert pam_faillock lines to enable lockout policy
sed -i '1i auth required pam_faillock.so preauth silent audit deny=5 unlock_time=900 fail_interval=900' "$PAM_AUTH_FILE"
sed -i '/^auth.*required.*pam_unix.so/a auth [default=die] pam_faillock.so authfail audit deny=5 unlock_time=900 fail_interval=900' "$PAM_AUTH_FILE"
sed -i '/^account.*required.*pam_unix.so/a account required pam_faillock.so' /etc/pam.d/common-account

echo "[*] Password aging and lockout policies configured." | tee -a "$LOGFILE"
