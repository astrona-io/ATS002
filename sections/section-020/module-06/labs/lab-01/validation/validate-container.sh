#!/usr/bin/env bash
# Match the account used by astrona ssh, including its home and permissions.
sudo -H -u student bash <<'ASTRONA_STUDENT_SCRIPT'
# Inspect protected state; user access checks select their target account explicitly.
sudo -n bash <<'GRADER_ROOT'
# Confirms the user pilot runs a rootless container named relay from
# docker.io/library/nginx:alpine with host port 8090 published.

set -u
cd /tmp

pilot_uid="$(id -u pilot 2>/dev/null || true)"
if [[ -z "$pilot_uid" ]]; then
  echo "FAIL: user pilot does not exist"
  exit 1
fi

run_as_pilot() {
  if [[ -d "/run/user/$pilot_uid" ]]; then
    sudo -u pilot env XDG_RUNTIME_DIR="/run/user/$pilot_uid" HOME=/home/pilot "$@"
  else
    sudo -u pilot env HOME=/home/pilot "$@"
  fi
}

if ! run_as_pilot podman container exists relay; then
  echo "FAIL: pilot has no container named relay"
  exit 1
fi

state="$(run_as_pilot podman inspect --format '{{ .State.Status }}' relay)"
if [[ "$state" != "running" ]]; then
  echo "FAIL: relay status is '$state', expected 'running'"
  exit 1
fi

image="$(run_as_pilot podman inspect --format '{{ .ImageName }}' relay)"
if [[ "$image" != *"nginx:alpine" ]]; then
  echo "FAIL: relay image is '$image', expected docker.io/library/nginx:alpine"
  exit 1
fi

ports="$(run_as_pilot podman inspect --format '{{ range $port, $bindings := .NetworkSettings.Ports }}{{ range $bindings }}{{ .HostPort }} {{ end }}{{ end }}' relay)"
if ! grep -qw 8090 <<<"$ports"; then
  echo "FAIL: relay publishes host ports '$ports', expected 8090"
  exit 1
fi

echo "PASS: pilot runs relay from $image with host port 8090"
exit 0
GRADER_ROOT
ASTRONA_STUDENT_SCRIPT
