#!/usr/bin/env bash
# OS prep for the kernel-modules playground. This host is a real qemu VM
# with its own kernel, so modprobe genuinely loads modules. Nothing is
# loaded or configured here — that is what you explore. No task, no grading.
set -eu

export DEBIAN_FRONTEND=noninteractive
sudo apt-get update -qq
# kmod (lsmod/modprobe/modinfo/depmod) is normally already present; make sure.
sudo apt-get install -y -qq kmod

# The 'dummy' virtual-NIC module is in-tree and always available. 'pcspkr'
# may or may not exist for a VM kernel — the module text uses it as the
# real-world example; the checkpoints use 'dummy', which is guaranteed.
echo "[playground] dummy module available: $(modinfo -n dummy 2>/dev/null || echo 'built-in path varies')"

echo "[playground] kernel-modules-lab: ready. Nothing is loaded."
echo "[playground] try:  lsmod | head  ;  modinfo -p dummy  ;  sudo modprobe dummy numdummies=2"
