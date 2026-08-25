#!/usr/bin/env bash
# Confirms billing_v2 is running, detached, image nginx:alpine, memory
# limit 64m (67108864 bytes), and port map 9090(host) -> 80(container).

set -u

if ! sudo docker inspect billing_v2 >/dev/null 2>&1; then
  echo "FAIL: billing_v2 config - container does not exist"
  exit 1
fi

status="$(sudo docker inspect --format '{{ .State.Status }}' billing_v2)"
if [[ "$status" != "running" ]]; then
  echo "FAIL: billing_v2 config - status is '$status', expected 'running'"
  exit 1
fi

image="$(sudo docker inspect --format '{{ .Config.Image }}' billing_v2)"
if [[ "$image" != "nginx:alpine" ]]; then
  echo "FAIL: billing_v2 config - image is '$image', expected 'nginx:alpine'"
  exit 1
fi

expected_mem=$((64 * 1024 * 1024))
mem="$(sudo docker inspect --format '{{ .HostConfig.Memory }}' billing_v2)"
if [[ "$mem" != "$expected_mem" ]]; then
  echo "FAIL: billing_v2 config - memory limit is '$mem' bytes, expected '$expected_mem' bytes (64m)"
  exit 1
fi

port_map="$(sudo docker inspect --format '{{ range $p, $conf := .HostConfig.PortBindings }}{{ $p }}=>{{ (index $conf 0).HostPort }} {{ end }}' billing_v2)"
if ! echo "$port_map" | grep -qE '80/tcp=>9090'; then
  echo "FAIL: billing_v2 config - port mapping is '$port_map', expected host 9090 -> container 80/tcp"
  exit 1
fi

echo "PASS: billing_v2 is running, image=$image, memory=$mem bytes, ports=$port_map"
exit 0
