#!/bin/bash

# -------------------------------------------------------------------
# Script: kernel_sysctl_hardening.sh
# Description: Apply secure kernel-level sysctl settings
# -------------------------------------------------------------------

set -euo pipefail

LOGFILE="/var/log/hardening/kernel_sysctl_hardening.log"
mkdir -p /var/log/hardening
echo "[*] Starting kernel sysctl hardening at $(date)" | tee -a "$LOGFILE"

SYSCTL_FILE="/etc/sysctl.d/99-custom-hardening.conf"

echo "[*] Writing secure kernel parameters to $SYSCTL_FILE..." | tee -a "$LOGFILE"
cat <<EOF > "$SYSCTL_FILE"
# Disable IP packet forwarding
net.ipv4.ip_forward = 0
net.ipv6.conf.all.forwarding = 0

# Disable sending ICMP redirects
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.send_redirects = 0

# Enable TCP SYN cookies (prevent SYN flood attacks)
net.ipv4.tcp_syncookies = 1

# Log suspicious packets
net.ipv4.conf.all.log_martians = 1
net.ipv4.conf.default.log_martians = 1

# Ignore bogus ICMP errors
net.ipv4.icmp_ignore_bogus_error_responses = 1

# Disable source routing
net.ipv4.conf.all.accept_source_route = 0
net.ipv4.conf.default.accept_source_route = 0
net.ipv6.conf.all.accept_source_route = 0
net.ipv6.conf.default.accept_source_route = 0

# Disable acceptance of ICMP redirects
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv6.conf.all.accept_redirects = 0
net.ipv6.conf.default.accept_redirects = 0

# Disable router advertisements
net.ipv6.conf.all.accept_ra = 0
net.ipv6.conf.default.accept_ra = 0

# Enable execshield (basic NX memory protection)
kernel.exec-shield = 1
kernel.randomize_va_space = 2

# Restrict core dumps
fs.suid_dumpable = 0
kernel.kptr_restrict = 2

# Increase max backlog for connections
net.core.somaxconn = 1024
EOF

echo "[*] Applying sysctl settings..." | tee -a "$LOGFILE"
sysctl --system >> "$LOGFILE" 2>&1

echo "[*] Kernel sysctl hardening complete." | tee -a "$LOGFILE"
