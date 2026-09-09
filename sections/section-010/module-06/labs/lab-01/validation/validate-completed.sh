#!/usr/bin/env bash
# Confirms reportd.service was genuinely repaired:
#   - active (running) now
#   - enabled for boot
#   - actually writing its heartbeat file (proves ExecStart runs the real
#     binary, not that the state was forced with `systemctl reset-failed`
#     or a stub).
set -u

fail() { echo "FAIL: $1"; exit 1; }

state="$(systemctl is-active reportd.service 2>/dev/null || true)"
[ "$state" = "active" ] || fail "reportd.service is not active (is-active=$state)"

enabled="$(systemctl is-enabled reportd.service 2>/dev/null || true)"
[ "$enabled" = "enabled" ] || fail "reportd.service is not enabled for boot (is-enabled=$enabled)"

# ExecStart must resolve to a real, executable file.
exec_path="$(systemctl show -p ExecStart --value reportd.service 2>/dev/null | grep -oE '/[^ ;]*reportd' | head -1)"
[ -n "$exec_path" ] || fail "could not read ExecStart from reportd.service"
[ -x "$exec_path" ] || fail "ExecStart path '$exec_path' is not an executable file"

# Functional proof: the heartbeat file must be growing.
log=/var/lib/reportd/heartbeat.log
[ -f "$log" ] || fail "heartbeat log $log does not exist - the daemon is not really running"
before="$(wc -l < "$log")"
sleep 5
after="$(wc -l < "$log")"
[ "$after" -gt "$before" ] || fail "heartbeat log is not growing ($before -> $after) - reportd is not actually running its work loop"

echo "PASS: reportd.service is active, enabled, and writing heartbeats (ExecStart -> $exec_path)"
exit 0
