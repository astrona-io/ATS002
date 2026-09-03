#!/usr/bin/env bash
# Bootstrap: creates /opt/course/apt-research, owned by the student user,
# as the destination for every recorded research output this lab asks
# for. Nothing about the research itself (search results, metadata,
# policy output, pattern-matched listings) is pre-computed here -- that
# is the student's task.

set -eu

sudo mkdir -p /opt/course/apt-research
sudo chmod 755 /opt/course /opt/course/apt-research
sudo chown -R student:student /opt/course
