#!/usr/bin/env bash
# Match the account used by astrona ssh, including its home and permissions.
sudo -H -u student bash <<'ASTRONA_STUDENT_SCRIPT'
# Bootstrap: ensures pcspkr is loaded (simulating the "already beeping"
# starting state), and ensures dummy is NOT already loaded, so the student
# has a clean, deterministic starting point for both module tasks regardless
# of what the underlying QEMU platform auto-loads.

set -eu

sudo modprobe pcspkr || true
sudo modprobe -r dummy 2>/dev/null || true
ASTRONA_STUDENT_SCRIPT
