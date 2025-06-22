#!/bin/bash

# ----------------------------------------
# Master Hardening Script
# Runs all hardening scripts sequentially
# ----------------------------------------

set -euo pipefail

export DEBIAN_FRONTEND=noninteractive
LOG_DIR="/var/log/hardening"
mkdir -p "$LOG_DIR"

SCRIPT_DIR="$(cd "$(dirname "$0")/../scripts" && pwd)"

echo "[+] Starting Full System Hardening at $(date)"

# Run each script in order
for script in \
  ex_utilities.sh \
  disable_unused_accounts.sh \
  blacklist_protocols.sh \
  kernel_sysctl_hardening.sh \
  apparmor_setup.sh \
  auditd_setup.sh \
  aide_setup.sh \
  lynis_audit.sh \
  secure_permissions_sensitive_files.sh \
  pam_password_policy.sh \
  password_aging_lockout.sh \
  mfa_google_auth.sh \
  ssh_hardening.sh \
  fail2ban_setup.sh \
  ufw_setup.sh \
  rkhunter_setup.sh \
  rsyslog_logrotate_setup.sh \
  unattended_upgrades_setup.sh
do
    echo "[*] Running $script..."
    bash "$SCRIPT_DIR/$script"
done

echo "[+] System Hardening Complete at $(date)"
