#!/usr/bin/env bash
set -euo pipefail
sudo pkill -KILL -f /opt/crew/stubborn.sh
pid=$(pgrep -f '[c]puburn.sh' | head -1)
sudo renice -n 15 -p "$pid"
pgrep -f '[c]rew-sleeper.sh' | head -1 | sudo tee /opt/course/7/sleeper-pid
