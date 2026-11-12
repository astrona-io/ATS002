#!/usr/bin/env bash
# Match the account used by astrona ssh, including its home and permissions.
sudo -H -u student bash <<'ASTRONA_STUDENT_SCRIPT'
# Inspect protected state; user access checks select their target account explicitly.
sudo -n bash <<'GRADER_ROOT'
# Confirms the first MiB of the suspect disk still has its original hash,
# which proves the scan did not write to it.

set -u

SUSPECT_ID=/dev/disk/by-id/virtio-lab08a-suspect
STORED=/var/lib/lab08a/suspect.sha256

if [[ ! -e "$SUSPECT_ID" ]]; then
  echo "FAIL: data - the suspect disk is missing"
  exit 1
fi

EXPECTED=$(sudo cat "$STORED" 2>/dev/null | awk '{print $1}')
if [[ -z "$EXPECTED" ]]; then
  echo "FAIL: data - the stored hash is missing"
  exit 1
fi

ACTUAL=$(sudo head -c 1048576 "$(readlink -f "$SUSPECT_ID")" | sha256sum | awk '{print $1}')

if [[ "$ACTUAL" != "$EXPECTED" ]]; then
  echo "FAIL: data - the start of the suspect disk changed"
  exit 1
fi

echo "PASS: the data on the suspect disk is intact"
exit 0
GRADER_ROOT
ASTRONA_STUDENT_SCRIPT
