# Solution Walkthrough

All commands below run **inside the `rpmbox` container**. Get a shell first:
```bash
docker exec -it rpmbox bash
```

---

## Step 1: Inspect the `.rpm` File's Metadata Before Installing

```bash
rpm -qip /home/candidate/downloads/logship-agent-2.1.0-1.x86_64.rpm
```
The `-p` modifier tells `rpm` to read the archive directly from disk rather than looking for an already-installed package of the same name.

---

## Step 2: Inspect the File List Before Installing

```bash
rpm -qlp /home/candidate/downloads/logship-agent-2.1.0-1.x86_64.rpm
```

---

## Step 3: Check Declared Dependencies Before Installing

```bash
rpm -qp --requires /home/candidate/downloads/logship-agent-2.1.0-1.x86_64.rpm
```

---

## Step 4: Install the Package Directly

```bash
sudo rpm -ivh /home/candidate/downloads/logship-agent-2.1.0-1.x86_64.rpm
```
Since `bash` and `coreutils` (the declared Requires) are already present in the base image, this completes cleanly.

---

## Step 5: Reverse Lookup — Which Package Owns an Existing File

```bash
rpm -qf /usr/bin/python3
```
No `-p` here — `/usr/bin/python3` is already on disk, owned by something already installed, so this is a database lookup, not an archive read.

---

## Step 6: Forward Lookup — Every File the New Package Owns

```bash
rpm -ql logship-agent
```
Expect `/usr/bin/logship-agent` and `/etc/logship-agent/agent.conf`.

---

## Step 7: Confirm Installed Metadata

```bash
rpm -qi logship-agent
```

---

## Step 8: Verify Integrity

```bash
rpm -V logship-agent
```
Clean output (nothing printed) is expected immediately after install — nothing has had a chance to legitimately or illegitimately modify the files yet.

---

## Step 9: Query Dependency Introspection

```bash
rpm -q --requires logship-agent
rpm -q --provides logship-agent
```

---

## Quick Verification

```bash
rpm -q logship-agent
rpm -qf /usr/bin/python3
rpm -ql logship-agent
rpm -V logship-agent
```
Once you're satisfied, run the local validation suite to pass the lab.
