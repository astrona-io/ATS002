# Solution Walkthrough

All commands below run **inside the `rpmbox` container**. Get a shell first:
```bash
docker exec -it rpmbox bash
```

---

## Step 1: Diagnose the Database Before Touching Anything

```bash
rpm -qa | tail -5
```
Look for database-layer error text (`error: rpmdb: ...`, a raw sqlite disk-image error, etc.) rather than a clearly-named missing/conflicting package (a real dependency conflict) or an outright "no space left" message (a disk-space problem). Rule out disk space separately:
```bash
df -h /var
```

Check the actual backend before assuming anything — Rocky Linux 9 uses a `sqlite`-backed store, not the older Berkeley DB layout:
```bash
ls -la /var/lib/rpm
```
Expect `rpmdb.sqlite` (and possibly stale `-wal`/`-shm` sidecar files).

---

## Step 2: Back Up and Rebuild

```bash
sudo cp -a /var/lib/rpm /var/lib/rpm.bak-$(date +%s)
ls -d /var/lib/rpm.bak-*
```
Not optional — this is the only rollback path if the rebuild doesn't go as expected.

```bash
sudo rpm --rebuilddb
```
Or, if a dedicated database-maintenance command exists on this system (`command -v rpmdb`):
```bash
sudo rpmdb --rebuilddb
```

Verify the repair actually worked end to end:
```bash
rpm -qa | wc -l
sudo dnf check
```
Expect a clean numeric package count with no interleaved error lines, and a clean exit from `dnf check` — confirming not just `rpm -qa` but `dnf`'s own transaction-check machinery is healthy again.

---

## Step 3: Inspect, Then Install the Staged Package

```bash
rpm -qip /home/candidate/downloads/metrics-shipper-1.4.0-1.x86_64.rpm
rpm -qlp /home/candidate/downloads/metrics-shipper-1.4.0-1.x86_64.rpm
rpm -qp --requires /home/candidate/downloads/metrics-shipper-1.4.0-1.x86_64.rpm
```
`-p` reads the archive directly from disk — no assumption about anything already being installed.

```bash
sudo rpm -ivh /home/candidate/downloads/metrics-shipper-1.4.0-1.x86_64.rpm
```
`bash` and `coreutils` (its declared Requires) are already present in the base image, so this completes cleanly now that the database itself is healthy again.

```bash
rpm -ql metrics-shipper
rpm -V metrics-shipper
```
Confirm the files it placed (`/usr/bin/metrics-shipper`, `/etc/metrics-shipper/agent.conf`) and that `rpm -V` reports clean — no output — immediately after install.

---

## Step 4: Discover and Install the Build Toolchain

```bash
dnf group list
dnf group list --hidden
```
Confirm `"Development Tools"` is genuinely a repository-published group, not a guess.

```bash
dnf group info "Development Tools"
```
Read the Mandatory/Default/Optional sections before installing anything.

```bash
sudo dnf group install "Development Tools"
```

---

## Step 5: Confirm Everything Landed

```bash
rpm -q metrics-shipper
rpm -V metrics-shipper
dnf group info "Development Tools"
dnf group list installed
rpm -q gcc make
sudo dnf check
```
Expected: `metrics-shipper-1.4.0-1.x86_64` installed with a clean verify; `"Development Tools"` present in the installed-groups listing with an installed-indicator against its members in `dnf group info`; `gcc` and `make` both resolve to real installed version strings; `dnf check` exits cleanly.

---

## Quick Verification

```bash
rpm -qa | grep -i "error\|rpmdb" | wc -l   # expect 0
rpm -q metrics-shipper                      # expect metrics-shipper-1.4.0-1.x86_64
dnf group list installed | grep -i "development tools"   # expect a match
rpm -q gcc make                             # expect version strings, not "not installed"
sudo dnf check                              # expect a clean exit
```
Once you're satisfied, run the local validation suite to pass the lab.
