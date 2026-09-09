#!/usr/bin/env bash
set -u

PROFILE="/usr/sbin/appservice"

AA_STATUS=$(sudo aa-status 2>/dev/null)
if [ -z "$AA_STATUS" ]; then
  echo "FAIL: unable to read aa-status output -- is AppArmor running?"
  exit 1
fi

# The profile must be loaded and specifically in enforce mode.
ENFORCE_BLOCK=$(printf '%s\n' "$AA_STATUS" | sed -n '/profiles are in enforce mode\./,/profiles are in complain mode\.\|processes have profiles defined\./p')
if ! printf '%s\n' "$ENFORCE_BLOCK" | grep -q "$PROFILE"; then
  echo "FAIL: $PROFILE is not loaded in enforce mode"
  exit 1
fi

# It must NOT have been left in complain mode as a shortcut.
COMPLAIN_BLOCK=$(printf '%s\n' "$AA_STATUS" | sed -n '/profiles are in complain mode\./,/processes have profiles defined\./p')
if printf '%s\n' "$COMPLAIN_BLOCK" | grep -q "$PROFILE"; then
  echo "FAIL: $PROFILE was left in complain mode instead of enforce"
  exit 1
fi

# The service itself must be running.
if ! systemctl is-active --quiet appservice; then
  echo "FAIL: appservice.service is not active"
  exit 1
fi

# The profile (main file or its local override) must now grant access to
# /srv/applogs.
if ! grep -rq "/srv/applogs" /etc/apparmor.d/usr.sbin.appservice /etc/apparmor.d/local/usr.sbin.appservice 2>/dev/null; then
  echo "FAIL: no rule for /srv/applogs found in the appservice AppArmor profile"
  exit 1
fi

# Prove it live: the log file must still be growing, with zero fresh
# DENIED entries against it during the check window.
BEFORE_SIZE=$(sudo stat -c %s /srv/applogs/app.log 2>/dev/null || echo 0)
sleep 8
AFTER_SIZE=$(sudo stat -c %s /srv/applogs/app.log 2>/dev/null || echo 0)

if [ "$AFTER_SIZE" -le "$BEFORE_SIZE" ]; then
  echo "FAIL: /srv/applogs/app.log is not growing -- appservice is not successfully writing to it"
  exit 1
fi

if sudo journalctl -k --since "15 seconds ago" 2>/dev/null | grep -q 'apparmor="DENIED".*applogs'; then
  echo "FAIL: a fresh AppArmor DENIED entry for /srv/applogs was logged during verification"
  exit 1
fi

echo "PASS: appservice's AppArmor profile is enforcing and correctly permits writes to /srv/applogs"
exit 0
