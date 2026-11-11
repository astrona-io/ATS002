#!/usr/bin/env bash
# Match the account used by astrona ssh, including its home and permissions.
sudo -H -u student bash <<'ASTRONA_STUDENT_SCRIPT'
# Inspect protected state; user access checks select their target account explicitly.
sudo -n bash <<'GRADER_ROOT'
# Confirms ftp was fully purged, not just removed: the package itself is
# uninstalled without residual configuration, including /etc/ftp.conf.

set -u

status=$(dpkg-query -W -f='${db:Status-Status}' ftp 2>/dev/null || true)
if [[ -n "$status" && "$status" != "not-installed" ]]; then
  echo "FAIL: ftp purged - package state is '$status'; expected absent or not-installed"
  exit 1
fi

if [[ -e /etc/ftp.conf ]]; then
  echo "FAIL: ftp purged - /etc/ftp.conf still exists; 'apt remove' alone leaves conffiles behind, 'apt purge' is required"
  exit 1
fi

echo "PASS: ftp is fully purged and /etc/ftp.conf is gone"
exit 0
GRADER_ROOT
ASTRONA_STUDENT_SCRIPT
