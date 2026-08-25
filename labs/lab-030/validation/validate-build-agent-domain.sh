#!/usr/bin/env bash
# Confirms the build-agent domain is defined persistently with 2048 MiB
# memory, 2 vCPUs, the default network attached, and autostart enabled.
set -u

DOMAIN=build-agent

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

network=$(sudo virsh dumpxml "$DOMAIN" 2>/dev/null | grep -o "network='default'")
if [[ -z "$network" ]]; then
  echo "FAIL: domain '$DOMAIN' is not attached to the 'default' libvirt network"
  exit 1
fi

echo "PASS: domain '$DOMAIN' is persistently defined with 2048 MiB memory, 2 vCPUs, attached to the default network, and autostart enabled"
exit 0
