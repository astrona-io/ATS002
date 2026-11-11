#!/usr/bin/env bash
# Match the account used by astrona ssh, including its home and permissions.
sudo -H -u student bash <<'ASTRONA_STUDENT_SCRIPT'
# Confirms the container status-web is running from status-page:1.0 and
# mounts the named volume status-data at /data.

set -u

if ! sudo docker inspect status-web >/dev/null 2>&1; then
  echo "FAIL: container status-web does not exist"
  exit 1
fi

state="$(sudo docker inspect --format '{{ .State.Status }}' status-web)"
if [[ "$state" != "running" ]]; then
  echo "FAIL: status-web status is '$state', expected 'running'"
  exit 1
fi

image="$(sudo docker inspect --format '{{ .Config.Image }}' status-web)"
if [[ "$image" != "status-page:1.0" ]]; then
  echo "FAIL: status-web image is '$image', expected 'status-page:1.0'"
  exit 1
fi

mount="$(sudo docker inspect --format '{{ range .Mounts }}{{ .Type }}:{{ .Name }}:{{ .Destination }} {{ end }}' status-web)"
if ! grep -q 'volume:status-data:/data' <<<"$mount"; then
  echo "FAIL: status-web mounts '$mount', expected the named volume status-data at /data"
  exit 1
fi

echo "PASS: status-web is running from $image with volume status-data at /data"
exit 0
ASTRONA_STUDENT_SCRIPT
