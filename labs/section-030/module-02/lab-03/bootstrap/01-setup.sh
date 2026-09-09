#!/usr/bin/env bash
# Bootstrap for lab-034: reconfigure a persistent domain.
#
# Installs libvirt/QEMU, ensures libvirtd + the default NAT network are up,
# stages an empty 2G qcow2 at /var/lib/libvirt/images/web-db.qcow2, then
# defines the persistent domain 'web-db' UNDER-PROVISIONED -- 512 MiB
# memory, 1 vCPU -- and leaves it shut off. The student must raise it to
# 2048 MiB / 2 vCPU in the persistent config, then start it.
#
# NOTE: this VM is itself a QEMU guest, so nested KVM may be unavailable.
# virt-install falls back to TCG software emulation automatically. The disk
# has no OS installed -- this lab grades libvirt domain configuration, not
# guest boot.

set -eu

sudo systemctl enable --now libvirtd

for i in $(seq 1 30); do
  if sudo virsh list --all >/dev/null 2>&1; then
    break
  fi
  sleep 1
done

if sudo virsh net-info default >/dev/null 2>&1; then
  sudo virsh net-start default 2>/dev/null || true
  sudo virsh net-autostart default >/dev/null 2>&1 || true
fi

sudo mkdir -p /var/lib/libvirt/images
sudo qemu-img create -f qcow2 /var/lib/libvirt/images/web-db.qcow2 2G
sudo chmod 644 /var/lib/libvirt/images/web-db.qcow2

sudo virt-install \
  --name web-db \
  --memory 512 \
  --vcpus 1 \
  --disk path=/var/lib/libvirt/images/web-db.qcow2,format=qcow2 \
  --import \
  --network network=default \
  --os-variant detect=on,require=off \
  --graphics none \
  --noautoconsole

# Leave it shut off so the student edits the persistent config, not just
# the live domain.
sleep 2
sudo virsh destroy web-db >/dev/null 2>&1 || true

sudo virsh dominfo web-db || true
