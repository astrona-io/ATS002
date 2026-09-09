#!/usr/bin/env bash
# Bootstrap for lab-033: "persistent vs. transient" recovery scenario.
#
# Installs libvirt/QEMU tooling, ensures libvirtd + its default NAT network
# are up, stages an empty 2G qcow2 at
# /var/lib/libvirt/images/metrics-cache.qcow2, writes a domain XML to
# /root/metrics-cache.xml, and then starts the domain with `virsh create`
# so it comes up TRANSIENT: running, but with no persistent definition in
# /etc/libvirt/qemu/. The student's job is to promote it to a persistent
# domain in place, without stopping it.
#
# NOTE: this VM is itself a QEMU guest, so nested KVM may be unavailable
# (/dev/kvm missing). The XML's <domain type=...> is set to 'kvm' when
# /dev/kvm is usable and 'qemu' (TCG software emulation) otherwise, so
# `virsh create` succeeds either way. The disk has no OS installed -- this
# lab grades libvirt domain lifecycle, not guest boot.

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
sudo qemu-img create -f qcow2 /var/lib/libvirt/images/metrics-cache.qcow2 2G
sudo chmod 644 /var/lib/libvirt/images/metrics-cache.qcow2

DOMTYPE=qemu
if [ -r /dev/kvm ]; then
  DOMTYPE=kvm
fi

sudo tee /root/metrics-cache.xml >/dev/null <<EOF
<domain type='${DOMTYPE}'>
  <name>metrics-cache</name>
  <memory unit='KiB'>1048576</memory>
  <currentMemory unit='KiB'>1048576</currentMemory>
  <vcpu placement='static'>1</vcpu>
  <os>
    <type arch='x86_64'>hvm</type>
    <boot dev='hd'/>
  </os>
  <features>
    <acpi/>
    <apic/>
  </features>
  <clock offset='utc'/>
  <on_poweroff>destroy</on_poweroff>
  <on_reboot>restart</on_reboot>
  <on_crash>destroy</on_crash>
  <devices>
    <emulator>/usr/bin/qemu-system-x86_64</emulator>
    <disk type='file' device='disk'>
      <driver name='qemu' type='qcow2'/>
      <source file='/var/lib/libvirt/images/metrics-cache.qcow2'/>
      <target dev='vda' bus='virtio'/>
    </disk>
    <interface type='network'>
      <source network='default'/>
      <model type='virtio'/>
    </interface>
    <console type='pty'/>
    <memballoon model='virtio'/>
  </devices>
</domain>
EOF

# Start it TRANSIENT: running now, but nothing written to the persistent store.
sudo virsh create /root/metrics-cache.xml

sudo virsh list --all
sudo virsh dominfo metrics-cache || true
