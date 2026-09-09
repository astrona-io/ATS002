# Solution Guide: AppArmor Profile Path Denial

Follow these steps to diagnose and repair the AppArmor denial blocking `appservice` from writing to its relocated log directory.

---

## Step 1: Confirm AppArmor Is Active and Check the Profile's Mode

```bash
sudo aa-status
```

Look for `/usr/sbin/appservice` in the output. Confirm it appears under the **enforce mode** section — this rules out "the profile isn't loaded" and confirms the service really is subject to active AppArmor restriction.

---

## Step 2: Find the Denial in the Audit Trail

```bash
sudo journalctl -k | grep 'apparmor="DENIED"'
```

You should see a line similar to:

```text
apparmor="DENIED" operation="open" profile="/usr/sbin/appservice" name="/srv/applogs/app.log" comm="appservice" requested_mask="w" denied_mask="w"
```

`name="/srv/applogs/app.log"` is the exact path the profile needs a rule for.

---

## Step 3: Inspect the Current Profile

```bash
sudo cat /etc/apparmor.d/usr.sbin.appservice
```

The profile only grants access under `/var/log/appservice/` — the service's *old* log location. There is no rule at all for `/srv/applogs`, which is why the write fails even though DAC ownership and permissions on `/srv/applogs` are already correct.

---

## Step 4: Add the Missing Rule

### Option A — edit the local override directly

```bash
sudo tee -a /etc/apparmor.d/local/usr.sbin.appservice > /dev/null << 'EOF'
/srv/applogs/*.log rw,
/srv/applogs/ r,
EOF
```

### Option B — use aa-logprof

```bash
sudo systemctl restart appservice   # trigger a fresh denial
sudo aa-logprof                      # accept the suggested rule for /srv/applogs
```

Either approach is acceptable. `aa-logprof` writes into the same profile files under the hood.

---

## Step 5: Reload the Profile

```bash
sudo apparmor_parser -r /etc/apparmor.d/usr.sbin.appservice
```

Skipping this step is the most common mistake — an edited profile file has no effect on the running kernel until it's explicitly reloaded.

---

## Step 6: Confirm Enforcement and the Fix

```bash
sudo aa-enforce /usr/sbin/appservice   # only needed if you used aa-complain while diagnosing
sudo aa-status | grep -A2 appservice
sudo systemctl restart appservice
sleep 6
ls -l /srv/applogs/app.log
sudo journalctl -k --since "10 seconds ago" | grep 'apparmor="DENIED"'
```

* `aa-status` should list `/usr/sbin/appservice` under **enforce mode**, never under `complain mode`.
* `/srv/applogs/app.log` should exist, be recently modified, and keep growing on its own every few seconds.
* No fresh `DENIED` entries referencing `applogs` should appear.
