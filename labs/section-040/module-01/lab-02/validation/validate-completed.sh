#!/usr/bin/env bash
# Confirms the credsync AppArmor READ denial was genuinely fixed:
#   - the profile is loaded and in enforce mode (not complain)
#   - the daemon can now read /etc/credsync/api.key -> it writes
#     /run/credsync/ready only when the read succeeds
#   - no fresh apparmor="DENIED" for credsync in the last few seconds
set -u

fail() { echo "FAIL: $1"; exit 1; }

# Profile loaded + enforcing.
status="$(sudo aa-status 2>/dev/null)"
echo "$status" | grep -qE 'enforce mode' || fail "aa-status shows no profiles in enforce mode"
echo "$status" | sed -n '/enforce mode/,/complain mode/p' | grep -q '/usr/sbin/credsync' \
  || fail "the /usr/sbin/credsync profile is not in enforce mode (left in complain, or unloaded?)"

# Service running.
[ "$(systemctl is-active credsync 2>/dev/null)" = "active" ] || fail "credsync.service is not active"

# Functional proof: the ready marker must exist and be fresh (updated
# within the daemon's 5s loop => the read is succeeding right now).
mark=/run/credsync/ready
[ -f "$mark" ] || fail "$mark missing - credsync still cannot read /etc/credsync/api.key"
age=$(( $(date +%s) - $(stat -c %Y "$mark") ))
sleep 6
age2=$(( $(date +%s) - $(stat -c %Y "$mark") ))
[ "$age2" -lt 8 ] || fail "$mark is stale (age ${age2}s) - the key read is not succeeding on the current cycle"

# No fresh denials.
den="$(sudo journalctl -k --since '10 seconds ago' 2>/dev/null | grep 'apparmor="DENIED"' | grep -c 'credsync' || true)"
[ "${den:-0}" -eq 0 ] || fail "$den fresh apparmor DENIED entries for credsync in the last 10s"

echo "PASS: credsync profile is enforcing, the daemon reads /etc/credsync/api.key, and no fresh denials"
exit 0
