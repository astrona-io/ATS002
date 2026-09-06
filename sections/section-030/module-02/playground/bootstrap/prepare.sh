#!/usr/bin/env bash
# OS prep for PLAYGROUND — libvirt Virtual Machine Lifecycle
#
# Runs once when the environment comes up. Environment preparation only:
# install libvirt + QEMU, make sure libvirtd and its default NAT network
# are up, and stage an empty qcow2 disk to define a domain around. There
# is no task and no grading.
#
# NOTE: this host is itself a QEMU guest, so nested KVM acceleration may
# not be available (/dev/kvm may be missing). That is fine here --
# virt-install / virsh fall back to software (TCG) emulation
# automatically, and every domain lifecycle transition the module teaches
# (defined -> running -> shut off, shutdown vs destroy) behaves the same
# way with or without KVM. The staged disk is intentionally left with no
# bootable OS inside it: the module is about the libvirt domain
# lifecycle, not guest boot.
set -euo pipefail

echo "[playground] libvirt-vm-lifecycle: installing libvirt + QEMU ..."
export DEBIAN_FRONTEND=noninteractive
sudo apt-get update -qq
sudo apt-get install -y -qq \
  libvirt-daemon-system \
  libvirt-clients \
  virtinst \
  qemu-system-x86 \
  qemu-utils

echo "[playground] enabling libvirtd ..."
sudo systemctl enable --now libvirtd

# Wait for the libvirt socket to accept connections.
for _ in $(seq 1 30); do
  if sudo virsh list --all >/dev/null 2>&1; then
    break
  fi
  sleep 1
done

# The 'default' NAT network ships with libvirt-daemon-system but is not
# always auto-started on first boot -- do not assume.
if ! sudo virsh net-info default >/dev/null 2>&1; then
  echo "[playground] WARNING: 'default' network missing -- unexpected on this image" >&2
else
  if ! sudo virsh net-info default | grep -q "Active:.*yes"; then
    sudo virsh net-start default
  fi
  sudo virsh net-autostart default >/dev/null 2>&1 || true
fi

# Stage an empty disk image to wrap a domain around. Empty on purpose:
# 'virt-install --import' will define + start a domain from it that then
# sits at "no bootable device" -- which is exactly enough to explore
# every lifecycle command.
echo "[playground] staging /var/lib/libvirt/images/inventory-db.qcow2 (2G, empty) ..."
sudo mkdir -p /var/lib/libvirt/images
if [ ! -f /var/lib/libvirt/images/inventory-db.qcow2 ]; then
  sudo qemu-img create -f qcow2 /var/lib/libvirt/images/inventory-db.qcow2 2G
  sudo chmod 644 /var/lib/libvirt/images/inventory-db.qcow2
fi

echo "[playground] ready. Try:  sudo virsh list --all"
