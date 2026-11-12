#!/usr/bin/env bash
# Match the account used by astrona ssh, including its home and permissions.
sudo -H -u student bash <<'ASTRONA_STUDENT_SCRIPT'
# Inspect protected state; user access checks select their target account explicitly.
sudo -n bash <<'GRADER_ROOT'
set -u

if ! sudo docker ps --format '{{.Names}}' | grep -qx zypperbox; then
  echo "FAIL: zypperbox container is not running"
  exit 1
fi

answer=$(sudo docker exec zypperbox cat /root/answers/04-installed-python3.txt 2>/dev/null)

if [ -z "$answer" ]; then
  echo "FAIL: /root/answers/04-installed-python3.txt is empty or missing"
  exit 1
fi

# Both seeded packages should appear, each marked installed ('i') in
# zypper's leading status column. Allow for zypper's normal column padding
# rather than requiring an exact fixed-width match.
if ! echo "$answer" | grep -E '^i[+]?[[:space:]]*\|[[:space:]]*python3-base'; then
  echo "FAIL: /root/answers/04-installed-python3.txt does not list python3-base as installed"
  exit 1
fi

if ! echo "$answer" | grep -E '^i[+]?[[:space:]]*\|[[:space:]]*python313-pip'; then
  echo "FAIL: /root/answers/04-installed-python3.txt does not list python313-pip as installed"
  exit 1
fi

# Every row naming a python3* package must be marked installed ('i') -- a
# stray non-'i' row would indicate the student ran an unfiltered search
# instead of using --installed-only.
if echo "$answer" | grep -E 'python3[0-9]*-' | grep -qv '^i'; then
  echo "FAIL: /root/answers/04-installed-python3.txt contains a python3* row not marked installed -- looks like an unfiltered search"
  exit 1
fi

echo "PASS: /root/answers/04-installed-python3.txt lists python3-base and python313-pip via a filtered installed-only search"
exit 0
GRADER_ROOT
ASTRONA_STUDENT_SCRIPT
