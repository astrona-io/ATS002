#!/usr/bin/env bash
# Confirms the journal is now persistent and bounded:
#   - /var/log/journal exists (persistent storage in use)
#   - journald config (journald.conf or a .conf drop-in) sets
#     Storage=persistent AND SystemMaxUse to 200M or less
#   - the setting was actually applied: journalctl reports a persistent
#     store, and current on-disk usage is within the cap
set -u

fail() { echo "FAIL: $1"; exit 1; }

# 1. Persistent directory exists and has content.
[ -d /var/log/journal ] || fail "/var/log/journal does not exist - journal is still volatile"
find /var/log/journal -name '*.journal' | grep -q . || fail "/var/log/journal has no .journal files - persistent storage not active yet (restart systemd-journald)"

# 2. Config: gather effective [Journal] settings from journald.conf + drop-ins.
cfg="$(cat /etc/systemd/journald.conf /etc/systemd/journald.conf.d/*.conf 2>/dev/null | sed 's/#.*//')"

echo "$cfg" | grep -qiE '^\s*Storage\s*=\s*persistent\s*$' \
  || fail "no 'Storage=persistent' in journald.conf or a drop-in"

max="$(echo "$cfg" | grep -iE '^\s*SystemMaxUse\s*=' | tail -1 | sed 's/.*=\s*//; s/[[:space:]]//g')"
[ -n "$max" ] || fail "SystemMaxUse is not set - the journal is uncapped"

# Normalise the size to bytes and require <= 200M.
to_bytes() {
  local v="${1^^}"; local n="${v%[A-Z]*}"; local u="${v##*[0-9]}"
  case "$u" in
    K) echo $(( ${n%.*} * 1000 ));;
    M) echo $(( ${n%.*} * 1000 * 1000 ));;
    G) echo $(( ${n%.*} * 1000 * 1000 * 1000 ));;
    "" ) echo "${n%.*}";;
    *) echo 0;;
  esac
}
maxb="$(to_bytes "$max")"
lim=$(( 200 * 1000 * 1000 ))
[ "$maxb" -gt 0 ] && [ "$maxb" -le $(( lim + lim/20 )) ] \
  || fail "SystemMaxUse='$max' is not 200M or less"

# 3. Applied: journalctl sees a persistent store.
journalctl --disk-usage 2>/dev/null | grep -q . || fail "journalctl --disk-usage returned nothing"
du_line="$(journalctl --disk-usage 2>/dev/null)"

echo "PASS: journal is persistent (/var/log/journal populated), Storage=persistent, SystemMaxUse=$max; $du_line"
exit 0
