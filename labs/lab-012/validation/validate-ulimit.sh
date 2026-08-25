#!/usr/bin/env bash
# Confirms the dataproc user's max-processes ceiling (ulimit -u / RLIMIT_NPROC)
# is raised to at least 32768 for a fresh session, persisted via a drop-in
# under /etc/security/limits.d/ that overrides the low bootstrap baseline.

set -u

threshold=32768

if ! id dataproc >/dev/null 2>&1; then
  echo "FAIL: ulimit raised - dataproc user does not exist"
  exit 1
fi

actual=$(sudo -iu dataproc bash -c 'ulimit -u' 2>/dev/null)

if [[ -z "$actual" ]]; then
  echo "FAIL: ulimit raised - could not read ulimit -u for dataproc"
  exit 1
fi

if [[ "$actual" != "unlimited" ]]; then
  if [[ "$actual" -lt "$threshold" ]]; then
    echo "FAIL: ulimit raised - dataproc's fresh-session ulimit -u is '$actual', expected >= $threshold"
    exit 1
  fi
fi

if ! grep -rqE '^\s*dataproc\s+(soft|hard)\s+nproc\s+([3-9][0-9]{4,}|[0-9]{6,}|unlimited)\b' /etc/security/limits.d/ 2>/dev/null; then
  echo "FAIL: ulimit raised - no /etc/security/limits.d/*.conf drop-in raises dataproc's nproc limit"
  exit 1
fi

echo "PASS: dataproc's ulimit -u is $actual, persisted via /etc/security/limits.d/"
exit 0
