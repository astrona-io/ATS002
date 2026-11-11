#!/usr/bin/env bash
set -euo pipefail
sudo docker exec -i rpmbox bash -se <<'CONTAINER_REFERENCE'
set -o pipefail
dnf -y group install 'Development Tools'
rpm -q gcc
dnf -y group remove 'Development Tools'
dnf check
CONTAINER_REFERENCE
