#!/usr/bin/env bash
# Confirms logtail-utils is cleanly installed (status: install ok
# installed) and that /usr/bin/logtail actually landed on disk and is
# executable.

set -u

status=$(dpkg-query -W -f='${Status}' logtail-utils 2>/dev/null || echo "")

if [[ "$status" != "install ok installed" ]]; then
  echo "FAIL: logtail-utils installed - status is '$status', expected 'install ok installed'"
  exit 1
fi

if [[ ! -x /usr/bin/logtail ]]; then
  echo "FAIL: logtail-utils installed - /usr/bin/logtail is missing or not executable"
  exit 1
fi

echo "PASS: logtail-utils is cleanly installed and /usr/bin/logtail is present and executable"
exit 0
