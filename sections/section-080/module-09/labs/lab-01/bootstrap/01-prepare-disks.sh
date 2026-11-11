#!/usr/bin/env bash
# Match the account used by astrona ssh, including its home and permissions.
sudo -H -u student bash <<'ASTRONA_STUDENT_SCRIPT'
# Builds the starting state for lab-08a (disk health diagnosis): two spare 1 GB disks (serials
# lab08a-suspect and lab08a-other), a known pattern in the first MiB of the
# suspect disk (its hash is stored so a read-only scan can be proven), and an
# I/O error message about the suspect disk in the kernel log.
#
# Disks are found by their virtio serials, never by a device letter. The VM
# root disk is not touched, so the machine stays reachable over SSH.

set -eu

SUSPECT_ID=/dev/disk/by-id/virtio-lab08a-suspect
OTHER_ID=/dev/disk/by-id/virtio-lab08a-other

for id in "$SUSPECT_ID" "$OTHER_ID"; do
  for i in $(seq 1 30); do
    [ -e "$id" ] && break
    sleep 1
  done
  [ -e "$id" ]
done

if ! command -v smartctl >/dev/null 2>&1; then
  sudo apt-get update -qq || true
  sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -qq smartmontools
fi

SUSPECT=$(readlink -f "$SUSPECT_ID")
SUSPECT_NAME=$(basename "$SUSPECT")

sudo wipefs -a "$SUSPECT" "$(readlink -f "$OTHER_ID")"

yes LAB08A-SUSPECT-DISK | head -c 1048576 | sudo dd of="$SUSPECT" bs=1M conv=fsync status=none
sudo mkdir -p /var/lib/lab08a
sudo sh -c "head -c 1048576 '$SUSPECT' | sha256sum > /var/lib/lab08a/suspect.sha256"

sudo sh -c "echo '<3>lab08a-monitor: I/O error, dev $SUSPECT_NAME, sector 4096 op 0x0:(READ) flags 0x0 phys_seg 1 prio class 2' > /dev/kmsg"
sudo mkdir -p /var/tmp/disk-report
sudo chmod 1777 /var/tmp/disk-report
ASTRONA_STUDENT_SCRIPT
