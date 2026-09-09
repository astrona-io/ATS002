# Solution Walkthrough

## 1. Confirm the profile is enforcing

```bash
sudo aa-status | grep -A2 'enforce mode' | grep credsync
#    /usr/sbin/credsync
```

Loaded, in enforce mode. AppArmor is in play.

## 2. Read the denial

```bash
sudo journalctl -k | grep 'apparmor="DENIED"' | grep credsync | tail -1
```

```text
apparmor="DENIED" operation="open" profile="/usr/sbin/credsync"
  name="/etc/credsync/api.key" requested_mask="r" denied_mask="r" ...
```

`requested_mask="r"` / `denied_mask="r"` — a **read** was refused on
`name="/etc/credsync/api.key"`. No label, no context — AppArmor decided
purely on that path string.

## 3. Find the gap in the profile

```bash
grep -n credsync /etc/apparmor.d/usr.sbin.credsync
```

```text
  /var/lib/credsync/ r,
  /var/lib/credsync/** r,
```

The profile only permits the **old** location. There is no rule for
`/etc/credsync/` at all.

## 4. Add a read rule to the local override

```bash
sudo tee -a /etc/apparmor.d/local/usr.sbin.credsync > /dev/null <<'EOF'
/etc/credsync/ r,
/etc/credsync/api.key r,
EOF
```

Only `r` — the daemon reads the key, it does not write it. (`aa-logprof`
after reproducing the read would propose the same rule and let you pick
exact-path vs a glob.)

## 5. Reload — pass the main profile path

```bash
sudo apparmor_parser -r /etc/apparmor.d/usr.sbin.credsync
```

The `local/` file is pulled in via the soft include at the bottom of the
main profile.

## 6. Verify — still enforcing, read succeeding

```bash
sudo aa-status | grep -A2 'enforce mode' | grep credsync   # still enforce
sleep 6
cat /run/credsync/ready                                     # "ok <recent timestamp>"
sudo journalctl -k --since '15 seconds ago' | grep credsync # no new DENIED
```

Same mechanism as a write denial — the only difference is the mask in the
audit line (`r` instead of `w`/`c`) and the rule you add (`r` instead of
`rw`).
