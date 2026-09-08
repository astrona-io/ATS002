#!/usr/bin/env bash
# Bootstrap: two units want TCP 8080. portsquatter.service grabs it first
# (a plain listener that does nothing useful); webreport.service - the one
# that actually matters - then fails to bind:
#   (98)Address already in use  /  Failed to listen on 0.0.0.0:8080
#
# webreport.service is `enabled` but `failed`. The candidate must find the
# conflicting listener with `ss -ltnp 'sport = :8080'`, stop and disable
# portsquatter (it is not needed), start webreport, and confirm it is the
# thing serving on 8080 and is enabled for boot.
set -eu

install -d -m 0755 /usr/local/sbin /var/www/report
echo "report service OK" > /var/www/report/index.html

# --- portsquatter: holds :8080, contributes nothing ---
cat > /etc/systemd/system/portsquatter.service <<'EOF'
[Unit]
Description=Leftover listener squatting on TCP 8080

[Service]
Type=simple
ExecStart=/usr/bin/python3 -m http.server 8080 --bind 0.0.0.0 --directory /root
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# --- webreport: the real service, cannot bind because 8080 is taken ---
cat > /usr/local/sbin/webreport <<'EOF'
#!/bin/bash
exec /usr/bin/python3 -m http.server 8080 --bind 0.0.0.0 --directory /var/www/report
EOF
chmod 0755 /usr/local/sbin/webreport

cat > /etc/systemd/system/webreport.service <<'EOF'
[Unit]
Description=Web report server
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/sbin/webreport
Restart=on-failure
RestartSec=2

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable --now portsquatter.service
sleep 1
systemctl enable webreport.service
systemctl start webreport.service || true
