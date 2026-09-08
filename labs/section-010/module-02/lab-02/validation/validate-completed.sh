#!/usr/bin/env bash
# Diagnosis variant: only ulimit -u was the clamp. Confirms:
#   - dataproc's ulimit -u is raised (>= 32768) for a fresh session AND
#     persisted via a student-added /etc/security/limits.d/ drop-in
#   - kernel.pid_max is still at its generous baseline (was never the
#     problem; a student drop-in raising it further is a diagnosis miss)
#   - the unit's TasksMax is still infinity/high (also not the problem)
set -u

fail() { echo "FAIL: $1"; exit 1; }

threshold=32768

id dataproc >/dev/null 2>&1 || fail "dataproc user missing"

# --- the ceiling that SHOULD have been raised ---
actual="$(sudo -iu dataproc bash -c 'ulimit -u' 2>/dev/null || true)"
[ -n "$actual" ] || fail "could not read ulimit -u for dataproc"
if [ "$actual" != "unlimited" ]; then
  [ "$actual" -ge "$threshold" ] 2>/dev/null || fail "dataproc's fresh-session ulimit -u is '$actual', expected >= $threshold"
fi
grep -rqE '^\s*dataproc\s+(soft|hard)\s+nproc\s+([3-9][0-9]{4,}|[0-9]{6,}|unlimited)\b' \
  /etc/security/limits.d/ 2>/dev/null \
  || fail "no student /etc/security/limits.d/*.conf drop-in raises dataproc's nproc"

# --- the two ceilings that should NOT have needed touching ---
pidmax="$(sysctl -n kernel.pid_max 2>/dev/null || echo 0)"
[ "$pidmax" -ge 1048576 ] || fail "kernel.pid_max dropped to '$pidmax' - it was already generous, do not lower it"

student_pidmax="$(grep -rlE '^\s*kernel\.pid_max\s*=' /etc/sysctl.d/ /etc/sysctl.conf 2>/dev/null | grep -v '00-pid-max-baseline' || true)"
[ -z "$student_pidmax" ] || fail "you added $student_pidmax to raise kernel.pid_max - it was NOT the limiting ceiling here; only ulimit -u needed raising"

tm="$(systemctl show data-ingest.service -p TasksMax --value 2>/dev/null || true)"
[ "$tm" = "infinity" ] || { [ "${tm//[!0-9]/}" = "$tm" ] && [ "$tm" -ge 65536 ] 2>/dev/null; } \
  || fail "data-ingest.service TasksMax is '$tm' - it was already uncapped and did not need changing"

echo "PASS: only ulimit -u was raised (now $actual); pid_max ($pidmax) and TasksMax ($tm) correctly left as-is"
exit 0
