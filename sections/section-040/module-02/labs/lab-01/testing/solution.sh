#!/usr/bin/env bash
set -euo pipefail
sudo semanage fcontext -a -t httpd_sys_content_t '/srv/web(/.*)?'
sudo restorecon -Rv /srv/web
sudo semanage port -a -t http_port_t -p tcp 8888
sudo setsebool -P httpd_can_network_connect on
sudo systemctl restart httpd
