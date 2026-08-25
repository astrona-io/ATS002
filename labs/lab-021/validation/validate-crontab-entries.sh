#!/usr/bin/env bash
# Confirms asset-manager's per-user crontab contains both required jobs:
# the converted 8:30pm daily job (no leftover username field) and the new
# Mon/Thu 11:15am clean.sh job (with the required "bash" prefix).

set -u

if ! id asset-manager >/dev/null 2>&1; then
  echo "FAIL: crontab entries - asset-manager user does not exist"
  exit 1
fi

crontab_out="$(sudo crontab -u asset-manager -l 2>/dev/null)"

if [[ -z "$crontab_out" ]]; then
  echo "FAIL: crontab entries - asset-manager has no crontab installed"
  exit 1
fi

# Strip comments and blank lines.
lines="$(echo "$crontab_out" | grep -Ev '^[[:space:]]*(#|$)')"

job1_ok=0
job2_ok=0

while IFS= read -r line; do
  [[ -z "$line" ]] && continue

  min=$(awk '{print $1}' <<<"$line")
  hr=$(awk '{print $2}' <<<"$line")
  dom=$(awk '{print $3}' <<<"$line")
  mon=$(awk '{print $4}' <<<"$line")
  dow=$(awk '{print $5}' <<<"$line" | tr '[:lower:]' '[:upper:]')
  cmd=$(cut -d' ' -f6- <<<"$line")

  # --- Job 1: converted daily 8:30pm nightly-sync.sh job ---
  if [[ "$min" == "30" && "$hr" == "20" && "$dom" == "*" && "$mon" == "*" && "$dow" == "*" ]]; then
    if echo "$cmd" | grep -qE '^asset-manager[[:space:]]'; then
      # Leftover username field pasted straight from the system-wide line -
      # cron would try to execute a program literally named "asset-manager".
      :
    elif echo "$cmd" | grep -qE '/home/asset-manager/nightly-sync\.sh([[:space:]]|$)'; then
      job1_ok=1
    fi
  fi

  # --- Job 2: new Mon/Thu 11:15am clean.sh job ---
  if [[ "$min" == "15" && "$hr" == "11" && "$dom" == "*" && "$mon" == "*" ]]; then
    case "$dow" in
      MON,THU|THU,MON|1,4|4,1)
        if echo "$cmd" | grep -qE '(^|[[:space:]])bash[[:space:]]+/home/asset-manager/clean\.sh([[:space:]]|$)'; then
          job2_ok=1
        fi
        ;;
    esac
  fi
done <<<"$lines"

if [[ "$job1_ok" -ne 1 ]]; then
  echo "FAIL: crontab entries - no valid '30 20 * * * /home/asset-manager/nightly-sync.sh' entry (without a username field) found for asset-manager"
  exit 1
fi

if [[ "$job2_ok" -ne 1 ]]; then
  echo "FAIL: crontab entries - no valid '15 11 * * MON,THU bash /home/asset-manager/clean.sh' entry found for asset-manager"
  exit 1
fi

echo "PASS: asset-manager's crontab contains both the converted nightly-sync.sh job and the new Mon/Thu clean.sh job"
exit 0
