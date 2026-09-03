#!/usr/bin/env bash
# Bootstrap: installs the real "cowsay" package cleanly, then manually
# edits its stanza in /var/lib/dpkg/status to flip its Status line from
# "install ok installed" to "install ok half-configured" -- reproducing,
# deterministically, exactly the on-disk state a real interrupted
# `dpkg -i`/postinst would leave behind (dpkg -l shows this as the "iF"
# status code). cowsay is chosen because it is small, has no running
# service, and its postinst (if any) is safe to re-run idempotently when
# the student later executes `dpkg --configure -a`.
#
# This is an unrelated package to logtail-utils -- it simulates "a
# colleague's dpkg -i of an unrelated package was interrupted midway,"
# independent of anything the student does with logtail-utils.

set -eu

sudo DEBIAN_FRONTEND=noninteractive apt-get install -y cowsay

sudo python3 - <<'PYEOF'
import re

path = "/var/lib/dpkg/status"
with open(path, "r") as f:
    content = f.read()

stanzas = content.split("\n\n")
found = False
out = []
for stanza in stanzas:
    if re.search(r'^Package: cowsay$', stanza, re.M):
        new_stanza, n = re.subn(
            r'^Status: install ok installed$',
            'Status: install ok half-configured',
            stanza,
            flags=re.M,
        )
        if n == 1:
            found = True
            stanza = new_stanza
    out.append(stanza)

if not found:
    raise SystemExit("bootstrap error: could not locate/modify the cowsay stanza in /var/lib/dpkg/status")

with open(path, "w") as f:
    f.write("\n\n".join(out))
PYEOF

echo "cowsay is now left in a half-configured (iF) state:"
dpkg -l | grep cowsay || true
