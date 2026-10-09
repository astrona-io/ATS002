# Solution Walkthrough

This walkthrough repairs the database first, because every later step needs it. Then it installs the waiting package and the build toolchain. The lab's setup built `metrics-shipper-1.4.0-1` (it needs only `bash` and `coreutils`, and ships `/usr/bin/metrics-shipper` and the configuration file `/etc/metrics-shipper/agent.conf`). After that, it damaged `/var/lib/rpm/rpmdb.sqlite`.

All commands below run **inside the `rpmbox` container**. Get a shell first:
```bash
docker exec -it rpmbox bash
```

If Docker answers with a permission error, run it with `sudo` in front. Inside the container you are the root user, so if `sudo` is not installed there, run the commands below without it.

---

## Step 1: Diagnose the database before touching anything

```bash
rpm -qa | tail -5
```
Look for error text about the database (`error: rpmdb: ...`, a `sqlite` "disk image" error and so on). A clearly named missing or conflicting package would mean a dependency problem, and an outright "no space left" message would mean a disk-space problem. Rule out disk space separately:
```bash
df -h /var
```

Check the real backend before assuming anything. Rocky Linux 9 uses a `sqlite` store, not the older Berkeley DB layout:
```bash
ls -la /var/lib/rpm
```
Expect `rpmdb.sqlite` (and possibly `-wal` and `-shm` side files).

---

## Step 2: Back up and rebuild

```bash
sudo cp -a /var/lib/rpm /var/lib/rpm.bak-$(date +%s)
ls -d /var/lib/rpm.bak-*
```
This is not optional. It is your only way back if the rebuild does not go as expected.

```bash
sudo rpm --rebuilddb
```
Or, if a separate database command exists on this system (`command -v rpmdb`):
```bash
sudo rpmdb --rebuilddb
```

Check that the repair really worked, end to end:
```bash
rpm -qa | wc -l
sudo dnf check
```
Expect a clean package count with no error lines mixed in, and a clean exit from `dnf check`. That proves not only `rpm -qa` but also `dnf`'s own consistency check works again.

---

## Step 3: Inspect, then install the waiting package

```bash
rpm -qip /home/candidate/downloads/metrics-shipper-1.4.0-1.x86_64.rpm
rpm -qlp /home/candidate/downloads/metrics-shipper-1.4.0-1.x86_64.rpm
rpm -qp --requires /home/candidate/downloads/metrics-shipper-1.4.0-1.x86_64.rpm
```
`-p` reads the file on disk directly; nothing has to be installed for these queries.

```bash
sudo rpm -ivh /home/candidate/downloads/metrics-shipper-1.4.0-1.x86_64.rpm
```
Its declared requirements, `bash` and `coreutils`, are already in the base image, so this finishes cleanly now that the database is healthy again.

```bash
rpm -ql metrics-shipper
rpm -V metrics-shipper
```
Confirm the files it placed (`/usr/bin/metrics-shipper`, `/etc/metrics-shipper/agent.conf`) and that `rpm -V` prints nothing right after the install. Do not edit `agent.conf`, or the verify line for it will fail the grader.

---

## Step 4: Discover and install the build toolchain

```bash
dnf group list
dnf group list --hidden
```
Confirm that `"Development Tools"` really is a group the repositories publish, not a guess.

```bash
dnf group info "Development Tools"
```
Read the Mandatory, Default and Optional lists before you install anything.

```bash
sudo dnf group install "Development Tools"
```

---

## Step 5: Confirm everything landed

```bash
rpm -q metrics-shipper
rpm -V metrics-shipper
dnf group info "Development Tools"
dnf group list installed
rpm -q gcc make
sudo dnf check
```
Expected: `metrics-shipper-1.4.0-1.x86_64` is installed with a clean verify; `"Development Tools"` appears in the installed groups, with installed markers next to its members in `dnf group info`; `gcc` and `make` both print real installed versions; and `dnf check` exits cleanly.

---

## Quick verification

```bash
rpm -qa | grep -i "error\|rpmdb" | wc -l   # expect 0
rpm -q metrics-shipper                      # expect metrics-shipper-1.4.0-1.x86_64
dnf group list installed | grep -i "development tools"   # expect a match
rpm -q gcc make                             # expect version strings, not "not installed"
sudo dnf check                              # expect a clean exit
```

From your own computer, not the lab machine, send the lab for grading:

```bash
astrona submit -c sections/section-060/capstone/labs/lab-01
```
