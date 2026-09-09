#!/usr/bin/env bash
# Bootstrap: a service that will not start because its ExecStart= names a
# path that does not exist.
#
# The real daemon 'reportd' is installed at /usr/local/sbin/reportd. The
# shipped unit reportd.service, however, has:
#     ExecStart=/usr/local/bin/reportd        <-- wrong directory
# so `systemctl start reportd` fails immediately with
#     (code=exited, status=203/EXEC)
# and `journalctl -u reportd` shows "Failed to locate executable ...: No
# such file or directory".
#
# The unit is `enabled` (so it is wired for boot) but not `active`. The
# candidate must find the wrong path from `systemctl status` / `journalctl`,
# correct the unit (edit or drop-in), daemon-reload, start it, and confirm
# it is both active and enabled.
set -eu

install -d -m 0755 /usr/local/sbin
install -d -m 0755 /var/lib/reportd

# The actual daemon: append a heartbeat line every few seconds, forever.
cat > /usr/local/sbin/reportd <<'EOF'
#!/bin/bash
while true; do
  printf '%s reportd heartbeat pid=%s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$$" >> /var/lib/reportd/heartbeat.log
  sleep 3
done
EOF
chmod 0755 /usr/local/sbin/reportd

cat > /etc/systemd/system/reportd.service <<'EOF'
[Unit]
Description=Report collection daemon
After=network.target

[Service]
Type=simple
# NOTE: the binary is actually at /usr/local/sbin/reportd
ExecStart=/usr/local/bin/reportd
Restart=on-failure
RestartSec=2

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable reportd.service
# Attempt to start it so it is already in the failed state on login.
systemctl start reportd.service || true
