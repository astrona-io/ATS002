# Solution Walkthrough

This walkthrough confirms the damage, copies the database, rebuilds it and proves the repair. The lab's setup installed a few extra packages (`vim-enhanced`, `wget`, `tree`) and then overwrote part of `/var/lib/rpm/rpmdb.sqlite` with random bytes and cut off its end. It also deleted the `-wal` and `-shm` side files. Package files under `/usr` and `/etc` were not touched.

All commands below run **inside the `rpmbox` container**. Get a shell first:
```bash
docker exec -it rpmbox bash
```

If Docker answers with a permission error, run it with `sudo` in front. Inside the container you are the root user, so if `sudo` is not installed there, run the commands below without it.

---

## Step 1: Recognise and confirm the symptom

```bash
rpm -qa | tail -5
```
Look for error text about the database. A clearly named missing or conflicting package would point to a dependency problem instead. Rule out a disk-space problem separately:
```bash
df -h /var
```

---

## Step 2: Check the real backend before assuming

```bash
ls -la /var/lib/rpm
```
Rocky Linux 9 uses a `sqlite` database. Look for `rpmdb.sqlite` (and possibly `-wal` and `-shm` side files), not the older Berkeley DB `Packages` and `__db.*` files that some guides assume.

---

## Step 3: Back up before touching anything

```bash
sudo cp -a /var/lib/rpm /var/lib/rpm.bak-$(date +%s)
ls -d /var/lib/rpm.bak-*
```
This is not optional. It is your only way back if the rebuild does not go as expected.

---

## Step 4: Rebuild the database

```bash
sudo rpm --rebuilddb
```
If a separate `rpmdb` command exists on this system (`command -v rpmdb`), this newer form does the same repair:
```bash
sudo rpmdb --rebuilddb
```

---

## Step 5: Verify the database answers again

```bash
rpm -qa | wc -l
```
Expected: a clean number, with no error lines mixed in.

```bash
sudo dnf check
```
Expected: it finishes cleanly. This proves `dnf`'s own consistency check, not just `rpm -qa`, works against the rebuilt database.

```bash
sudo dnf check-update
```
Expected: it completes normally instead of failing at a database step.

---

## Quick verification

```bash
rpm -qa | grep -i "error\|rpmdb" | wc -l   # expect 0
sudo dnf check                              # expect a clean exit
```

The grader runs `rpm -qa` and `dnf check` inside `rpmbox`: both must succeed, `rpm -qa` must print no error text, and it must list at least 20 packages.

From your own computer, not the lab machine, send the lab for grading:

```bash
astrona submit -c sections/section-060/module-02/labs/lab-01
```

Depending on how badly the damage hit, the rebuilt package count may come back slightly lower than before, if one record was really lost rather than only badly indexed. If you notice a specific package missing after the rebuild, `dnf reinstall <package>` restores it. `--rebuilddb` fixes indexes; it cannot bring back lost header data.
