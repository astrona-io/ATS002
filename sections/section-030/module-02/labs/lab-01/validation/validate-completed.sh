#!/usr/bin/env bash
# Match the account used by astrona ssh, including its home and permissions.
sudo -H -u student bash <<'ASTRONA_STUDENT_SCRIPT'
set -u

DOMAIN=inventory-db

if ! sudo virsh dominfo "$DOMAIN" >/dev/null 2>&1; then
  echo "FAIL: domain '$DOMAIN' is not defined"
  exit 1
fi

dominfo_out=$(sudo virsh dominfo "$DOMAIN" 2>/dev/null)

persistent=$(echo "$dominfo_out" | awk -F: '/^Persistent:/ {gsub(/^[ \t]+/,"",$2); print $2}')
if [[ "$persistent" != "yes" ]]; then
  echo "FAIL: domain '$DOMAIN' is not persistently defined (Persistent: '$persistent')"
  exit 1
fi

max_mem_kib=$(echo "$dominfo_out" | awk -F: '/^Max memory:/ {gsub(/[^0-9]/,"",$2); print $2}')
if [[ "$max_mem_kib" != "2097152" ]]; then
  echo "FAIL: domain '$DOMAIN' Max memory is '${max_mem_kib:-unset}' KiB, expected 2097152 KiB (2048 MiB)"
  exit 1
fi

vcpus=$(echo "$dominfo_out" | awk -F: '/^CPU\(s\):/ {gsub(/[^0-9]/,"",$2); print $2}')
if [[ "$vcpus" != "2" ]]; then
  echo "FAIL: domain '$DOMAIN' has '${vcpus:-unset}' vCPU(s), expected 2"
  exit 1
fi

autostart=$(echo "$dominfo_out" | awk -F: '/^Autostart:/ {gsub(/^[ \t]+/,"",$2); print $2}')
if [[ "$autostart" != "enable" ]]; then
  echo "FAIL: domain '$DOMAIN' Autostart is '${autostart:-unset}', expected 'enable'"
  exit 1
fi

if ! sudo test -e "/etc/libvirt/qemu/autostart/${DOMAIN}.xml"; then
  echo "FAIL: autostart symlink /etc/libvirt/qemu/autostart/${DOMAIN}.xml not found"
  exit 1
fi

network=$(sudo virsh dumpxml "$DOMAIN" 2>/dev/null | grep -o "network='default'")
if [[ -z "$network" ]]; then
  echo "FAIL: domain '$DOMAIN' is not attached to the 'default' libvirt network"
  exit 1
fi

if [[ "$(sudo virsh domstate "$DOMAIN" | xargs)" != running ]]; then
  echo 'FAIL: guest is not running'; exit 1
fi
if ! sudo virsh domblklist "$DOMAIN" --details | grep -Fq /var/lib/libvirt/images/inventory-db.qcow2; then
  echo 'FAIL: guest must boot the assigned inventory-db disk'; exit 1
fi
# A running QEMU process can be stuck in firmware. Require a service from the guest OS.
for attempt in $(seq 1 90); do
  address=$(sudo virsh domifaddr "$DOMAIN" --source lease | awk '$3 == "ipv4" {split($4,a,"/"); print a[1]; exit}')
  if [[ "$address" == 192.168.122.* ]] && ssh-keyscan -T 2 "$address" 2>/dev/null | grep -q 'ssh-'; then
    echo "PASS: persistent inventory-db booted Linux and answers SSH at $address"
    exit 0
  fi
  sleep 2
done
echo 'FAIL: guest has no reachable SSH service on its libvirt DHCP lease'
exit 1
ASTRONA_STUDENT_SCRIPT
