# Solution Walkthrough

All commands below run **inside the `rpmbox` container**. Get a shell first:
```bash
docker exec -it rpmbox bash
```

---

## Step 1: Recognize and Confirm the Symptom

```bash
rpm -qa | tail -5
```
Look for database-related error text (rather than a clearly-named missing/conflicting package, which would point to a real dependency conflict instead). Rule out a disk-space problem separately:
```bash
df -h /var
```

---

## Step 2: Check the Actual Backend Before Assuming

```bash
ls -la /var/lib/rpm
```
Rocky Linux 9 uses a `sqlite`-backed database — look for `rpmdb.sqlite` (and possibly `-wal`/`-shm` sidecar files), not the older Berkeley DB `Packages`/`__db.*` layout some tutorials assume.

---

## Step 3: Back Up Before Touching Anything

```bash
sudo cp -a /var/lib/rpm /var/lib/rpm.bak-$(date +%s)
ls -d /var/lib/rpm.bak-*
```
This is not optional — it is your only rollback path if the rebuild doesn't go as expected.

---

## Step 4: Rebuild the Database

```bash
sudo rpm --rebuilddb
```
If a dedicated `rpmdb` command is available on this system (`command -v rpmdb`), the more current equivalent is:
```bash
sudo rpmdb --rebuilddb
```

---

## Step 5: Verify the Database Is Queryable Again

```bash
rpm -qa | wc -l
```
Expected: a clean numeric count, no interleaved error lines.

```bash
sudo dnf check
```
Expected: exits cleanly, confirming `dnf`'s own transaction-check logic (not just `rpm -qa`) is healthy against the rebuilt database.

```bash
sudo dnf check-update
```
Expected: completes normally rather than failing at a database-related stage.

---

## Quick Verification

```bash
rpm -qa | grep -i "error\|rpmdb" | wc -l   # expect 0
sudo dnf check                              # expect a clean exit
```
Once you're satisfied, run the local validation suite to pass the lab.

> **Note:** Depending on exactly how severely the corruption affected this system, the rebuilt package count may come back very slightly lower than before if a specific record was genuinely unrecoverable rather than just mis-indexed. If you notice a specific package missing after the rebuild, `dnf reinstall <package>` restores it — `--rebuilddb` fixes indexing, not lost header data.
