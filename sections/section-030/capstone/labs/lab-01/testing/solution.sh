#!/usr/bin/env bash
set -euo pipefail
cd /tmp
tar xzf /tools/vmreport-1.0.tar.gz
cd vmreport-1.0
./configure --bindir=/usr/local/bin --disable-color
make
sudo make install
sudo virt-install --connect qemu:///system --name build-agent --virt-type qemu --arch x86_64 --memory 2048 --vcpus 2 --disk path=/var/lib/libvirt/images/build-agent.qcow2,format=qcow2 --import --network network=default --osinfo detect=on,require=off --graphics none --noautoconsole
sudo virsh autostart build-agent
