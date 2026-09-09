#!/usr/bin/env bash
# Confirms the ingest chain is genuinely repaired:
#   - ingest-db.service   : active + enabled
#   - ingest.service      : active + enabled, NOT in auto-restart/start-limit
#   - ingest is doing real work (ingest.log grows)
set -u

fail() { echo "FAIL: $1"; exit 1; }

for u in ingest-db.service ingest.service; do
  st="$(systemctl is-active "$u" 2>/dev/null || true)"
  [ "$st" = "active" ] || fail "$u is not active (is-active=$st)"
  en="$(systemctl is-enabled "$u" 2>/dev/null || true)"
  [ "$en" = "enabled" ] || fail "$u is not enabled for boot (is-enabled=$en)"
done

# ingest must be genuinely running, not flapping.
sub="$(systemctl show -p SubState --value ingest.service 2>/dev/null || true)"
[ "$sub" = "running" ] || fail "ingest.service SubState is '$sub', expected 'running' (still auto-restarting?)"

result="$(systemctl show -p Result --value ingest.service 2>/dev/null || true)"
[ "$result" = "success" ] || fail "ingest.service Result is '$result' (start-limit-hit not cleared?)"

# ExecStart of ingest-db must point at a real executable.
dbexec="$(systemctl show -p ExecStart --value ingest-db.service 2>/dev/null | grep -oE '/[^ ;]*ingest[a-z-]*' | head -1)"
[ -n "$dbexec" ] && [ -x "$dbexec" ] || fail "ingest-db ExecStart '$dbexec' is not an executable file"

# Functional proof.
log=/var/lib/ingest/ingest.log
[ -f "$log" ] || fail "$log missing - ingest is not doing work"
b="$(wc -l < "$log")"; sleep 5; a="$(wc -l < "$log")"
[ "$a" -gt "$b" ] || fail "$log not growing ($b -> $a) - ingest not really running"

echo "PASS: ingest-db and ingest are both active and enabled; ingest is running (Result=success) and writing $log"
exit 0
