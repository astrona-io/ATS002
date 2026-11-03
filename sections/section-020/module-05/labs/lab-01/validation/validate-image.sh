#!/usr/bin/env bash
# Confirms the image status-page:1.0 exists and holds the page from
# /opt/course/25/build/index.html at /usr/share/nginx/html/index.html.

set -u

if ! sudo docker image inspect status-page:1.0 >/dev/null 2>&1; then
  echo "FAIL: image status-page:1.0 does not exist"
  exit 1
fi

inside="$(sudo docker run --rm --entrypoint cat status-page:1.0 /usr/share/nginx/html/index.html 2>/dev/null)"
expected="$(cat /opt/course/25/build/index.html)"

if [[ "$inside" != "$expected" ]]; then
  echo "FAIL: /usr/share/nginx/html/index.html in the image does not match /opt/course/25/build/index.html"
  exit 1
fi

echo "PASS: image status-page:1.0 exists and holds the page"
exit 0
