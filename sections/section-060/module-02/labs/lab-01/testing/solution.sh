#!/usr/bin/env bash
set -euo pipefail
sudo docker exec -i rpmbox bash -se <<'CONTAINER_REFERENCE'
set -o pipefail
cp -a /var/lib/rpm /var/lib/rpm.damaged
(cd /root/rpmdb-known-good && sha256sum -c /root/rpmdb-known-good.sha256)
cp -a /root/rpmdb-known-good/. /var/lib/rpm/
rm -f /var/lib/rpm/rpmdb.sqlite-wal /var/lib/rpm/rpmdb.sqlite-shm
rpm --rebuilddb
rpm -qa | LC_ALL=C sort > /root/rpm-packages-restored.txt
diff -u /root/rpm-packages-before.txt /root/rpm-packages-restored.txt
dnf check
CONTAINER_REFERENCE
