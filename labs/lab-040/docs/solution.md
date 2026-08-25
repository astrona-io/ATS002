# Solution Guide: AppArmor — Two Services, Two Denials

Both services fail for the same underlying reason — an AppArmor profile that only knows about a path the service no longer uses — but the direction of the blocked access differs. Work through each independently.

---

## Part 1: logshipper (write denial)

### Step 1: Confirm the profile's mode

```bash
sudo aa-status
```

Confirm `/usr/sbin/logshipper` appears under **enforce mode**.

### Step 2: Find the denial

```bash
sudo journalctl -k | grep 'apparmor="DENIED"' | grep logshipper
```

```text
apparmor="DENIED" operation="open" profile="/usr/sbin/logshipper" name="/srv/shiplogs/ship.log" comm="logshipper" requested_mask="w" denied_mask="w"
```

### Step 3: Inspect and fix the profile

```bash
sudo cat /etc/apparmor.d/usr.sbin.logshipper
```

It only grants access under `/var/log/logshipper/`. Add the missing rule:

```bash
sudo tee -a /etc/apparmor.d/local/usr.sbin.logshipper > /dev/null << 'EOF'
/srv/shiplogs/*.log rw,
/srv/shiplogs/ r,
EOF
```

(Or trigger a fresh denial with `sudo systemctl restart logshipper` and run `sudo aa-logprof` instead.)

### Step 4: Reload and confirm enforcement

```bash
sudo apparmor_parser -r /etc/apparmor.d/usr.sbin.logshipper
sudo aa-enforce /usr/sbin/logshipper   # only needed if aa-complain was used while diagnosing
sudo aa-status | grep -A2 logshipper
```

### Step 5: Confirm the write succeeds

```bash
sudo systemctl restart logshipper
sleep 6
ls -l /srv/shiplogs/ship.log
sudo journalctl -k --since "10 seconds ago" | grep 'apparmor="DENIED"' | grep shiplogs
# (no output expected)
```

---

## Part 2: metrics-agent (read denial)

### Step 1: Confirm the profile's mode

```bash
sudo aa-status
```

Confirm `/usr/sbin/metrics-agent` appears under **enforce mode**.

### Step 2: Find the denial

```bash
sudo journalctl -k | grep 'apparmor="DENIED"' | grep metrics-agent
```

```text
apparmor="DENIED" operation="open" profile="/usr/sbin/metrics-agent" name="/etc/metrics-agent/remote.conf" comm="metrics-agent" requested_mask="r" denied_mask="r"
```

Note the `requested_mask="r"` — this is a **read** denial, not a write denial. AppArmor blocks reads exactly as readily as writes; the mechanism doesn't care which direction the access is.

### Step 3: Inspect and fix the profile

```bash
sudo cat /etc/apparmor.d/usr.sbin.metrics-agent
```

It only grants read access to `/etc/metrics-agent/local.conf` — the service's old config file. Add a rule for the new one:

```bash
sudo tee -a /etc/apparmor.d/local/usr.sbin.metrics-agent > /dev/null << 'EOF'
/etc/metrics-agent/remote.conf r,
EOF
```

(Or trigger a fresh denial with `sudo systemctl restart metrics-agent` and run `sudo aa-logprof` instead.)

### Step 4: Reload and confirm enforcement

```bash
sudo apparmor_parser -r /etc/apparmor.d/usr.sbin.metrics-agent
sudo aa-enforce /usr/sbin/metrics-agent   # only needed if aa-complain was used while diagnosing
sudo aa-status | grep -A2 metrics-agent
```

### Step 5: Confirm the read succeeds

```bash
sudo systemctl restart metrics-agent
sleep 6
sudo tail -n 3 /var/lib/metrics-agent/status
# ... metrics-agent read ok: TOKEN=remote-9f31ab
sudo journalctl -k --since "10 seconds ago" | grep 'apparmor="DENIED"' | grep metrics-agent
# (no output expected)
```

---

## Final Check

```bash
sudo aa-status
```

Both `/usr/sbin/logshipper` and `/usr/sbin/metrics-agent` must appear under **enforce mode**, and neither under **complain mode**. Leaving either profile in complain mode "fixes" the symptom without actually restoring MAC enforcement, and does not satisfy the task.
