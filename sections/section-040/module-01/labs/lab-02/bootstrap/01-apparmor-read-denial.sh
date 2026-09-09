#!/usr/bin/env bash
# Bootstrap: an AppArmor *read* denial (contrast with lab-01's write
# denial). The credsync daemon reads its API key on every cycle. The key
# was relocated from /var/lib/credsync/api.key to /etc/credsync/api.key,
# but the enforce-mode profile only permits the OLD path -- so every open
# of the new key is denied with:
#     apparmor="DENIED" operation="open" ... name="/etc/credsync/api.key"
#     requested_mask="r" denied_mask="r"
#
# DAC on /etc/credsync/api.key is already correct for the credsync user.
# The fix is a profile rule permitting READ of the new path, reloaded with
# apparmor_parser -r, profile left in enforce.
set -eu

if ! id -u credsync >/dev/null 2>&1; then
  sudo useradd --system --no-create-home --shell /usr/sbin/nologin credsync
fi

# Old location (still permitted by the profile) - now unused.
sudo mkdir -p /var/lib/credsync
sudo chown credsync:credsync /var/lib/credsync
sudo chmod 750 /var/lib/credsync

# New location - DAC correct, AppArmor blocks it.
sudo mkdir -p /etc/credsync
printf 'APIKEY=%s\n' "$(head -c 24 /dev/urandom | base64)" | sudo tee /etc/credsync/api.key >/dev/null
sudo chown -R root:credsync /etc/credsync
sudo chmod 750 /etc/credsync
sudo chmod 640 /etc/credsync/api.key

# The daemon: every 5s, try to read the key; on success write a ready
# marker, on failure log and keep running so a fresh denial is always
# available.
sudo tee /usr/sbin/credsync > /dev/null <<'SCRIPT'
#!/bin/bash
KEY=/etc/credsync/api.key
MARK=/run/credsync/ready
mkdir -p /run/credsync 2>/dev/null || true
while true; do
  if head -c1 "$KEY" >/dev/null 2>&1; then
    printf 'ok %s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)" > "$MARK"
  else
    rm -f "$MARK" 2>/dev/null || true
    echo "credsync: cannot read $KEY" >&2
  fi
  sleep 5
done
SCRIPT
sudo chmod 755 /usr/sbin/credsync

sudo mkdir -p /etc/apparmor.d/local
sudo tee /etc/apparmor.d/local/usr.sbin.credsync > /dev/null <<'LOCAL'
# Site-specific additions for usr.sbin.credsync go here.
LOCAL

# Enforce-mode profile that only knows the OLD key path.
sudo tee /etc/apparmor.d/usr.sbin.credsync > /dev/null <<'PROFILE'
#include <tunables/global>

/usr/sbin/credsync {
  #include <abstractions/base>
  #include <abstractions/bash>

  /usr/sbin/credsync r,
  /bin/bash ix,
  /usr/bin/head rix,
  /usr/bin/date rix,
  /usr/bin/sleep rix,
  /bin/mkdir rix,
  /bin/rm rix,

  /run/credsync/ rw,
  /run/credsync/** rw,

  # old key location only - no rule for /etc/credsync/
  /var/lib/credsync/ r,
  /var/lib/credsync/** r,

  #include if exists <local/usr.sbin.credsync>
}
PROFILE

sudo apparmor_parser -r /etc/apparmor.d/usr.sbin.credsync

sudo tee /etc/systemd/system/credsync.service > /dev/null <<'UNIT'
[Unit]
Description=Credential sync daemon
After=network.target

[Service]
Type=simple
User=credsync
Group=credsync
ExecStart=/usr/sbin/credsync
Restart=on-failure
RestartSec=2

[Install]
WantedBy=multi-user.target
UNIT

sudo systemctl daemon-reload
sudo systemctl enable --now credsync
sleep 6
