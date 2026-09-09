#!/usr/bin/env bash
# Provides the two maintenance scripts and one existing cron job the
# student will work with.
set -eu

sudo install -d -m 0755 /usr/local/sbin /var/log/maint

sudo tee /usr/local/sbin/report.sh >/dev/null <<'EOF'
#!/bin/bash
printf '%s report generated\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)" >> /var/log/maint/report.log
EOF

sudo tee /usr/local/sbin/dbclean.sh >/dev/null <<'EOF'
#!/bin/bash
printf '%s dbclean run\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)" >> /var/log/maint/dbclean.log
EOF

sudo chmod 0755 /usr/local/sbin/report.sh /usr/local/sbin/dbclean.sh

# Existing system-wide cron job: dbclean every 6 hours. The student
# converts this to a systemd timer and removes this file.
sudo tee /etc/cron.d/dbclean >/dev/null <<'EOF'
# run the database cleanup every 6 hours
0 */6 * * * root /usr/local/sbin/dbclean.sh
EOF

echo "lab-023 bootstrap complete."
echo "  scripts: /usr/local/sbin/report.sh, /usr/local/sbin/dbclean.sh"
echo "  existing cron job to convert: /etc/cron.d/dbclean (every 6h)"
