#!/usr/bin/env bash
set -u

if ! grep -rq "/etc/metrics-agent/remote.conf" /etc/apparmor.d/usr.sbin.metrics-agent /etc/apparmor.d/local/usr.sbin.metrics-agent 2>/dev/null; then
  echo "FAIL: no rule for /etc/metrics-agent/remote.conf found in the metrics-agent AppArmor profile"
  exit 1
fi

BEFORE_SIZE=$(sudo stat -c %s /var/lib/metrics-agent/status 2>/dev/null || echo 0)
sleep 8
AFTER_SIZE=$(sudo stat -c %s /var/lib/metrics-agent/status 2>/dev/null || echo 0)

if [ "$AFTER_SIZE" -le "$BEFORE_SIZE" ]; then
  echo "FAIL: /var/lib/metrics-agent/status is not growing -- metrics-agent is not successfully reading the new config"
  exit 1
fi

if ! sudo grep -q "remote-9f31ab" /var/lib/metrics-agent/status 2>/dev/null; then
  echo "FAIL: /var/lib/metrics-agent/status does not contain the token from remote.conf -- the read did not actually succeed"
  exit 1
fi

if sudo journalctl -k --since "15 seconds ago" 2>/dev/null | grep -q 'apparmor="DENIED".*remote.conf'; then
  echo "FAIL: a fresh AppArmor DENIED entry for remote.conf was logged during verification"
  exit 1
fi

echo "PASS: metrics-agent is actively and successfully reading /etc/metrics-agent/remote.conf"
exit 0
