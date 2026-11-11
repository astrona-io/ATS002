#!/usr/bin/env bash
set -euo pipefail
sudo docker exec -i zypperbox bash -se <<'CONTAINER_REFERENCE'
set -o pipefail
zypper --non-interactive install fail2ban
CONTAINER_REFERENCE
