#!/usr/bin/env bash
# Confirms pcspkr is blacklisted, currently unloaded, and stays absent after
# a simulated hardware re-detection pass (udevadm trigger).

set -u

if ! grep -rqE '^\s*blacklist\s+pcspkr\b' /etc/modprobe.d/ 2>/dev/null; then
  echo "FAIL: pcspkr blacklisted - no /etc/modprobe.d/*.conf file blacklists pcspkr"
  exit 1
fi

if lsmod | grep -qw pcspkr; then
  echo "FAIL: pcspkr blacklisted - pcspkr is still loaded; unload it with 'sudo modprobe -r pcspkr'"
  exit 1
fi

sudo udevadm trigger --subsystem-match=sound >/dev/null 2>&1 || true
sudo udevadm settle --timeout=10 >/dev/null 2>&1 || true

if lsmod | grep -qw pcspkr; then
  echo "FAIL: pcspkr blacklisted - pcspkr reloaded automatically after udevadm trigger; blacklist is not holding"
  exit 1
fi

echo "PASS: pcspkr is blacklisted, unloaded, and stays absent after re-triggered hardware detection"
exit 0
