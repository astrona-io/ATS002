#!/usr/bin/env bash
# Bootstrap: creates the dataproc user and forces a low nproc ceiling via a
# low-priority /etc/security/limits.d drop-in, so the "raise ulimit -u
# persistently" task has a real, low starting ceiling to override. A file
# the student adds that sorts after this one (e.g. 50-dataproc.conf) will
# win, since pam_limits applies the last matching directive across files.

set -eu

if ! id dataproc >/dev/null 2>&1; then
  sudo useradd -m -s /bin/bash dataproc
fi

sudo tee /etc/security/limits.d/00-dataproc-baseline.conf > /dev/null <<'EOF'
dataproc soft nproc 200
dataproc hard nproc 200
EOF
