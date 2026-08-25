#!/usr/bin/env bash
# Confirms gcc -- installed only because of the Development Tools group
# install, with no independent reason to be present beforehand -- was
# actually removed along with the group. Proves the group removal did
# real work, not nothing at all.

set -u

if sudo docker exec rpmbox rpm -q gcc >/dev/null 2>&1; then
  echo "FAIL: gcc removed - gcc is still installed inside rpmbox; it was only pulled in by the group install and should have been removed with the group"
  exit 1
fi

echo "PASS: gcc is not installed inside rpmbox, confirming the group removal actually removed group-installed packages"
exit 0
