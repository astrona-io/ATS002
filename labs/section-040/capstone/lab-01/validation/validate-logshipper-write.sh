#!/usr/bin/env bash
set -u

if ! grep -rq "/srv/shiplogs" /etc/apparmor.d/usr.sbin.logshipper /etc/apparmor.d/local/usr.sbin.logshipper 2>/dev/null; then
  echo "FAIL: no rule for /srv/shiplogs found in the logshipper AppArmor profile"
  exit 1
fi

BEFORE_SIZE=$(sudo stat -c %s /srv/shiplogs/ship.log 2>/dev/null || echo 0)
sleep 8
AFTER_SIZE=$(sudo stat -c %s /srv/shiplogs/ship.log 2>/dev/null || echo 0)

if [ "$AFTER_SIZE" -le "$BEFORE_SIZE" ]; then
  echo "FAIL: /srv/shiplogs/ship.log is not growing -- logshipper is not successfully writing to it"
  exit 1
fi

if sudo journalctl -k --since "15 seconds ago" 2>/dev/null | grep -q 'apparmor="DENIED".*shiplogs'; then
  echo "FAIL: a fresh AppArmor DENIED entry for /srv/shiplogs was logged during verification"
  exit 1
fi

echo "PASS: logshipper is actively and successfully writing to /srv/shiplogs"
exit 0
