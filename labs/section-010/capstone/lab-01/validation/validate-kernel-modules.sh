#!/usr/bin/env bash
# Confirms dummy is loaded live with numdummies=4 and persisted (both the
# load and the parameter), and that pcspkr is blacklisted, unloaded now,
# and stays absent after a simulated hardware re-detection pass.

set -u

fail=0

# --- dummy: loaded live with numdummies=4 ---

if ! lsmod | grep -qw dummy; then
  echo "FAIL: kernel modules - dummy module is not currently loaded"
  fail=1
else
  param=$(cat /sys/module/dummy/parameters/numdummies 2>/dev/null || echo "")
  if [[ "$param" != "4" ]]; then
    echo "FAIL: kernel modules - dummy numdummies parameter is '$param', expected '4'"
    fail=1
  else
    echo "PASS: kernel modules - dummy is loaded live with numdummies=4"
  fi
fi

# --- dummy: persisted load + parameter ---

if ! grep -rqw 'dummy' /etc/modules-load.d/ 2>/dev/null; then
  echo "FAIL: kernel modules - no /etc/modules-load.d/*.conf file persists the dummy module load"
  fail=1
else
  echo "PASS: kernel modules - dummy load is persisted via /etc/modules-load.d/"
fi

if ! grep -rqE 'options\s+dummy\s+numdummies=4' /etc/modprobe.d/ 2>/dev/null; then
  echo "FAIL: kernel modules - no /etc/modprobe.d/*.conf file persists 'options dummy numdummies=4'"
  fail=1
else
  echo "PASS: kernel modules - dummy numdummies=4 is persisted via /etc/modprobe.d/"
fi

# --- pcspkr: blacklisted and unloaded ---

if ! grep -rqE '^\s*blacklist\s+pcspkr\b' /etc/modprobe.d/ 2>/dev/null; then
  echo "FAIL: kernel modules - no /etc/modprobe.d/*.conf file blacklists pcspkr"
  fail=1
else
  echo "PASS: kernel modules - pcspkr is blacklisted via /etc/modprobe.d/"
fi

if lsmod | grep -qw pcspkr; then
  echo "FAIL: kernel modules - pcspkr is still loaded; unload it with 'sudo modprobe -r pcspkr'"
  fail=1
else
  sudo udevadm trigger --subsystem-match=sound >/dev/null 2>&1 || true
  sudo udevadm settle --timeout=10 >/dev/null 2>&1 || true

  if lsmod | grep -qw pcspkr; then
    echo "FAIL: kernel modules - pcspkr reloaded automatically after udevadm trigger; blacklist is not holding"
    fail=1
  else
    echo "PASS: kernel modules - pcspkr is unloaded and stays absent after re-triggered hardware detection"
  fi
fi

if [[ "$fail" -ne 0 ]]; then
  exit 1
fi

exit 0
