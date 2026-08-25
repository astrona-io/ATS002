#!/usr/bin/env bash
# Confirms dpkg's package database correctly resolves ownership of
# /usr/bin/logtail in both directions -- the reverse lookup (file to
# package) and the forward lookup (package to files) -- which only
# succeed once logtail-utils is genuinely, cleanly installed via dpkg.

set -u

search_result=$(dpkg -S /usr/bin/logtail 2>/dev/null || echo "")

if [[ "$search_result" != "logtail-utils: /usr/bin/logtail" ]]; then
  echo "FAIL: ownership lookups - 'dpkg -S /usr/bin/logtail' returned '$search_result', expected 'logtail-utils: /usr/bin/logtail'"
  exit 1
fi

if ! dpkg -L logtail-utils 2>/dev/null | grep -qx /usr/bin/logtail; then
  echo "FAIL: ownership lookups - 'dpkg -L logtail-utils' did not list /usr/bin/logtail"
  exit 1
fi

echo "PASS: dpkg -S and dpkg -L both correctly resolve logtail-utils <-> /usr/bin/logtail"
exit 0
