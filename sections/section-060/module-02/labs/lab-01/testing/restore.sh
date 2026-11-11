#!/usr/bin/env bash
set -euo pipefail
sudo docker exec -i rpmbox bash -se <<'RESTORE'
cp -a /root/rpmdb-known-good/. /var/lib/rpm/
rm -f /var/lib/rpm/rpmdb.sqlite-wal /var/lib/rpm/rpmdb.sqlite-shm
rpm --rebuilddb
RESTORE
