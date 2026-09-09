#!/usr/bin/env bash
# Bootstrap: a two-unit chain where the *upstream* unit is the real fault,
# plus a restart flap on the downstream unit.
#
#   ingest-db.service   ExecStart=/usr/local/sbin/ingest-db  <-- typo: real
#                       binary is /usr/local/sbin/ingestdb (no dash).
#                       Fails with 203/EXEC.
#
#   ingest.service      Requires=ingest-db.service
#                       After=ingest-db.service
#                       Restart=always, low StartLimit -> because its
#                       Requires= dependency never comes up, ingest is
#                       pulled straight to failed, restarts, and quickly
#                       trips 'start-limit-hit'.
#
# Neither unit is enabled. The candidate must:
#   1. fix ingest-db.service's ExecStart (find the real binary),
#   2. `systemctl reset-failed ingest.service` to clear the latched flap,
#   3. start the chain (starting ingest pulls in ingest-db via Requires=),
#   4. `systemctl enable` BOTH units so the chain survives a reboot.
set -eu

install -d -m 0755 /usr/local/sbin /var/lib/ingest

# Real DB daemon - note the name has NO dash.
cat > /usr/local/sbin/ingestdb <<'EOF'
#!/bin/bash
touch /var/lib/ingest/db.ready
while true; do sleep 5; done
EOF
chmod 0755 /usr/local/sbin/ingestdb

# Real ingest worker: only makes progress once db.ready exists.
cat > /usr/local/sbin/ingest <<'EOF'
#!/bin/bash
[ -e /var/lib/ingest/db.ready ] || { echo "ingest: database not ready" >&2; exit 1; }
while true; do
  printf '%s ingest batch=%s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$RANDOM" >> /var/lib/ingest/ingest.log
  sleep 3
done
EOF
chmod 0755 /usr/local/sbin/ingest

cat > /etc/systemd/system/ingest-db.service <<'EOF'
[Unit]
Description=Ingest database backend

[Service]
Type=simple
# NOTE: real binary is /usr/local/sbin/ingestdb  (no dash)
ExecStart=/usr/local/sbin/ingest-db
Restart=on-failure
RestartSec=2

[Install]
WantedBy=multi-user.target
EOF

cat > /etc/systemd/system/ingest.service <<'EOF'
[Unit]
Description=Ingest worker
Requires=ingest-db.service
After=ingest-db.service

[Service]
Type=simple
ExecStart=/usr/local/sbin/ingest
Restart=always
RestartSec=1
StartLimitIntervalSec=10
StartLimitBurst=3

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
# Deliberately NOT enabled. Start ingest to drive it into the flap/failed state.
systemctl start ingest.service || true
sleep 8   # let it trip start-limit-hit
