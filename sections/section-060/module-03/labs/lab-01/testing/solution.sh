#!/usr/bin/env bash
set -euo pipefail
sudo docker exec -i rpmbox bash -se <<'CONTAINER_REFERENCE'
set -o pipefail
dnf -y install fail2ban mtr
id=$(dnf history list | awk -F '|' '/install fail2ban mtr/ {gsub(/ /,"",$1); print $1; exit}')
test -n "$id"
dnf -y history undo "$id"
dnf -y install fail2ban
dnf -y remove telnet
dnf -y autoremove
CONTAINER_REFERENCE
