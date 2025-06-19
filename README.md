#  Debian Linux Base Hardening Project

This project provides a fully hardened Debian 12 (Bookworm) base server image, configured for use across various projects.

##  Contents

- Automated scripts for system hardening
- SSH, PAM, AppArmor, and UFW configuration
- Intrusion detection tools (AIDE, RKHunter, auditd, Fail2Ban)
- Security logging, log rotation
- System integrity and compliance tools (Lynis, unattended-upgrades)
- MFA setup using Google Authenticator

##  How to Use

```bash
git clone https://github.com/yourusername/debian-base-hardening.git
cd debian-base-hardening
chmod +x master_script.sh
sudo ./master_script.sh
```

All logs are saved in /var/log/hardening/.

## Hardening Standards Followed
- CIS Benchmarks (Debian)
- NIST 800-53 / 800-171
- MITRE ATT&CK Mapping
- OWASP Linux Security
- ISO 27001 Controls (Applicable subset)

## Exclusions
- No graphical environment (text-only VM)
- No cloud-init / system provisioning agent

## Requirements
- Debian 12+ (tested on Bookworm)
- Root privileges (run scripts with sudo)

## Additional Notes
- Designed as a secure baseline for various personal projects.
- Scripts are idempotent where possible and log detailed outputs for auditing
- Regular updates and improvements planned based on best practices and feedback

## Security Audit Result
This system was audited using [Lynis](https://cisofy.com/lynis/), yielding a final security score of:
> **Lynis Audit Score: 85**

Logs and full reports are saved in `/var/log/hardening/`.

## Contact
For questions or contributions, open an issue or contact [prichh09@gmail.com].
