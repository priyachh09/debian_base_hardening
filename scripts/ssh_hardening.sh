#!/bin/bash

set -euo pipefail

LOGFILE="/var/log/hardening/ssh_hardening.log"
mkdir -p /var/log/hardening
echo "[*] Starting SSH hardening at $(date)" | tee -a "$LOGFILE"

SSHD_CONFIG="/etc/ssh/sshd_config"
BACKUP_SSHD="/etc/ssh/sshd_config.bak.$(date +%F_%T)"
cp "$SSHD_CONFIG" "$BACKUP_SSHD"
echo "[*] Backup of $SSHD_CONFIG saved as $BACKUP_SSHD" | tee -a "$LOGFILE"

SSH_PORT=2222

# Set SSH Port or add if missing
if grep -q "^Port" "$SSHD_CONFIG"; then
    sed -i "s/^Port.*/Port $SSH_PORT/" "$SSHD_CONFIG"
else
    echo "Port $SSH_PORT" >> "$SSHD_CONFIG"
fi

# Enable ChallengeResponseAuthentication
if grep -q "^ChallengeResponseAuthentication" "$SSHD_CONFIG"; then
    sed -i 's/^ChallengeResponseAuthentication.*/ChallengeResponseAuthentication yes/' "$SSHD_CONFIG"
else
    echo "ChallengeResponseAuthentication yes" >> "$SSHD_CONFIG"
fi

# Enable PubkeyAuthentication
if grep -q "^PubkeyAuthentication" "$SSHD_CONFIG"; then
    sed -i 's/^PubkeyAuthentication.*/PubkeyAuthentication yes/' "$SSHD_CONFIG"
else
    echo "PubkeyAuthentication yes" >> "$SSHD_CONFIG"
fi

# Remove any line disabling keyboard-interactive auth explicitly
sed -i '/^KbdInteractiveAuthentication\s*no/d' "$SSHD_CONFIG"

# Set AuthenticationMethods to require both pubkey and keyboard-interactive
if grep -q "^AuthenticationMethods" "$SSHD_CONFIG"; then
    sed -i 's/^AuthenticationMethods.*/AuthenticationMethods publickey,keyboard-interactive/' "$SSHD_CONFIG"
else
    echo "AuthenticationMethods publickey,keyboard-interactive" >> "$SSHD_CONFIG"
fi

# Other hardening settings as before (PermitRootLogin, MaxAuthTries, etc)
sed -i 's/^#*PermitRootLogin.*/PermitRootLogin no/' "$SSHD_CONFIG" || echo "PermitRootLogin no" >> "$SSHD_CONFIG"
sed -i 's/^#*PasswordAuthentication.*/PasswordAuthentication no/' "$SSHD_CONFIG" || echo "PasswordAuthentication no" >> "$SSHD_CONFIG"
sed -i 's/^#*PermitEmptyPasswords.*/PermitEmptyPasswords no/' "$SSHD_CONFIG" || echo "PermitEmptyPasswords no" >> "$SSHD_CONFIG"
sed -i 's/^#*MaxAuthTries.*/MaxAuthTries 3/' "$SSHD_CONFIG" || echo "MaxAuthTries 3" >> "$SSHD_CONFIG"
sed -i 's/^#*X11Forwarding.*/X11Forwarding no/' "$SSHD_CONFIG" || echo "X11Forwarding no" >> "$SSHD_CONFIG"
sed -i 's/^#*UseDNS.*/UseDNS no/' "$SSHD_CONFIG" || echo "UseDNS no" >> "$SSHD_CONFIG"
sed -i 's/^#*AllowTcpForwarding.*/AllowTcpForwarding no/' "$SSHD_CONFIG" || echo "AllowTcpForwarding no" >> "$SSHD_CONFIG"
sed -i 's/^#*AllowAgentForwarding.*/AllowAgentForwarding no/' "$SSHD_CONFIG" || echo "AllowAgentForwarding no" >> "$SSHD_CONFIG"
sed -i 's/^#*LoginGraceTime.*/LoginGraceTime 30/' "$SSHD_CONFIG" || echo "LoginGraceTime 30" >> "$SSHD_CONFIG"

# --- Lynis recommended SSH hardening additions ---
sed -i '/^ClientAliveCountMax/d' "$SSHD_CONFIG"
echo "ClientAliveCountMax 2" >> "$SSHD_CONFIG"

sed -i '/^Compression/d' "$SSHD_CONFIG"
echo "Compression no" >> "$SSHD_CONFIG"

sed -i '/^LogLevel/d' "$SSHD_CONFIG"
echo "LogLevel VERBOSE" >> "$SSHD_CONFIG"

sed -i '/^MaxSessions/d' "$SSHD_CONFIG"
echo "MaxSessions 2" >> "$SSHD_CONFIG"

sed -i '/^TCPKeepAlive/d' "$SSHD_CONFIG"
echo "TCPKeepAlive no" >> "$SSHD_CONFIG"
# --- End Lynis additions ---

echo "[*] Restarting SSH service to apply changes..." | tee -a "$LOGFILE"
systemctl restart sshd

echo "[*] SSH hardening complete. SSH is running on port $SSH_PORT." | tee -a "$LOGFILE"
