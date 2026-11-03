# Solution Walkthrough

The skill here is diagnosis: read all three ceilings, find the one that is really too low, and change nothing else.

## 1. Inspect all three ceilings

```bash
sysctl -n kernel.pid_max
# 4194304                       <- generous, not the problem

systemctl show data-ingest.service -p TasksMax --value
# infinity                      <- uncapped, not the problem

sudo -iu dataproc bash -c 'ulimit -u'
# 256                           <- THIS is the clamp
```

Two of the three are already far above what a thread-heavy job needs. The `dataproc` user's per-user process ceiling (`RLIMIT_NPROC`) is `256`. That is what stops `fork()`.

## 2. Confirm where it comes from

```bash
grep -rn nproc /etc/security/limits.conf /etc/security/limits.d/
# /etc/security/limits.d/00-dataproc-baseline.conf:1:dataproc soft nproc 256
# /etc/security/limits.d/00-dataproc-baseline.conf:2:dataproc hard nproc 256
```

`pam_limits` reads these files at login. The baseline file holds the limit at `256`.

## 3. Raise only `ulimit -u`, persistently

Add a drop-in file whose name sorts **after** the baseline file. When two files set the same limit, `pam_limits` uses the one it reads later.

Save this as `/etc/security/limits.d/50-dataproc.conf`:

```text
dataproc soft nproc 32768
dataproc hard nproc 65536
```

There is no apply command. `pam_limits` reads the file at the next login.

## 4. Verify, and check that you left the others alone

```bash
sudo -iu dataproc bash -c 'ulimit -u'    # 32768 (new login session picks up the drop-in)
sysctl -n kernel.pid_max                 # still 4194304 — untouched
systemctl show data-ingest.service -p TasksMax --value   # still infinity — untouched
```

`pam_limits` works at login, so a session that was open *before* your edit keeps the old value. `sudo -iu` starts a fresh one. The service itself is a systemd unit and does not go through `pam_limits`. For it, the unit's own `TasksMax=` and `LimitNPROC=` apply, and both are already fine here, so no change was needed.

## 5. Send it for grading

From your own computer, run:

```sh
astrona submit -c sections/section-010/module-02/labs/lab-02
```

If the check fails, its message says which ceiling is wrong. A message about `kernel.pid_max` or `TasksMax` means you changed a ceiling that was never the problem: remove that change and submit again.
