# Solution Walkthrough

Both services fail for the same reason: an AppArmor profile that only knows a path the service no longer uses. The direction of the blocked access is different: one is a write, the other a read. Work through each service on its own. Run every command on the lab machine (`astrona ssh ats-002-lab-040`).

---

## Service 1: logshipper (write denial)

Start with the service that cannot write its log.

### Step 1: Confirm the profile's mode

```bash
sudo aa-status
```

Confirm that `/usr/sbin/logshipper` appears under **enforce mode**.

### Step 2: Find the denial

```bash
sudo journalctl -k | grep 'apparmor="DENIED"' | grep logshipper
```

```text
apparmor="DENIED" operation="open" profile="/usr/sbin/logshipper" name="/srv/shiplogs/ship.log" comm="logshipper" requested_mask="w" denied_mask="w"
```

On a fresh lab the log file does not exist yet, so your line may say `operation="mknod"` with `requested_mask="c"` and `denied_mask="c"` (create) instead of `open` and `w`. The fix is the same.

### Step 3: Inspect and fix the profile

```bash
sudo cat /etc/apparmor.d/usr.sbin.logshipper
```

It only allows access under `/var/log/logshipper/`. The local override already exists and holds one comment line. Save this as `/etc/apparmor.d/local/usr.sbin.logshipper` (for example with `sudo nano`):

```text
# Site-specific additions and overrides for usr.sbin.logshipper go here.
/srv/shiplogs/*.log rw,
/srv/shiplogs/ r,
```

Instead of editing by hand, you can trigger a fresh denial with `sudo systemctl restart logshipper` and run `sudo aa-logprof`.

### Step 4: Reload and confirm enforcement

Apply it:

```bash
sudo apparmor_parser -r /etc/apparmor.d/usr.sbin.logshipper
sudo aa-enforce /usr/sbin/logshipper   # only needed if aa-complain was used while diagnosing
sudo aa-status | grep -A2 logshipper
```

### Step 5: Confirm the write works

Then check the result:

```bash
sudo systemctl restart logshipper
sleep 6
ls -l /srv/shiplogs/ship.log
sudo journalctl -k --since "10 seconds ago" | grep 'apparmor="DENIED"' | grep shiplogs
# (no output expected)
```

---

## Service 2: metrics-agent (read denial)

Now the service that cannot read its new configuration file.

### Step 1: Confirm the profile's mode

```bash
sudo aa-status
```

Confirm that `/usr/sbin/metrics-agent` appears under **enforce mode**.

### Step 2: Find the denial

```bash
sudo journalctl -k | grep 'apparmor="DENIED"' | grep metrics-agent
```

```text
apparmor="DENIED" operation="open" profile="/usr/sbin/metrics-agent" name="/etc/metrics-agent/remote.conf" comm="metrics-agent" requested_mask="r" denied_mask="r"
```

Note `requested_mask="r"`: this is a **read** denial, not a write denial. AppArmor blocks reads just as it blocks writes. The method does not care which direction the access goes.

### Step 3: Inspect and fix the profile

```bash
sudo cat /etc/apparmor.d/usr.sbin.metrics-agent
```

It only allows reading `/etc/metrics-agent/local.conf`, the service's old configuration file. The local override already exists and holds one comment line. Save this as `/etc/apparmor.d/local/usr.sbin.metrics-agent`:

```text
# Site-specific additions and overrides for usr.sbin.metrics-agent go here.
/etc/metrics-agent/remote.conf r,
```

The grader looks for the exact path `/etc/metrics-agent/remote.conf` in the profile files, so name the file itself rather than a wildcard. Instead of editing by hand, you can trigger a fresh denial with `sudo systemctl restart metrics-agent` and run `sudo aa-logprof`; choose the exact path when it asks.

### Step 4: Reload and confirm enforcement

Apply it:

```bash
sudo apparmor_parser -r /etc/apparmor.d/usr.sbin.metrics-agent
sudo aa-enforce /usr/sbin/metrics-agent   # only needed if aa-complain was used while diagnosing
sudo aa-status | grep -A2 metrics-agent
```

### Step 5: Confirm the read works

Then check the result:

```bash
sudo systemctl restart metrics-agent
sleep 6
sudo tail -n 3 /var/lib/metrics-agent/status
# ... metrics-agent read ok: TOKEN=remote-9f31ab
sudo journalctl -k --since "10 seconds ago" | grep 'apparmor="DENIED"' | grep metrics-agent
# (no output expected)
```

---

## Final check

```bash
sudo aa-status
```

Both `/usr/sbin/logshipper` and `/usr/sbin/metrics-agent` must appear under **enforce mode**, and neither under complain mode. A profile left in complain mode hides the symptom without bringing MAC enforcement back, and it fails the task.

When both services pass, send the capstone for grading from your own computer:

```bash
astrona submit -c sections/section-040/capstone/labs/lab-01
```
