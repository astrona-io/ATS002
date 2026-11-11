#!/usr/bin/env bash
# Match the account used by astrona ssh, including its home and permissions.
sudo -H -u student bash <<'ASTRONA_STUDENT_SCRIPT'
set -eu
fail() { echo "FAIL: $*"; exit 1; }
[ "$(getenforce)" = Enforcing ] || fail 'SELinux must remain enforcing'
sudo grep -Eq '^SELINUX=enforcing$' /etc/selinux/config || fail 'boot mode must be enforcing'
if sudo semanage permissive -l | grep -qw httpd_t; then fail 'httpd_t must not be permissive'; fi
sudo matchpathcon /srv/web/index.html | grep -q ':httpd_sys_content_t:' || fail 'persistent file-context rule missing'
ls -Zd /srv/web /srv/web/index.html | grep -q ':user_home_t:' && fail 'web content still has home labels'
ls -Zd /srv/web/index.html | grep -q ':httpd_sys_content_t:' || fail 'live web content label incorrect'
getsebool httpd_can_network_connect | grep -q -- '--> on$' || fail 'outgoing connection boolean is off'
sudo semanage port -l | awk '$1=="http_port_t" && $2=="tcp" {for(i=3;i<=NF;i++){gsub(/,/,"",$i); if($i==8888) found=1}} END {exit !found}' || fail 'TCP 8888 is not an HTTP port'
systemctl is-active --quiet httpd || fail 'Apache is not running'
ps -eZ | grep 'httpd_t.*httpd' >/dev/null || fail 'Apache is not confined as httpd_t'
[ "$(curl --fail --silent --max-time 5 http://127.0.0.1:8888/)" = 'SELinux page ready' ] || fail 'Apache cannot serve the page'
[ "$(curl --fail --silent --max-time 5 http://127.0.0.1:8888/probe)" = 'SELinux backend ready' ] || fail 'Apache cannot reach the backend'
echo 'PASS: confined Apache serves content and reaches its backend with SELinux enforcing'
ASTRONA_STUDENT_SCRIPT
