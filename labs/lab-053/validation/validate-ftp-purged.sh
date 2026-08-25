#!/usr/bin/env bash
# Confirms ftp was fully purged, not just removed: the package itself is
# gone from dpkg's database AND its /etc/ftp.conf conffile is gone too.

set -u

if dpkg-query -W -f='${Status}' ftp >/dev/null 2>&1; then
  status=$(dpkg-query -W -f='${Status}' ftp 2>/dev/null)
  echo "FAIL: ftp purged - dpkg still has a record for ftp (status: '$status'); expected no record at all after a purge"
  exit 1
fi

if [[ -e /etc/ftp.conf ]]; then
  echo "FAIL: ftp purged - /etc/ftp.conf still exists; 'apt remove' alone leaves conffiles behind, 'apt purge' is required"
  exit 1
fi

echo "PASS: ftp is fully purged and /etc/ftp.conf is gone"
exit 0
