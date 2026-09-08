#!/usr/bin/env bash
# Diagnosis variant: only the unit's TasksMax= was the clamp. Confirms:
#   - data-ingest.service TasksMax is raised (infinity or >= 65536) AND
#     applied to the RUNNING unit (systemctl show reflects it live)
#   - the override lives in a student-added drop-in / unit edit
#   - kernel.pid_max and dataproc's ulimit -u are still at their generous
#     baselines and no student file needlessly raised them
set -u

fail() { echo "FAIL: $1"; exit 1; }

# --- the ceiling that SHOULD have been raised ---
tm="$(systemctl show data-ingest.service -p TasksMax --value 2>/dev/null || true)"
if [ "$tm" = "infinity" ]; then :; elif [ "${tm//[!0-9]/}" = "$tm" ] && [ -n "$tm" ] && [ "$tm" -ge 65536 ] 2>/dev/null; then :; else
  fail "data-ingest.service TasksMax is '$tm', expected 'infinity' or >= 65536, applied to the running unit"
fi
# It must be a real override, not the bootstrap's TasksMax=64 still in the vendor unit.
override="$(systemctl show data-ingest.service -p DropInPaths --value 2>/dev/null || true)"
grepd="$(grep -rl 'TasksMax' /etc/systemd/system/data-ingest.service.d/ /etc/systemd/system/data-ingest.service 2>/dev/null || true)"
[ -n "$override" ] || [ -n "$grepd" ] || fail "TasksMax reads OK but no student drop-in / unit edit sets it - did daemon-reload + restart run?"

# --- the two ceilings that should NOT have needed touching ---
pidmax="$(sysctl -n kernel.pid_max 2>/dev/null || echo 0)"
[ "$pidmax" -ge 1048576 ] || fail "kernel.pid_max dropped to '$pidmax'"
student_pidmax="$(grep -rlE '^\s*kernel\.pid_max\s*=' /etc/sysctl.d/ /etc/sysctl.conf 2>/dev/null | grep -v '00-pid-max-baseline' || true)"
[ -z "$student_pidmax" ] || fail "you added $student_pidmax for kernel.pid_max - it was NOT the limiting ceiling; only TasksMax needed raising"

ul="$(sudo -iu dataproc bash -c 'ulimit -u' 2>/dev/null || true)"
if [ "$ul" != "unlimited" ]; then [ "$ul" -ge 65536 ] 2>/dev/null || fail "dataproc's ulimit -u dropped to '$ul' - it was already generous"; fi
student_lim="$(grep -rlE '^\s*dataproc\s+(soft|hard)\s+nproc' /etc/security/limits.d/ 2>/dev/null | grep -v '00-dataproc-baseline' || true)"
[ -z "$student_lim" ] || fail "you added $student_lim to raise dataproc's nproc - it was NOT the limiting ceiling; only TasksMax needed raising"

echo "PASS: only TasksMax was raised (now $tm, applied live); pid_max ($pidmax) and ulimit -u ($ul) correctly left as-is"
exit 0
