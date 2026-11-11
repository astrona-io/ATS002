#!/usr/bin/env bash
set -euo pipefail
sudo mkdir -p /opt/course/audit
uname -r | sudo tee /opt/course/audit/kernel-release
sysctl -n vm.swappiness | sudo tee /opt/course/audit/vm-swappiness
sudo mkdir -p /etc/sysctl.d
sudo tee /etc/sysctl.d/99-pid-max.conf >/dev/null <<'REFERENCE_FILE'
kernel.pid_max=1048576
REFERENCE_FILE
sudo sysctl --system
sudo mkdir -p /etc/modules-load.d
sudo tee /etc/modules-load.d/dummy.conf >/dev/null <<'REFERENCE_FILE'
dummy
REFERENCE_FILE
sudo mkdir -p /etc/modprobe.d
sudo tee /etc/modprobe.d/dummy.conf >/dev/null <<'REFERENCE_FILE'
options dummy numdummies=4
REFERENCE_FILE
sudo mkdir -p /etc/modprobe.d
sudo tee /etc/modprobe.d/blacklist-pcspkr.conf >/dev/null <<'REFERENCE_FILE'
blacklist pcspkr
REFERENCE_FILE
if lsmod | grep -qw dummy; then sudo modprobe -r dummy; fi
sudo modprobe dummy
if lsmod | grep -qw pcspkr; then sudo modprobe -r pcspkr; fi
sudo mkdir -p /etc/udev/rules.d
sudo tee /etc/udev/rules.d/99-telemetry-disk.rules >/dev/null <<'REFERENCE_FILE'
SUBSYSTEM=="block", ENV{DEVTYPE}=="disk", ATTRS{serial}=="lab010-telemetry", SYMLINK+="telemetry-disk"
REFERENCE_FILE
sudo udevadm control --reload-rules
sudo udevadm trigger --subsystem-match=block
sudo udevadm settle
sudo systemctl stop telemetry-agent
