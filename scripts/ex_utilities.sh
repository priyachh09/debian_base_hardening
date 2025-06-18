#!/bin/bash

# -------------------------------------------------------------------
# Script: ex_utilities.sh
# Description: Install essential baseline utilities for hardening & ops
# -------------------------------------------------------------------

set -euo pipefail

LOGFILE="/var/log/hardening/ex_utilities.log"
mkdir -p /var/log/hardening
echo "[*] Starting Essential Utilities Setup at $(date)" | tee -a "$LOGFILE"

echo "[*] Updating package index..." | tee -a "$LOGFILE"
apt-get update -y >> "$LOGFILE" 2>&1

echo "[*] Installing essential packages..." | tee -a "$LOGFILE"
apt-get install -y \
    curl \
    wget \
    vim \
    gnupg \
    unzip \
    net-tools \
    htop \
    tree \
    tmux \
    ufw \
    fail2ban \
    rsyslog \
    logrotate \
    cron \
    bash-completion \
    lsof \
    whois \
    netcat-openbsd \
    iptables \
    sudo \
    software-properties-common \
    apt-transport-https \
    ca-certificates \
    gnupg2 \
    dnsutils \
    debsums \
    git \
    python3 \
    python3-pip \
    libpam-tmpdir \
    apt-listbugs \
    needrestart \
    apt-show-versions \
    sysstat \
    >> "$LOGFILE" 2>&1

echo "[*] Utility installation complete." | tee -a "$LOGFILE"
