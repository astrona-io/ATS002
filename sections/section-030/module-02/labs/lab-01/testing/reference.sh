#!/usr/bin/env bash
set -euo pipefail
sudo virt-install --connect qemu:///system --virt-type qemu --arch x86_64 \
  --name inventory-db --memory 2048 --vcpus 2 \
  --disk path=/var/lib/libvirt/images/inventory-db.qcow2,format=qcow2,bus=virtio \
  --import --network network=default,model=virtio --osinfo generic \
  --graphics none --noautoconsole
sudo virsh autostart inventory-db
