#!/usr/bin/env bash
# Bootstrap: creates /opt/course/audit for the audit task, and lowers
# vm.swappiness to a deliberately non-default live value (10) so the
# "record the current live value" task has a real, non-default number
# worth auditing rather than a boring stock default.

set -eu

sudo mkdir -p /opt/course/audit
sudo chmod 755 /opt/course /opt/course/audit
sudo chown -R student:student /opt/course

sudo sysctl -w vm.swappiness=10 > /dev/null
