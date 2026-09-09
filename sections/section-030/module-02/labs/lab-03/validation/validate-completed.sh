#!/usr/bin/env bash
# Confirms 'web-db' was reconfigured to 2048 MiB / 2 vCPU PERSISTENTLY:
#   - Persistent: yes
#   - the inactive (on-disk) config has <memory> and <currentMemory> at
#     2097152 KiB and <vcpu> at 2  -- i.e. it survives a reboot; a bare
#     `virsh setmem` / `virsh setvcpus` without --config would NOT set this
#   - the domain is running and the running domain reflects 2048 MiB / 2 vCPU
#   - the original disk and default-network attachment are untouched
set -u

DOMAIN=web-db
fail() { echo "FAIL: $1"; exit 1; }

sudo virsh dominfo "$DOMAIN" >/dev/null 2>&1 \
  || fail "domain '$DOMAIN' does not exist"

info="$(sudo virsh dominfo "$DOMAIN" 2>/dev/null)"

persistent="$(echo "$info" | awk -F: '/^Persistent:/ {gsub(/[ \t]/,"",$2); print $2}')"
[ "$persistent" = "yes" ] \
  || fail "domain '$DOMAIN' is not persistent (Persistent: ${persistent:-unset})"

state="$(echo "$info" | awk -F: '/^State:/ {gsub(/^[ \t]+/,"",$2); print $2}')"
[ "$state" = "running" ] \
  || fail "domain '$DOMAIN' is '${state:-unset}', not running -- start it after reconfiguring so the change takes effect"

# --- Persistent (inactive) config: this is what survives a reboot ---
inact="$(sudo virsh dumpxml --inactive "$DOMAIN" 2>/dev/null)"

pers_mem="$(echo "$inact" | sed -n "s/.*<memory[^>]*>\([0-9]\{1,\}\)<\/memory>.*/\1/p" | head -1)"
pers_cur="$(echo "$inact" | sed -n "s/.*<currentMemory[^>]*>\([0-9]\{1,\}\)<\/currentMemory>.*/\1/p" | head -1)"
pers_vcpu="$(echo "$inact" | sed -n "s/.*<vcpu[^>]*>\([0-9]\{1,\}\)<\/vcpu>.*/\1/p" | head -1)"

[ "$pers_mem" = "2097152" ] \
  || fail "persistent <memory> is '${pers_mem:-unset}' KiB, expected 2097152 (2048 MiB). A live-only change ('virsh setmem' without --config) does not persist -- edit the persistent config (virsh edit, or virsh setmaxmem --config)."
[ -n "${pers_cur:-}" ] && [ "$pers_cur" -ge 2097152 ] 2>/dev/null \
  || fail "persistent <currentMemory> is '${pers_cur:-unset}' KiB -- it still caps the domain below 2048 MiB. Raise it too (virsh setmem --config, or bump <currentMemory> in virsh edit)."
[ "$pers_vcpu" = "2" ] \
  || fail "persistent <vcpu> is '${pers_vcpu:-unset}', expected 2. Use 'virsh setvcpus $DOMAIN 2 --config --maximum' or edit <vcpu> directly."

# --- Running domain must reflect the new spec ---
live_kib="$(echo "$info" | awk -F: '/^Max memory:/ {gsub(/[^0-9]/,"",$2); print $2}')"
live_vcpu="$(echo "$info" | awk -F: '/^CPU\(s\):/ {gsub(/[^0-9]/,"",$2); print $2}')"

[ "$live_kib" = "2097152" ] \
  || fail "running domain Max memory is '${live_kib:-unset}' KiB, expected 2097152 -- restart the domain so the persistent change is applied"
[ "$live_vcpu" = "2" ] \
  || fail "running domain CPU(s) is '${live_vcpu:-unset}', expected 2 -- restart the domain to pick up the new vCPU count"

# --- Original devices unchanged ---
echo "$inact" | grep -q "network='default'" \
  || fail "domain must stay attached to the 'default' network"
echo "$inact" | grep -q "web-db.qcow2" \
  || fail "domain disk must remain /var/lib/libvirt/images/web-db.qcow2"

echo "PASS: '$DOMAIN' reconfigured to 2048 MiB / 2 vCPU in the persistent config and running with it; disk and network untouched"
exit 0
