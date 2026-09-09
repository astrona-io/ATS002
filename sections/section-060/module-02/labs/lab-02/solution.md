# Solution Walkthrough

All commands run inside `rpmbox` (`docker exec -it rpmbox bash`).

## 1. Read the symptom carefully

```bash
dnf check
```

```text
python3-pip-... requires python3-setuptools, but none of the providers can be installed
Error: Check discovered 1 problem(s)
```

The error names a **package** and a missing **requirement**. Nothing here
says "database", "damaged header", "BDB", or "sqlite". Compare with real
corruption, which produces `error: rpmdb: ...` / `error: rpmdbNextIterator`.

## 2. Rule out the look-alikes

```bash
rpm -qa | wc -l          # completes cleanly, plausible count -> DB is fine
df -h /                  # plenty of free space -> not a disk-space issue
```

`rpm -qa` working perfectly is the tell: a corrupted database cannot be
iterated. This is a **dependency gap**, not corruption.

## 3. Fix the actual problem — not a rebuild

Find what is unsatisfied:

```bash
rpm -q --requires python3-pip | grep setuptools
rpm -q python3-setuptools          # "package python3-setuptools is not installed"
```

The requirement was removed. Reinstall it:

```bash
sudo dnf -y install python3-setuptools
```

(Alternatively, if the dependent package is genuinely unwanted:
`sudo dnf -y remove python3-pip`. Either closes the gap.)

Running `rpm --rebuilddb` at this point would rebuild the indexes from
header data and change **nothing** about the missing package — the classic
wasted step when a scary error is misread as corruption.

## 4. Verify

```bash
dnf check                # (no output, exit 0)
rpm -qa | wc -l          # still clean
```
