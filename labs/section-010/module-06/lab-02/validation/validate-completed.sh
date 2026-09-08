#!/usr/bin/env bash
# Confirms metricsd.service was genuinely repaired:
#   - active + enabled
#   - still runs as a NON-root user (the fix must not be "run it as root")
#   - the state directory is now writable by that user: metrics.log grows
set -u

fail() { echo "FAIL: $1"; exit 1; }

state="$(systemctl is-active metricsd.service 2>/dev/null || true)"
[ "$state" = "active" ] || fail "metricsd.service is not active (is-active=$state)"

enabled="$(systemctl is-enabled metricsd.service 2>/dev/null || true)"
[ "$enabled" = "enabled" ] || fail "metricsd.service is not enabled (is-enabled=$enabled)"

# Must still be a non-root service.
svc_user="$(systemctl show -p User --value metricsd.service 2>/dev/null || true)"
[ -n "$svc_user" ] && [ "$svc_user" != "root" ] || fail "metricsd.service now runs as root (User='$svc_user') - fix the permissions, not the user"

# Functional proof: the log is being written.
log=/var/lib/metricsd/metrics.log
[ -f "$log" ] || fail "$log does not exist - metricsd still cannot write its state"
before="$(wc -l < "$log")"
sleep 5
after="$(wc -l < "$log")"
[ "$after" -gt "$before" ] || fail "$log is not growing ($before -> $after) - metricsd is not writing"

echo "PASS: metricsd.service is active, enabled, running as '$svc_user', and writing $log"
exit 0
