#!/usr/bin/env bash
# Match the account used by astrona ssh, including its home and permissions.
sudo -H -u student bash <<'ASTRONA_STUDENT_SCRIPT'
set -euo pipefail
sudo -n bash <<'ROOT'
set -euo pipefail
dnf install -y httpd policycoreutils-python-utils python3 curl audit
[ "$(getenforce)" = Enforcing ]
systemctl enable --now auditd
mkdir -p /srv/web /srv/backend
printf 'SELinux page ready\n' >/srv/web/index.html
printf 'SELinux backend ready\n' >/srv/backend/index.html
chmod -R a+rX /srv/web /srv/backend
chcon -R -t user_home_t /srv/web
setsebool -P httpd_can_network_connect off
sed -i '/^Listen /d' /etc/httpd/conf/httpd.conf
cat >/etc/httpd/conf.d/training.conf <<'EOF'
Listen 8888
<VirtualHost *:8888>
  DocumentRoot /srv/web
  <Directory /srv/web>
    Require all granted
  </Directory>
  ProxyPass /probe http://127.0.0.1:19090/
  ProxyPassReverse /probe http://127.0.0.1:19090/
</VirtualHost>
EOF
cat >/etc/systemd/system/training-backend.service <<'EOF'
[Unit]
Description=SELinux lab backend
[Service]
ExecStart=/usr/bin/python3 -m http.server 19090 --bind 127.0.0.1 --directory /srv/backend
Restart=on-failure
[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
systemctl enable --now training-backend
systemctl enable httpd
# The missing port label deliberately prevents Apache from starting.
if systemctl start httpd; then
  echo 'Unexpected initial Apache success; check the image policy' >&2
  exit 1
fi
ROOT
ASTRONA_STUDENT_SCRIPT
