#!/usr/bin/env bash
set -euo pipefail
sudo docker exec -i rpmbox bash -se <<'CONTAINER_REFERENCE'
set -o pipefail
mkdir -p /home/candidate/answers
dnf search fail2ban > /home/candidate/answers/search.txt
dnf info httpd > /home/candidate/answers/info.txt
dnf provides '*/ip' > /home/candidate/answers/provides.txt
dnf list installed | grep '^python3-' > /home/candidate/answers/python-packages.txt
CONTAINER_REFERENCE
