#!/usr/bin/env bash
# Match the account used by astrona ssh, including its home and permissions.
sudo -H -u student bash <<'ASTRONA_STUDENT_SCRIPT'
set -euo pipefail
sudo systemctl enable --now libvirtd
sudo virsh net-info default >/dev/null
sudo virsh net-start default || sudo virsh net-info default | grep 'Active:.*yes' >/dev/null
sudo virsh net-autostart default
# Use the same small x86 guest on both outer VM architectures; TCG needs no nested KVM.
image=$(mktemp)
trap 'rm -f "$image"' EXIT
curl --fail --location --retry 3 -o "$image" https://github.com/cirros-dev/cirros/releases/download/0.6.3/cirros-0.6.3-x86_64-disk.img
printf '%s  %s\n' 7d6355852aeb6dbcd191bcda7cd74f1536cfe5cbf8a10495a7283a8396e4b75b "$image" | sha256sum --check
sudo install -m 0644 "$image" /var/lib/libvirt/images/inventory-db.qcow2
sudo qemu-img resize /var/lib/libvirt/images/inventory-db.qcow2 2G
ASTRONA_STUDENT_SCRIPT
