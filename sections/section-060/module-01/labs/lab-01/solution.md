# Solution Walkthrough

This walkthrough reads the package file first, installs it with `rpm`, and then checks it from the installed side. The lab's setup built `logship-agent-2.1.0-1` with `rpmbuild` and placed it in `/home/candidate/downloads/`. The package needs only `bash` and `coreutils`, and it ships two files: `/usr/bin/logship-agent` and the configuration file `/etc/logship-agent/agent.conf`.

All commands below run **inside the `rpmbox` container**. Get a shell first:
```bash
docker exec -it rpmbox bash
```

If Docker answers with a permission error, run it with `sudo` in front. Inside the container you are the root user, so if `sudo` is not installed there, run the commands below without it.

---

## Step 1: Inspect the package details before installing

```bash
rpm -qip /home/candidate/downloads/logship-agent-2.1.0-1.x86_64.rpm
```
The `-p` modifier tells `rpm` to read the file on disk, not to look for an installed package of the same name.

---

## Step 2: Inspect the file list before installing

```bash
rpm -qlp /home/candidate/downloads/logship-agent-2.1.0-1.x86_64.rpm
```

This shows where the package will write before it writes anything.

---

## Step 3: Check the declared dependencies before installing

```bash
rpm -qp --requires /home/candidate/downloads/logship-agent-2.1.0-1.x86_64.rpm
```

The list tells you whether a plain `rpm -ivh` will succeed or refuse.

---

## Step 4: Install the package directly

```bash
sudo rpm -ivh /home/candidate/downloads/logship-agent-2.1.0-1.x86_64.rpm
```
The declared requirements, `bash` and `coreutils`, are already in the base image, so this finishes cleanly.

---

## Step 5: File to package, for a file that already existed

```bash
rpm -qf /usr/bin/python3
```
There is no `-p` here. `/usr/bin/python3` is already on disk and belongs to an installed package, so this is a question for the RPM database, not a file read.

---

## Step 6: Package to files, for the new package

```bash
rpm -ql logship-agent
```
Expect `/usr/bin/logship-agent` and `/etc/logship-agent/agent.conf`.

---

## Step 7: Confirm the installed details

```bash
rpm -qi logship-agent
```

This is the same information as Step 1, now read from the database instead of the file.

---

## Step 8: Verify integrity

```bash
rpm -V logship-agent
```
Expect no output at all. Right after the install, nothing has had a chance to change the files yet. If you edited `agent.conf`, `rpm -V` would print a line for it and the grader would fail this check.

---

## Step 9: Read what the package needs and offers

```bash
rpm -q --requires logship-agent
rpm -q --provides logship-agent
```

The requirements include `bash` and `coreutils`, which the grader checks.

---

## Quick verification

```bash
rpm -q logship-agent
rpm -qf /usr/bin/python3
rpm -ql logship-agent
rpm -V logship-agent
```

`rpm -q` must print `logship-agent-2.1.0-1.x86_64`, and `rpm -V` must print nothing.

From your own computer, not the lab machine, send the lab for grading:

```bash
astrona submit -c sections/section-060/module-01/labs/lab-01
```
