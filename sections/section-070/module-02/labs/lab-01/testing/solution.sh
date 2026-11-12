#!/usr/bin/env bash
set -euo pipefail
sudo docker exec -i zypperbox bash -se <<'CONTAINER_REFERENCE'
set -o pipefail
mkdir -p /root/answers
zypper search fail2ban > /root/answers/01-search.txt
zypper info nginx > /root/answers/02-info.txt
zypper what-provides /usr/sbin/ip > /root/answers/03-what-provides.txt
zypper search --installed-only 'python3*' > /root/answers/04-installed-python3.txt
CONTAINER_REFERENCE
