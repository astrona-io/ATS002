#!/usr/bin/env bash
set -euo pipefail
uname -r | sudo tee /opt/course/kernel
sysctl -n net.ipv4.ip_forward | sudo tee /opt/course/ip_forward
timedatectl show --property=Timezone --value | sudo tee /opt/course/timezone
