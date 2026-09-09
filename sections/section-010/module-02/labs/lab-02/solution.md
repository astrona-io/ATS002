# Solution Walkthrough

## 1. Inspect all three ceilings

```bash
sysctl -n kernel.pid_max
# 4194304                       <- generous, not the problem

systemctl show data-ingest.service -p TasksMax --value
# infinity                      <- uncapped, not the problem

sudo -iu dataproc bash -c 'ulimit -u'
# 256                           <- THIS is the clamp
```

Two of the three are already well above what a thread-heavy job needs. The
`dataproc` user's per-UID process ceiling (`RLIMIT_NPROC`) is `256` — that
is what stops `fork()`.

## 2. Confirm where it comes from

```bash
grep -rn nproc /etc/security/limits.conf /etc/security/limits.d/
# /etc/security/limits.d/00-dataproc-baseline.conf:1:dataproc soft nproc 256
# /etc/security/limits.d/00-dataproc-baseline.conf:2:dataproc hard nproc 256
```

`pam_limits` reads these at login. The baseline file pins it at `256`.

## 3. Raise only `ulimit -u`, persistently

Add a drop-in that sorts **after** the baseline (later file wins in
`pam_limits`):

```bash
sudo tee /etc/security/limits.d/50-dataproc.conf > /dev/null <<'EOF'
dataproc soft nproc 32768
dataproc hard nproc 65536
EOF
```

## 4. Verify — and that you left the others alone

```bash
sudo -iu dataproc bash -c 'ulimit -u'    # 32768 (new login session picks up the drop-in)
sysctl -n kernel.pid_max                 # still 4194304 — untouched
systemctl show data-ingest.service -p TasksMax --value   # still infinity — untouched
```

`pam_limits` applies at login, so a session open from *before* your edit
keeps the old value — `sudo -iu` starts a fresh one. The service itself,
being a systemd unit, does not go through `pam_limits`; for it, the unit's
own `TasksMax=`/`LimitNPROC=` govern — and both are already fine here, so no
change was needed.
