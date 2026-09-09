#!/usr/bin/env bash
# Confirms the report.timer / report.service pair:
#   - both units exist
#   - report.timer is enabled (survives reboot) and active
#   - it activates report.service
#   - OnCalendar resolves to Mon,Thu 11:15 (any equivalent normalisation)
#   - Persistent=true is set
set -u

fail() { echo "FAIL: $1"; exit 1; }

systemctl cat report.service >/dev/null 2>&1 || fail "report.service does not exist"
systemctl cat report.timer   >/dev/null 2>&1 || fail "report.timer does not exist"

[ "$(systemctl is-enabled report.timer 2>/dev/null)" = "enabled" ] || fail "report.timer is not enabled (won't survive a reboot)"
[ "$(systemctl is-active  report.timer 2>/dev/null)" = "active" ]  || fail "report.timer is not active"

# The timer must activate report.service.
act="$(systemctl show report.timer -p Unit --value 2>/dev/null)"
[ -z "$act" ] || [ "$act" = "report.service" ] || fail "report.timer activates '$act', expected report.service"
systemctl list-timers --all 2>/dev/null | grep -q 'report.timer .*report.service' \
  || systemctl show report.timer -p Unit --value 2>/dev/null | grep -q 'report.service' \
  || fail "report.timer is not wired to report.service"

# OnCalendar must be Mon+Thu at 11:15.
cal="$(systemctl show report.timer -p TimersCalendar --value 2>/dev/null)"
echo "$cal" | grep -qiE 'Mon.*Thu|Thu.*Mon' || fail "report.timer OnCalendar '$cal' does not include Mon and Thu"
echo "$cal" | grep -q '11:15:00' || fail "report.timer OnCalendar '$cal' is not at 11:15"

# Persistent=true.
[ "$(systemctl show report.timer -p Persistent --value 2>/dev/null)" = "yes" ] \
  || fail "report.timer does not have Persistent=true"

# ExecStart of the service must run report.sh.
es="$(systemctl show report.service -p ExecStart --value 2>/dev/null)"
echo "$es" | grep -q '/usr/local/sbin/report.sh' || fail "report.service ExecStart does not run /usr/local/sbin/report.sh (got: $es)"

echo "PASS: report.timer is enabled+active, Persistent, OnCalendar='$cal', activating report.service"
exit 0
