#!/usr/bin/env bash
set -eu
[ "$(getenforce)" = Enforcing ]
command -v semanage
sudo test -f /srv/web/index.html
curl --fail --silent --max-time 5 http://127.0.0.1:19090/ | grep -q 'SELinux backend ready'
