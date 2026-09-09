#!/usr/bin/env bash
# Confirms collector2 (the only process that calls the forbidden kill()
# syscall) has been terminated and its executable removed from disk.

set -u

if pgrep -f /usr/local/bin/collector2 >/dev/null 2>&1; then
  echo "FAIL: guilty process removed - collector2 is still running"
  exit 1
fi

if [[ -e /usr/local/bin/collector2 ]]; then
  echo "FAIL: guilty process removed - /usr/local/bin/collector2 still exists on disk"
  exit 1
fi

echo "PASS: collector2 is terminated and its executable has been removed"
exit 0
