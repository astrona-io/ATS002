#!/usr/bin/env bash
# Match the account used by astrona ssh, including its home and permissions.
sudo -H -u student bash <<'ASTRONA_STUDENT_SCRIPT'
# Inspect protected state; user access checks select their target account explicitly.
sudo -n bash <<'GRADER_ROOT'
# Confirms cargo_vg exists again on the spare disk and its physical volume
# has the UUID recorded in the metadata backup.

set -u

DISK_ID=/dev/disk/by-id/virtio-lab088-pv001
BACKUP=/etc/lvm/backup/cargo_vg

if [[ ! -e "$DISK_ID" ]]; then
  echo "FAIL: group - $DISK_ID not found"
  exit 1
fi

DISK=$(readlink -f "$DISK_ID")

if ! sudo vgs --noheadings cargo_vg >/dev/null 2>&1; then
  echo "FAIL: group - volume group cargo_vg does not exist"
  exit 1
fi

PV_NAME=$(sudo pvs --noheadings -o pv_name --select vg_name=cargo_vg 2>/dev/null | tr -d ' ' | head -n 1)
if [[ -z "$PV_NAME" || "$(readlink -f "$PV_NAME")" != "$DISK" ]]; then
  echo "FAIL: group - cargo_vg is not on the spare disk"
  exit 1
fi

NOW_UUID=$(sudo pvs --noheadings -o pv_uuid "$DISK" 2>/dev/null | tr -d ' ')
OLD_UUID=$(sudo awk '/pv0 \{/ {found=1} found && /id = / {gsub(/[" ]/, "", $3); print $3; exit}' "$BACKUP" 2>/dev/null)

if [[ -z "$OLD_UUID" ]]; then
  echo "FAIL: group - could not read the physical volume UUID from $BACKUP"
  exit 1
fi

if [[ "$NOW_UUID" != "$OLD_UUID" ]]; then
  echo "FAIL: group - the physical volume has a new UUID, not the original one"
  exit 1
fi

echo "PASS: cargo_vg is back on the spare disk with the original physical volume UUID"
exit 0
GRADER_ROOT
ASTRONA_STUDENT_SCRIPT
