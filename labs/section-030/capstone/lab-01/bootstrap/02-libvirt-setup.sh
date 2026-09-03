#!/usr/bin/env bash
# Bootstrap (2/2): installs libvirt/QEMU tooling, ensures libvirtd is
# running with its default NAT network active, and stages an empty 2G
# qcow2 disk at /var/lib/libvirt/images/build-agent.qcow2.
#
# NOTE: this VM is itself a QEMU guest, so nested KVM acceleration may
# not be available. That's fine -- virt-install/virsh fall back to
# software (TCG) emulation automatically, and domain lifecycle
# transitions (defined -> running -> shut off) work correctly either
# way. The disk image is intentionally left without a bootable OS
# inside it -- this lab grades libvirt domain lifecycle management (and
# vmreport's ability to query it), not guest OS behavior.

set -eu

if ! command -v virsh >/dev/null 2>&1; then
  sudo apt-get update -y
  sudo apt-get install -y \
    qemu-system-x86 \
    libvirt-daemon-system \
    libvirt-clients \
    virtinst \
    bridge-utils
fi

sudo systemctl enable --now libvirtd

for i in $(seq 1 30); do
  if sudo virsh list --all >/dev/null 2>&1; then
    break
  fi
  sleep 1
done

if ! sudo virsh net-info default >/dev/null 2>&1; then
  echo "default libvirt network not found -- unexpected on this image" >&2
  exit 1
fi

if ! sudo virsh net-info default | grep -q "Active:.*yes"; then
  sudo virsh net-start default
fi

sudo virsh net-autostart default >/dev/null 2>&1 || true

sudo mkdir -p /var/lib/libvirt/images
sudo qemu-img create -f qcow2 /var/lib/libvirt/images/build-agent.qcow2 2G
sudo chmod 644 /var/lib/libvirt/images/build-agent.qcow2
