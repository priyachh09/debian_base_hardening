#!/bin/bash

# -------------------------------------------------------------------
# Script: auditd_setup.sh
# Description: Install and configure auditd for system auditing and monitoring
# -------------------------------------------------------------------

set -euo pipefail

LOGFILE="/var/log/hardening/auditd_setup.log"
mkdir -p /var/log/hardening
echo "[*] Starting auditd setup at $(date)" | tee -a "$LOGFILE"

echo "[*] Installing auditd package..." | tee -a "$LOGFILE"
apt-get update -y >> "$LOGFILE" 2>&1
apt-get install -y auditd audispd-plugins >> "$LOGFILE" 2>&1

echo "[*] Backing up current audit rules..." | tee -a "$LOGFILE"
cp /etc/audit/audit.rules /etc/audit/audit.rules.bak.$(date +%F_%T)

# Example minimal audit rules for user and system monitoring
AUDIT_RULES_FILE="/etc/audit/rules.d/hardening.rules"
cat <<EOF > "$AUDIT_RULES_FILE"
## Audit all changes to passwd, shadow, group files
-w /etc/passwd -p wa -k identity
-w /etc/shadow -p wa -k identity
-w /etc/group -p wa -k identity
-w /etc/gshadow -p wa -k identity

## Audit attempts to use sudo
-w /var/log/sudo.log -p wa -k sudo

## Audit all executions by users
-a always,exit -F arch=b64 -S execve -k exec
-a always,exit -F arch=b32 -S execve -k exec

## Audit changes to critical files and directories
-w /etc/ssh/sshd_config -p wa -k sshd_config
-w /etc/sudoers -p wa -k sudoers

## Audit modifications to audit rules themselves
-w /etc/audit/ -p wa -k auditconfig

EOF

echo "[*] Restarting auditd service to apply new rules..." | tee -a "$LOGFILE"
systemctl restart auditd >> "$LOGFILE" 2>&1
systemctl enable auditd >> "$LOGFILE" 2>&1

echo "[*] auditd setup complete." | tee -a "$LOGFILE"
