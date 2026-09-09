#!/usr/bin/env bash
# Confirms webreport.service is genuinely serving on TCP 8080:
#   - active + enabled
#   - a webreport process is the listener on :8080
#   - an HTTP GET on :8080 returns the webreport content
#   - portsquatter is no longer holding the port
set -u

fail() { echo "FAIL: $1"; exit 1; }

state="$(systemctl is-active webreport.service 2>/dev/null || true)"
[ "$state" = "active" ] || fail "webreport.service is not active (is-active=$state)"

enabled="$(systemctl is-enabled webreport.service 2>/dev/null || true)"
[ "$enabled" = "enabled" ] || fail "webreport.service is not enabled (is-enabled=$enabled)"

# Who is listening on 8080?
listener="$(ss -H -ltnp 'sport = :8080' 2>/dev/null)"
[ -n "$listener" ] || fail "nothing is listening on TCP 8080"
echo "$listener" | grep -q 'webreport\|/usr/local/sbin/webreport' \
  || echo "$listener" | grep -q "pid=$(systemctl show -p MainPID --value webreport.service)" \
  || fail "the listener on :8080 is not webreport: $listener"

# portsquatter must not still be up.
sq="$(systemctl is-active portsquatter.service 2>/dev/null || true)"
[ "$sq" != "active" ] || fail "portsquatter.service is still active and holding the port"

# Functional HTTP check.
body="$(curl -fsS --max-time 5 http://127.0.0.1:8080/ 2>/dev/null || true)"
echo "$body" | grep -q 'report service OK' || fail "HTTP GET on :8080 did not return the webreport content (got: $body)"

echo "PASS: webreport.service is active, enabled, and serving on TCP 8080; portsquatter is stopped"
exit 0
