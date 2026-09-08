#!/usr/bin/env bash
# Bootstrap: a service that starts, runs its ExecStart, and exits non-zero
# because the unprivileged user it runs as cannot write where it needs to.
#
#   metricsd.service:  User=metricsd
#   ExecStart writes to /var/lib/metricsd/metrics.log
#   /var/lib/metricsd is owned root:root, mode 0755  -> metricsd cannot write
#
# Result: `systemctl status metricsd` shows
#   Active: failed (Result: exit-code)  ...  status=1/FAILURE
# and `journalctl -u metricsd` shows the daemon's own line:
#   metricsd: cannot open /var/lib/metricsd/metrics.log: Permission denied
#
# Two acceptable fixes:
#   a) chown metricsd:metricsd /var/lib/metricsd   (grant the user access), OR
#   b) give the unit a StateDirectory=/ReadWritePaths= / correct the User=.
# The validator only checks the end state: unit active + enabled, still a
# non-root user, and the log file is being written.
set -eu

id -u metricsd >/dev/null 2>&1 || useradd --system --no-create-home --shell /usr/sbin/nologin metricsd

install -d -m 0755 /usr/local/sbin
install -d -m 0755 -o root -g root /var/lib/metricsd   # deliberately NOT writable by metricsd

cat > /usr/local/sbin/metricsd <<'EOF'
#!/bin/bash
LOG=/var/lib/metricsd/metrics.log
# Fail loudly and immediately if we cannot write the log.
if ! : >> "$LOG" 2>/dev/null; then
  echo "metricsd: cannot open $LOG: Permission denied" >&2
  exit 1
fi
while true; do
  printf '%s metricsd sample=%s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$RANDOM" >> "$LOG"
  sleep 3
done
EOF
chmod 0755 /usr/local/sbin/metricsd

cat > /etc/systemd/system/metricsd.service <<'EOF'
[Unit]
Description=Metrics sampling daemon
After=network.target

[Service]
Type=simple
User=metricsd
ExecStart=/usr/local/sbin/metricsd
Restart=on-failure
RestartSec=2

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable metricsd.service
systemctl start metricsd.service || true
