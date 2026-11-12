#!/usr/bin/env bash
set -euo pipefail
sudo docker exec -i zypperbox bash -se <<'CONTAINER_REFERENCE'
set -o pipefail
mkdir -p /root/answers
zypper refresh
zypper search fail2ban > /root/answers/01-research-search.txt
zypper info fail2ban > /root/answers/02-research-info.txt
zypper search --installed-only telnet-server > /root/answers/03-confirm-telnet-installed.txt
zypper --non-interactive install fail2ban
zypper --non-interactive remove telnet-server
CONTAINER_REFERENCE
