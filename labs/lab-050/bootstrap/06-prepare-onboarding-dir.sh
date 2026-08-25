#!/usr/bin/env bash
# Bootstrap: creates /opt/course/onboarding, owned by the student user,
# as the destination for the recorded research answer this lab asks for.
# Nothing about the answer itself is pre-computed here -- that is the
# student's task.

set -eu

sudo mkdir -p /opt/course/onboarding
sudo chmod 755 /opt/course /opt/course/onboarding
sudo chown -R student:student /opt/course
