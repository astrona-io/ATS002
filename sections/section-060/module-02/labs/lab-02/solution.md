# Solution Walkthrough

This walkthrough reads the error, rules out the look-alikes and closes the dependency gap. The lab's setup installed `python3-pip` and then removed its requirement `python3-setuptools` from the database with `rpm -e --nodeps`. The database itself stayed perfectly consistent. (If `python3-pip` could not be installed, the setup uses `httpd` and its requirement `httpd-core` instead. `dnf check` names whichever pair your ship has; use those names in the steps below.)

All commands run inside `rpmbox` (`docker exec -it rpmbox bash`). If Docker answers with a permission error, put `sudo` in front. Inside the container you are the root user, so if `sudo` is not installed there, run the commands below without it.

## 1. Read the symptom carefully

```bash
dnf check
```

```text
python3-pip-... requires python3-setuptools, but none of the providers can be installed
Error: Check discovered 1 problem(s)
```

(The `...` stands for the package's version and release, which this output leaves out.)

The error names a **package** and a missing **requirement**. Nothing here says "database", "damaged header", "BDB" or "sqlite". Compare it with real corruption, which prints `error: rpmdb: ...` or `error: rpmdbNextIterator`.

## 2. Rule out the look-alikes

```bash
rpm -qa | wc -l          # completes cleanly, plausible count -> DB is fine
df -h /                  # plenty of free space -> not a disk-space issue
```

`rpm -qa` working perfectly is the giveaway: a corrupted database cannot be read from start to end. This is a **dependency gap**, not corruption.

## 3. Fix the actual problem, not with a rebuild

Find what is missing:

```bash
rpm -q --requires python3-pip | grep setuptools
rpm -q python3-setuptools          # "package python3-setuptools is not installed"
```

The required package was removed. Install it again:

```bash
sudo dnf -y install python3-setuptools
```

If the package that needs it is really unwanted, removing that package closes the gap too: `sudo dnf -y remove python3-pip`. The grader accepts either fix.

Running `rpm --rebuilddb` here would rebuild the indexes from the header data and change **nothing** about the missing package. That is the classic wasted step when a scary error is misread as corruption.

## 4. Verify

```bash
dnf check                # (no output, exit 0)
rpm -qa | wc -l          # still clean
```

From your own computer, not the lab machine, send the lab for grading:

```bash
astrona submit -c sections/section-060/module-02/labs/lab-02
```
