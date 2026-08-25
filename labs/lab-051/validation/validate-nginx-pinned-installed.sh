#!/usr/bin/env bash
# Confirms nginx is installed at exactly the vendor-published version
# recorded by bootstrap in /opt/lab-meta/nginx-vendor-version.

set -u

expected=$(cat /opt/lab-meta/nginx-vendor-version 2>/dev/null)

if [[ -z "$expected" ]]; then
  echo "FAIL: nginx pinned version installed - could not read expected version from bootstrap metadata"
  exit 1
fi

installed=$(dpkg-query -W -f='${Version}' nginx 2>/dev/null || echo "")

if [[ "$installed" != "$expected" ]]; then
  echo "FAIL: nginx pinned version installed - dpkg reports version '$installed', expected exactly '$expected'"
  exit 1
fi

status=$(dpkg-query -W -f='${Status}' nginx 2>/dev/null || echo "")
if [[ "$status" != "install ok installed" ]]; then
  echo "FAIL: nginx pinned version installed - package status is '$status', expected 'install ok installed'"
  exit 1
fi

echo "PASS: nginx is installed at the exact pinned vendor version $installed"
exit 0
