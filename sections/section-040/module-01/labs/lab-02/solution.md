# Solution Walkthrough

This walkthrough closes an AppArmor **read** denial. The method is the same as for a write denial: read the denial line, add a rule for the exact path, reload the profile, and leave it in enforce mode. Only the mask and the rule are different. Run every command on the lab machine (`astrona ssh ats-002-lab-042`).

---

## Step 1: Confirm the profile is enforcing

```bash
sudo aa-status | grep -A2 'enforce mode' | grep credsync
#    /usr/sbin/credsync
```

The profile is loaded and in enforce mode, so AppArmor is in play. `grep -A2` only shows the two lines after each "enforce mode" heading. If this prints nothing, run `sudo aa-status` on its own and look for `/usr/sbin/credsync` in the enforce mode list.

---

## Step 2: Read the denial

```bash
sudo journalctl -k | grep 'apparmor="DENIED"' | grep credsync | tail -1
```

```text
apparmor="DENIED" operation="open" profile="/usr/sbin/credsync"
  name="/etc/credsync/api.key" requested_mask="r" denied_mask="r" ...
```

`requested_mask="r"` and `denied_mask="r"` mean a **read** was refused on `name="/etc/credsync/api.key"`. There is no label and no context: AppArmor decided only on that path string.

---

## Step 3: Find the gap in the profile

```bash
grep -n credsync /etc/apparmor.d/usr.sbin.credsync
```

```text
  /var/lib/credsync/ r,
  /var/lib/credsync/** r,
```

(Shortened to the two rules that matter. On the machine, `grep -n` also prints other lines that mention `credsync`, and puts the line number in front of each line.) The profile only allows the **old** key location. There is no rule for `/etc/credsync/` at all.

---

## Step 4: Add a read rule to the local override

The file `/etc/apparmor.d/local/usr.sbin.credsync` already exists and holds one comment line. Save this as `/etc/apparmor.d/local/usr.sbin.credsync` (for example with `sudo nano`):

```text
# Site-specific additions for usr.sbin.credsync go here.
/etc/credsync/ r,
/etc/credsync/api.key r,
```

Only `r`: the daemon reads the key, it does not write it. If you reproduce the read and run `sudo aa-logprof` instead, it suggests the same rule and lets you choose the exact path or a wildcard.

---

## Step 5: Reload the profile

Apply it, passing the main profile path:

```bash
sudo apparmor_parser -r /etc/apparmor.d/usr.sbin.credsync
```

The main profile pulls in the `local/` file through the soft include at its end.

---

## Step 6: Check that it still enforces and the read works

Then check the result:

```bash
sudo aa-status | grep -A2 'enforce mode' | grep credsync   # still enforce
sleep 6
cat /run/credsync/ready                                     # "ok <recent timestamp>"
sudo journalctl -k --since '15 seconds ago' | grep credsync # no new DENIED
```

The profile is still in enforce mode, `/run/credsync/ready` holds `ok` and a recent time stamp, and no new denial appears. A read denial works just like a write denial. Only the mask in the audit line (`r` instead of `w` or `c`) and the rule you add (`r` instead of `rw`) change.

---

## Step 7: Send it for grading

From your own computer, not the lab machine:

```bash
astrona submit -c sections/section-040/module-01/labs/lab-02
```

The grader checks that the profile is in enforce mode, that `credsync` is running, that `/run/credsync/ready` exists and is fresh, and that no new denial for `credsync` was logged.
