#!/usr/bin/env bash
# Confirms device.txt names the suspect disk and size.txt holds its size.

set -u

DIR=/var/tmp/disk-report
SUSPECT_ID=/dev/disk/by-id/virtio-lab08a-suspect

if [[ ! -e "$SUSPECT_ID" ]]; then
  echo "FAIL: device - the suspect disk is missing"
  exit 1
fi

SUSPECT=$(readlink -f "$SUSPECT_ID")
EXPECTED_SIZE=$(lsblk -bdno SIZE "$SUSPECT" | tr -d ' ')

if [[ ! -s "$DIR/device.txt" ]]; then
  echo "FAIL: device - $DIR/device.txt is missing or empty"
  exit 1
fi

GOT_DEVICE=$(head -n 1 "$DIR/device.txt" | tr -d ' \r')
if [[ "$(readlink -f "$GOT_DEVICE" 2>/dev/null)" != "$SUSPECT" ]]; then
  echo "FAIL: device - device.txt says '$GOT_DEVICE', expected the suspect disk"
  exit 1
fi

if [[ ! -s "$DIR/size.txt" ]]; then
  echo "FAIL: device - $DIR/size.txt is missing or empty"
  exit 1
fi

GOT_SIZE=$(head -n 1 "$DIR/size.txt" | tr -d ' \r')
if [[ "$GOT_SIZE" != "$EXPECTED_SIZE" ]]; then
  echo "FAIL: device - size.txt says '$GOT_SIZE', expected $EXPECTED_SIZE"
  exit 1
fi

echo "PASS: device.txt names the suspect disk and size.txt is correct"
exit 0
