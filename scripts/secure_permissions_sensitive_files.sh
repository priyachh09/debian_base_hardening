#!/bin/bash

# -------------------------------------------------------------------
# Script: secure_permissions_sensitive_files.sh
# Description: Set strict permissions on sensitive system files
# -------------------------------------------------------------------

set -euo pipefail

LOGFILE="/var/log/hardening/secure_permissions_sensitive_files.log"
mkdir -p /var/log/hardening
echo "[*] Starting securing sensitive file permissions at $(date)" | tee -a "$LOGFILE"

declare -A files=(
    ["/etc/passwd"]="644"
    ["/etc/shadow"]="600"
    ["/etc/group"]="644"
    ["/etc/gshadow"]="600"
    ["/etc/sudoers"]="440"
    ["/etc/ssh/sshd_config"]="600"
)

for file in "${!files[@]}"; do
    if [ -f "$file" ]; then
        perm="${files[$file]}"
        echo "[*] Setting permissions $perm on $file" | tee -a "$LOGFILE"
        chmod "$perm" "$file"
        chown root:root "$file"
    else
        echo "[!] File $file does not exist, skipping." | tee -a "$LOGFILE"
    fi
done

echo "[*] Sensitive file permission hardening complete." | tee -a "$LOGFILE"
