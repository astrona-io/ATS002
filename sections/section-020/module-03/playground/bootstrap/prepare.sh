#!/usr/bin/env bash
# OS prep for PLAYGROUND -- systemd Timers
#
# Runs once when the environment comes up. Environment preparation only:
# create four small maintenance scripts and one old cron job to convert
# to a timer. There is no task and no grading.
set -euo pipefail

echo "[playground] systemd-timer-bay: staging scripts ..."
sudo install -d -m 0755 /usr/local/sbin /var/log/maint

for job in backup archive report dbclean; do
  sudo tee "/usr/local/sbin/${job}.sh" >/dev/null <<EOF
#!/bin/bash
printf '%s ${job} run\n' "\$(date -u +%Y-%m-%dT%H:%M:%SZ)" >> /var/log/maint/${job}.log
EOF
  sudo chmod 0755 "/usr/local/sbin/${job}.sh"
done

# Make sure cron runs, so the old job is a real one.
if command -v crontab >/dev/null 2>&1; then
  sudo systemctl enable --now cron || true
fi

# Existing system-wide cron job: dbclean every 6 hours. You convert this
# to a systemd timer and remove this file.
sudo tee /etc/cron.d/dbclean >/dev/null <<'EOF'
# run the database cleanup every 6 hours
0 */6 * * * root /usr/local/sbin/dbclean.sh
EOF
sudo chmod 0644 /etc/cron.d/dbclean

echo "[playground] systemd-timer-bay: ready."
