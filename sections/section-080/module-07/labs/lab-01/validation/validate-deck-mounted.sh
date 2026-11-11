#!/usr/bin/env bash
# Match the account used by astrona ssh, including its home and permissions.
sudo -H -u student bash <<'ASTRONA_STUDENT_SCRIPT'
# Inspect protected state; user access checks select their target account explicitly.
sudo -n bash <<'GRADER_ROOT'
# Confirms the deck is mounted at /srv/deck and the original files are
# still there with their original content.

set -u

MOUNT_POINT=/srv/deck

SOURCE=$(findmnt -rn -o SOURCE "$MOUNT_POINT" 2>/dev/null | head -n 1)
if [[ -z "$SOURCE" ]]; then
  echo "FAIL: mounted - nothing is mounted at $MOUNT_POINT"
  exit 1
fi

if [[ "$(readlink -f "$SOURCE")" != "$(readlink -f /dev/cargo_vg/deck)" ]]; then
  echo "FAIL: mounted - $MOUNT_POINT is not the logical volume cargo_vg/deck"
  exit 1
fi

MARKER=$(cat "$MOUNT_POINT/marker.txt" 2>/dev/null || true)
FLIGHT=$(cat "$MOUNT_POINT/logs/flight.log" 2>/dev/null || true)

if [[ "$MARKER" != "cargo manifest 1 - LFCS lab-088, do not lose me" ]]; then
  echo "FAIL: mounted - marker.txt is missing or changed"
  exit 1
fi

if [[ "$FLIGHT" != "flight log entry 7 - LFCS lab-088, do not lose me" ]]; then
  echo "FAIL: mounted - logs/flight.log is missing or changed"
  exit 1
fi

echo "PASS: the deck is mounted at $MOUNT_POINT and both original files are intact"
exit 0
GRADER_ROOT
ASTRONA_STUDENT_SCRIPT
