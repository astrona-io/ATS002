#!/usr/bin/env bash
# Confirms the default boot target is now multi-user.target:
#   - systemctl get-default reports it
#   - /etc/systemd/system/default.target symlink resolves to it
set -u

fail() { echo "FAIL: $1"; exit 1; }

def="$(systemctl get-default 2>/dev/null)"
[ "$def" = "multi-user.target" ] || fail "systemctl get-default reports '$def', expected 'multi-user.target'"

link="$(readlink -f /etc/systemd/system/default.target 2>/dev/null)"
case "$link" in
  */multi-user.target) : ;;
  "") fail "/etc/systemd/system/default.target symlink is missing" ;;
  *) fail "/etc/systemd/system/default.target points at '$link', expected .../multi-user.target" ;;
esac

echo "PASS: default boot target is multi-user.target (get-default + default.target symlink both agree)"
exit 0
