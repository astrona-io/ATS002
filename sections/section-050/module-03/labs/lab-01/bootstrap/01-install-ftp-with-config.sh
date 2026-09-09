#!/usr/bin/env bash
# Bootstrap: ftp ships pre-installed in the base image; this registers a
# real configuration file under /etc as one of its tracked dpkg conffiles.
#
# The stock "ftp" client package ships no /etc configuration of its own,
# so to make "purge vs. remove, verified by /etc leftovers" a reliable,
# gradeable scenario, this script adds a genuine conffile entry to ftp's
# own dpkg status stanza -- the same mechanism a real package with
# shipped /etc config would use. Once registered this way, `apt remove
# ftp` genuinely leaves /etc/ftp.conf behind, and `apt purge ftp`
# genuinely deletes it -- real dpkg conffile-purge behavior, not a
# scripted imitation of it.

set -eu

sudo tee /etc/ftp.conf >/dev/null <<'EOF'
# Legacy default FTP client site configuration.
# Installed by the ftp package for this host.
DefaultUser=anonymous
PassiveMode=yes
EOF

sudo python3 - <<'PYEOF'
import hashlib
import re

conf_path = "/etc/ftp.conf"
status_path = "/var/lib/dpkg/status"

with open(conf_path, "rb") as f:
    digest = hashlib.md5(f.read()).hexdigest()

with open(status_path, "r") as f:
    content = f.read()

stanzas = content.split("\n\n")
found = False
out = []
for stanza in stanzas:
    if re.search(r'^Package: ftp$', stanza, re.M):
        if "Conffiles:" not in stanza:
            stanza = stanza.rstrip("\n") + f"\nConffiles:\n {conf_path} {digest}\n"
        found = True
    out.append(stanza)

if not found:
    raise SystemExit("bootstrap error: could not locate the ftp stanza in /var/lib/dpkg/status")

with open(status_path, "w") as f:
    f.write("\n\n".join(out))
PYEOF

echo "ftp installed with a tracked conffile at /etc/ftp.conf"
