#!/usr/bin/env bash
# Confirms frontend_v3 is running, detached, image nginx:alpine, memory
# limit 30m (31457280 bytes), and port map 1234(host) -> 80(container).

set -u

if ! sudo docker inspect frontend_v3 >/dev/null 2>&1; then
  echo "FAIL: frontend_v3 - container does not exist"
  exit 1
fi

status="$(sudo docker inspect --format '{{ .State.Status }}' frontend_v3)"
if [[ "$status" != "running" ]]; then
  echo "FAIL: frontend_v3 - status is '$status', expected 'running'"
  exit 1
fi

image="$(sudo docker inspect --format '{{ .Config.Image }}' frontend_v3)"
if [[ "$image" != "nginx:alpine" ]]; then
  echo "FAIL: frontend_v3 - image is '$image', expected 'nginx:alpine'"
  exit 1
fi

expected_mem=$((30 * 1024 * 1024))
mem="$(sudo docker inspect --format '{{ .HostConfig.Memory }}' frontend_v3)"
if [[ "$mem" != "$expected_mem" ]]; then
  echo "FAIL: frontend_v3 - memory limit is '$mem' bytes, expected '$expected_mem' bytes (30m)"
  exit 1
fi

port_map="$(sudo docker inspect --format '{{ range $p, $conf := .HostConfig.PortBindings }}{{ $p }}=>{{ (index $conf 0).HostPort }} {{ end }}' frontend_v3)"
if ! echo "$port_map" | grep -qE '80/tcp=>1234'; then
  echo "FAIL: frontend_v3 - port mapping is '$port_map', expected host 1234 -> container 80/tcp"
  exit 1
fi

echo "PASS: frontend_v3 is running, image=$image, memory=$mem bytes, ports=$port_map"
exit 0
