#!/usr/bin/env bash
# Confirms the transient domain 'metrics-cache' was promoted to a persistent
# domain IN PLACE:
#   - the domain still exists (was not lost)
#   - Persistent: yes
#   - a definition file exists at /etc/libvirt/qemu/metrics-cache.xml
#   - autostart is enabled (flag + symlink)
#   - the original spec was preserved, not replaced with a stub:
#     1024 MiB memory, 1 vCPU, default network, the staged qcow2 disk
set -u

DOMAIN=metrics-cache
fail() { echo "FAIL: $1"; exit 1; }

sudo virsh dominfo "$DOMAIN" >/dev/null 2>&1 \
  || fail "domain '$DOMAIN' does not exist -- it must be promoted to persistent, not lost. Run: sudo virsh define /root/metrics-cache.xml"

info="$(sudo virsh dominfo "$DOMAIN" 2>/dev/null)"

persistent="$(echo "$info" | awk -F: '/^Persistent:/ {gsub(/[ \t]/,"",$2); print $2}')"
[ "$persistent" = "yes" ] \
  || fail "domain '$DOMAIN' is still transient (Persistent: ${persistent:-unset}). Promote it in place with: sudo virsh define /root/metrics-cache.xml"

[ -f "/etc/libvirt/qemu/${DOMAIN}.xml" ] \
  || fail "no persistent definition on disk at /etc/libvirt/qemu/${DOMAIN}.xml"

autostart="$(echo "$info" | awk -F: '/^Autostart:/ {gsub(/[ \t]/,"",$2); print $2}')"
[ "$autostart" = "enable" ] \
  || fail "autostart is '${autostart:-unset}', expected 'enable'. Run: sudo virsh autostart $DOMAIN"
[ -e "/etc/libvirt/qemu/autostart/${DOMAIN}.xml" ] \
  || fail "autostart symlink /etc/libvirt/qemu/autostart/${DOMAIN}.xml is missing"

# The promoted definition must keep the original devices/spec, not a stub.
xml="$(sudo virsh dumpxml --inactive "$DOMAIN" 2>/dev/null)"

echo "$xml" | grep -q "network='default'" \
  || fail "domain is no longer attached to the 'default' network -- keep the original network device"
echo "$xml" | grep -q "metrics-cache.qcow2" \
  || fail "domain no longer references /var/lib/libvirt/images/metrics-cache.qcow2 -- do not swap the disk"

max_kib="$(echo "$info" | awk -F: '/^Max memory:/ {gsub(/[^0-9]/,"",$2); print $2}')"
[ "$max_kib" = "1048576" ] \
  || fail "Max memory is '${max_kib:-unset}' KiB, expected 1048576 KiB (1024 MiB) -- keep the original memory size"

vcpus="$(echo "$info" | awk -F: '/^CPU\(s\):/ {gsub(/[^0-9]/,"",$2); print $2}')"
[ "$vcpus" = "1" ] \
  || fail "CPU(s) is '${vcpus:-unset}', expected 1 -- keep the original vCPU count"

echo "PASS: '$DOMAIN' is now persistently defined (original spec preserved), autostart enabled, definition present at /etc/libvirt/qemu/${DOMAIN}.xml"
exit 0
