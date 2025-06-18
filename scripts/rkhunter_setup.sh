#!/bin/bash
# ------------------------------------------------------------
# Rootkit Hunter Installation and Safe Update Script
# - Installs and configures rkhunter
# - Validates update results (only skips optional files)
# - Creates daily cron job for automatic checks
# ------------------------------------------------------------

set -euo pipefail

LOGDIR="/var/log/hardening"
LOGFILE="$LOGDIR/rkhunter_setup.log"
DATA_DIR="/var/lib/rkhunter/db"

mkdir -p "$LOGDIR"
echo "[*] Starting rkhunter installation and configuration at $(date)" | tee -a "$LOGFILE"

# Step 1: Install dependencies
echo "[*] Updating package index..." | tee -a "$LOGFILE"
apt-get update -y >> "$LOGFILE" 2>&1

echo "[*] Installing rkhunter and wget..." | tee -a "$LOGFILE"
apt-get install -y rkhunter wget >> "$LOGFILE" 2>&1

# Step 2: Configure rkhunter.conf
echo "[*] Disabling WEB_CMD in /etc/rkhunter.conf ..." | tee -a "$LOGFILE"
sed -i 's|^WEB_CMD=.*|WEB_CMD=""|' /etc/rkhunter.conf

echo "[*] Setting MIRRORS_MODE=0 in /etc/rkhunter.conf ..." | tee -a "$LOGFILE"
if grep -q "^MIRRORS_MODE=" /etc/rkhunter.conf; then
    sed -i 's/^MIRRORS_MODE=.*/MIRRORS_MODE=0/' /etc/rkhunter.conf
else
    echo "MIRRORS_MODE=0" >> /etc/rkhunter.conf
fi

# Step 3: Download only mandatory files
echo "[*] Ensuring rkhunter data directory exists: $DATA_DIR" | tee -a "$LOGFILE"
mkdir -p "$DATA_DIR"
cd "$DATA_DIR"

echo "[*] Downloading mandatory rkhunter data files..." | tee -a "$LOGFILE"
wget -q -N https://rkhunter.sourceforge.net/1.4/mirrors.dat
wget -q -N https://rkhunter.sourceforge.net/1.4/programs_bad.dat
wget -q -N https://rkhunter.sourceforge.net/1.4/backdoorports.dat
wget -q -N https://rkhunter.sourceforge.net/1.4/suspscan.dat

# Step 4: Run update and handle exit code safely
echo "[*] Running rkhunter --update ..." | tee -a "$LOGFILE"
rkhunter --update >> "$LOGFILE" 2>&1 || {
    CODE=$?
    if [ "$CODE" -eq 2 ]; then
        echo "[!] rkhunter --update returned exit code 2 (some files skipped)" | tee -a "$LOGFILE"
    else
        echo "[✗] rkhunter --update failed with exit code $CODE" | tee -a "$LOGFILE"
        exit $CODE
    fi
}

# Step 5: Confirm no mandatory files were skipped
echo "[*] Verifying mandatory files were not skipped..." | tee -a "$LOGFILE"
MANDATORY=("mirrors.dat" "programs_bad.dat" "backdoorports.dat" "suspscan.dat")
SKIPPED_MANDATORY=0

for FILE in "${MANDATORY[@]}"; do
    if grep -q "Checking file $FILE.*\[ Skipped \]" "$LOGFILE"; then
        echo "[✗] Mandatory file $FILE was skipped! Aborting..." | tee -a "$LOGFILE"
        SKIPPED_MANDATORY=1
    fi
done

if [ "$SKIPPED_MANDATORY" -eq 1 ]; then
    echo "[✗] One or more mandatory files were skipped. Update incomplete." | tee -a "$LOGFILE"
    exit 3
fi

# Step 6: Run initial check quietly
echo "[*] Running rkhunter --check (quiet mode) ..." | tee -a "$LOGFILE"
rkhunter --check --sk >> "$LOGFILE" 2>&1

# Step 7: Create daily cron job for automatic scan
CRON_FILE="/etc/cron.daily/rkhunter_daily_check"
echo "[*] Creating daily rkhunter cron job at $CRON_FILE ..." | tee -a "$LOGFILE"

cat <<EOF > "$CRON_FILE"
#!/bin/bash
/usr/bin/rkhunter --check --quiet --rwo
EOF

chmod +x "$CRON_FILE"

echo "[✓] rkhunter installation, validation, and automation complete at $(date)" | tee -a "$LOGFILE"
echo "Please review $LOGFILE and /var/log/rkhunter.log for details."
