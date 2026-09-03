#!/usr/bin/env bash
# Confirms ops-monitor's per-user crontab has an every-minute job that,
# either directly or via a referenced script, restarts billing_v2.

set -u

if ! id ops-monitor >/dev/null 2>&1; then
  echo "FAIL: cron schedule - ops-monitor user does not exist"
  exit 1
fi

crontab_out="$(sudo crontab -u ops-monitor -l 2>/dev/null)"

if [[ -z "$crontab_out" ]]; then
  echo "FAIL: cron schedule - ops-monitor has no crontab installed"
  exit 1
fi

lines="$(echo "$crontab_out" | grep -Ev '^[[:space:]]*(#|$)')"

found=0

while IFS= read -r line; do
  [[ -z "$line" ]] && continue

  min=$(awk '{print $1}' <<<"$line")
  hr=$(awk '{print $2}' <<<"$line")
  dom=$(awk '{print $3}' <<<"$line")
  mon=$(awk '{print $4}' <<<"$line")
  dow=$(awk '{print $5}' <<<"$line")
  cmd=$(cut -d' ' -f6- <<<"$line")

  if [[ "$min" != "*" || "$hr" != "*" || "$dom" != "*" || "$mon" != "*" || "$dow" != "*" ]]; then
    continue
  fi

  # If the command references a script path, pull that file's contents in
  # too, so an inline docker command OR a wrapper script both pass.
  combined="$cmd"
  for token in $cmd; do
    if [[ "$token" == /* && -f "$token" ]]; then
      combined="$combined $(cat "$token" 2>/dev/null)"
    fi
  done

  if echo "$combined" | grep -q 'docker' && \
     echo "$combined" | grep -q 'billing_v2' && \
     echo "$combined" | grep -Eq 'start|restart'; then
    found=1
    break
  fi
done <<<"$lines"

if [[ "$found" -ne 1 ]]; then
  echo "FAIL: cron schedule - no '* * * * *' job found in ops-monitor's crontab that restarts billing_v2"
  exit 1
fi

echo "PASS: ops-monitor's crontab has an every-minute job that restarts billing_v2"
exit 0
