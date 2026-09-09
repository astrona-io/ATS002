#!/usr/bin/env bash
# Confirms automake -- pre-installed independently of the Development
# Tools group, before the student ever touched it -- survived the group
# removal. Proves the student understands (and dnf actually enforces)
# tracking-based group removal: a package present beforehand for an
# unrelated reason is not swept up just because it also happens to be a
# group member.

set -u

if ! sudo docker exec rpmbox rpm -q automake >/dev/null 2>&1; then
  echo "FAIL: automake survives - automake is no longer installed inside rpmbox; it should have survived the group removal since it predates the group install"
  exit 1
fi

echo "PASS: automake is still installed inside rpmbox after the group removal"
exit 0
