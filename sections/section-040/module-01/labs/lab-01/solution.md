# Solution Walkthrough

This walkthrough finds the AppArmor denial that blocks `appservice` from writing to its new log folder, adds the missing rule, reloads the profile and proves it still enforces. Run every command on the lab machine (`astrona ssh ats-002-lab-041`).

---

## Step 1: Confirm AppArmor is active and check the profile's mode

```bash
sudo aa-status
```

Look for `/usr/sbin/appservice` in the output. Confirm it appears under the **enforce mode** list. This rules out "the profile is not loaded" and proves that AppArmor really holds the service in check.

---

## Step 2: Find the denial in the kernel log

```bash
sudo journalctl -k | grep 'apparmor="DENIED"'
```

You see a line similar to:

```text
apparmor="DENIED" operation="open" profile="/usr/sbin/appservice" name="/srv/applogs/app.log" comm="appservice" requested_mask="w" denied_mask="w"
```

`name="/srv/applogs/app.log"` is the exact path the profile needs a rule for, and `profile="/usr/sbin/appservice"` is the profile to change.

On a fresh lab the log file does not exist yet, so your line may say `operation="mknod"` with `requested_mask="c"` and `denied_mask="c"` (create) instead of `open` and `w`. The fix is the same.

---

## Step 3: Inspect the current profile

```bash
sudo cat /etc/apparmor.d/usr.sbin.appservice
```

The profile only allows access under `/var/log/appservice/`, the service's *old* log folder. There is no rule at all for `/srv/applogs`. That is why the write fails even though the owner and permissions on `/srv/applogs` are correct.

---

## Step 4: Add the missing rule

You can add the rule by hand or let `aa-logprof` suggest it. Either way is accepted.

### Option A: edit the local override

The file `/etc/apparmor.d/local/usr.sbin.appservice` already exists and holds one comment line. Save this as `/etc/apparmor.d/local/usr.sbin.appservice` (for example with `sudo nano`):

```text
# Site-specific additions and overrides for usr.sbin.appservice go here.
/srv/applogs/*.log rw,
/srv/applogs/ r,
```

The first rule lets the service read and write `.log` files in the folder. The second lets it read the folder itself.

### Option B: use aa-logprof

```bash
sudo systemctl restart appservice   # trigger a fresh denial
sudo aa-logprof                      # accept the suggested rule for /srv/applogs
```

`aa-logprof` writes into the same profile files and reloads the profile for you.

---

## Step 5: Reload the profile

Apply it:

```bash
sudo apparmor_parser -r /etc/apparmor.d/usr.sbin.appservice
```

Skipping this step is the most common mistake. An edited profile file has no effect on the running kernel until you reload it. Pass the main profile: it pulls in the `local/` file through its `#include if exists` line.

---

## Step 6: Confirm enforcement and the fix

Then check the result:

```bash
sudo aa-enforce /usr/sbin/appservice   # only needed if you used aa-complain while diagnosing
sudo aa-status | grep -A2 appservice
sudo systemctl restart appservice
sleep 6
ls -l /srv/applogs/app.log
sudo journalctl -k --since "10 seconds ago" | grep 'apparmor="DENIED"'
```

* `aa-status` must list `/usr/sbin/appservice` under **enforce mode**, never under complain mode.
* `/srv/applogs/app.log` must exist, be recently changed, and keep growing on its own every few seconds.
* No new `DENIED` entries for `applogs` may appear.

---

## Step 7: Send it for grading

From your own computer, not the lab machine:

```bash
astrona submit -c sections/section-040/module-01/labs/lab-01
```

The grader checks that the profile is in enforce mode and not in complain mode, that `appservice` is running, that the profile files name `/srv/applogs`, that `/srv/applogs/app.log` grows over 8 seconds, and that no new denial for `applogs` was logged.
