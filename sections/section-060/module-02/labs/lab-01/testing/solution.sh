#!/usr/bin/env bash
set -euo pipefail
sudo docker exec -i rpmbox bash -se <<'CONTAINER_REFERENCE'
set -o pipefail
cp -a /var/lib/rpm /var/lib/rpm.ci-backup
rpm --rebuilddb
dnf check
CONTAINER_REFERENCE
