#!/usr/bin/env bash
set -euo pipefail
sudo docker exec -i rpmbox bash -se <<'CONTAINER_REFERENCE'
set -o pipefail
cp -a /var/lib/rpm /var/lib/rpm.ci-backup
rpm --rebuilddb
rpm -ivh /home/candidate/downloads/metrics-shipper-*.rpm
dnf -y group install 'Development Tools'
dnf check
CONTAINER_REFERENCE
