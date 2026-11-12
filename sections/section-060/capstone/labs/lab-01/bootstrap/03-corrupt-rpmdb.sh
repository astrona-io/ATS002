#!/usr/bin/env bash
# Match the account used by astrona ssh, including its home and permissions.
sudo -H -u student bash <<'ASTRONA_STUDENT_SCRIPT'
# Simulates a real, unattended RPM database corruption inside rpmbox --
# same technique as lab-062/bootstrap/02-corrupt-rpmdb.sh -- a
# disk-full/interrupted-write style truncation-plus-overwrite of the
# actual sqlite-backed rpmdb file Rocky Linux 9 uses
# (/var/lib/rpm/rpmdb.sqlite, NOT the older Berkeley DB Packages/__db.*
# layout some older tutorials assume). This runs AFTER the
# metrics-shipper RPM was already built and staged in the previous
# bootstrap step, so the story is: the package was staged cleanly, then
# something killed a process mid-transaction overnight and left the
# database itself inconsistent. Already-installed package files on disk
# are left completely untouched -- only the database's own file is
# corrupted.

set -eu

echo "Confirming rpmdb backend in use inside rpmbox..."
sudo docker exec rpmbox ls -la /var/lib/rpm

echo "Pre-corruption package count (bootstrap log only, not shown to the student):"
sudo docker exec rpmbox rpm -qa | wc -l

# No package transaction runs while taking this lab snapshot.
sudo docker exec rpmbox bash -c '
  set -eu
  # RPM renames its database directory during rebuild. Make that directory
  # local to the container writable layer before the exercise starts.
  cp -a /var/lib/rpm /var/lib/rpm-upper
  rm -rf /var/lib/rpm
  mv /var/lib/rpm-upper /var/lib/rpm
  cp -a /var/lib/rpm /root/rpmdb-known-good
  rpm -qa | LC_ALL=C sort > /root/rpm-packages-before.txt
  cd /root/rpmdb-known-good
  sha256sum rpmdb.sqlite > /root/rpmdb-known-good.sha256
'
echo "Corrupting /var/lib/rpm/rpmdb.sqlite inside rpmbox..."
sudo docker exec rpmbox bash -c '
  set -eu
  f=/var/lib/rpm/rpmdb.sqlite
  size=$(stat -c%s "$f")

  # Overwrite a chunk of real page data roughly 40% into the file with
  # random bytes. We deliberately never touch the first 4KB (the sqlite
  # file header + master schema page). Recovery requires the saved snapshot.
  offset=$(( size * 40 / 100 ))
  dd if=/dev/urandom of="$f" bs=1024 seek=$(( offset / 1024 )) count=64 conv=notrunc status=none

  # Additionally truncate the tail, simulating a disk-full event that cut
  # the file off mid-transaction.
  newsize=$(( size * 85 / 100 ))
  truncate -s "$newsize" "$f"

  # Drop any WAL/SHM sidecar files so a stale write-ahead-log cannot
  # silently "fix" the truncated main file on next open.
  rm -f /var/lib/rpm/rpmdb.sqlite-wal /var/lib/rpm/rpmdb.sqlite-shm
'

echo "Confirming the database is now genuinely broken (expect an error below -- this is intentional):"
sudo docker exec rpmbox rpm -qa 2>&1 | tail -5

echo "rpmbox's RPM database is now corrupted. The staged metrics-shipper RPM and all already-installed package files are untouched. Diagnosing and repairing the database is the first part of the student's task."
ASTRONA_STUDENT_SCRIPT
