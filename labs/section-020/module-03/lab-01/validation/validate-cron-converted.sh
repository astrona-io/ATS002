#!/usr/bin/env bash
# Confirms the dbclean cron job was converted to a systemd timer:
#   - no cron entry for dbclean.sh remains anywhere
#   - a timer exists, is enabled + active, activates a service that runs
#     dbclean.sh, on a 6-hourly schedule
set -u

fail() { echo "FAIL: $1"; exit 1; }

# 1. The cron job must be gone.
if grep -rqs 'dbclean' /etc/cron.d/ /etc/crontab /var/spool/cron/ 2>/dev/null; then
  echo "FAIL: a cron entry for dbclean still exists - it will now fire from both cron and the timer"
  grep -rns 'dbclean' /etc/cron.d/ /etc/crontab /var/spool/cron/ 2>/dev/null
  exit 1
fi

# 2. Find a timer whose activated service runs dbclean.sh.
found=""
while read -r t; do
  [ -n "$t" ] || continue
  svc="$(systemctl show "$t" -p Unit --value 2>/dev/null)"
  [ -n "$svc" ] || svc="${t%.timer}.service"
  es="$(systemctl show "$svc" -p ExecStart --value 2>/dev/null || true)"
  if echo "$es" | grep -q '/usr/local/sbin/dbclean.sh'; then found="$t"; FOUND_SVC="$svc"; break; fi
done < <(systemctl list-unit-files --type=timer --no-legend 2>/dev/null | awk '{print $1}')

[ -n "$found" ] || fail "no systemd timer activates a service that runs /usr/local/sbin/dbclean.sh"

[ "$(systemctl is-enabled "$found" 2>/dev/null)" = "enabled" ] || fail "$found is not enabled"
[ "$(systemctl is-active  "$found" 2>/dev/null)" = "active" ]  || fail "$found is not active"

# 3. Schedule: every 6 hours. Accept OnCalendar with a 0/6 (or 6-step) hour
#    field, or OnUnitActiveSec/OnBootSec of 6h / 21600s.
cal="$(systemctl show "$found" -p TimersCalendar --value 2>/dev/null)"
mono="$(systemctl show "$found" -p TimersMonotonic --value 2>/dev/null)"
if echo "$cal" | grep -qE '0/6:00:00|00/6:00:00|\*-\*-\* (00|0)/6'; then :
elif echo "$cal" | grep -qE '(00:00:00).*(06:00:00).*(12:00:00).*(18:00:00)'; then :
elif echo "$mono" | grep -qE '21600000000|6h|6 h'; then :
else
  fail "$found schedule does not look 6-hourly (OnCalendar='$cal' Monotonic='$mono')"
fi

echo "PASS: dbclean cron job removed and replaced by $found -> $FOUND_SVC, enabled+active, ~6-hourly"
exit 0
