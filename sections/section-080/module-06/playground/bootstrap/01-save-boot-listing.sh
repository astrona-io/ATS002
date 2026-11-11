#!/usr/bin/env bash
# Match the account used by astrona ssh, including its home and permissions.
sudo -H -u student bash <<'ASTRONA_STUDENT_SCRIPT'
# Starting state for the initramfs playground. The machine stays healthy:
# this only saves a listing of /boot so you can compare it with the state
# after your own experiments. Nothing is deleted or rebuilt.

set -eu

sudo sh -c 'ls -l /boot > /root/boot-listing.original.txt'
ASTRONA_STUDENT_SCRIPT
