# Solution Walkthrough

Follow these steps to check and raise all three independent ceilings. Each ceiling has a live part and a permanent part, and the grader checks both.

---

## Step 1: Confirm this is a fork ceiling, not memory or CPU pressure

```bash
free -m
top -bn1 | head -5
dmesg | tail -30 | grep -iE 'fork|cannot allocate|out of memory'
```

Idle-looking CPU and memory together with `fork` or `pthread_create` failures is the signature of a process or thread ceiling, not of a real shortage of resources.

---

## Step 2: Read the current `kernel.pid_max` value

```bash
sysctl -n kernel.pid_max
cat /proc/sys/kernel/pid_max
```

You should see the old kernel default, `32768`. The lab setup forces it with the file `/etc/sysctl.d/01-pid-max-baseline.conf`. A 64-bit kernel supports values up to `4194304` (2²²).

Note: Ubuntu 24.04 also ships its own sysctl file that sets `kernel.pid_max` to `4194304`, and it can win over the low baseline when the files are applied. If you already see `4194304` here, the live part is done. You still need your own persistent file in the next step, because the grader looks for one.

---

## Step 3: Raise `kernel.pid_max` live, then make it permanent

Change the live value:

```bash
sudo sysctl -w kernel.pid_max=4194304
```

Save this as `/etc/sysctl.d/98-pid-max.conf`:

```ini
kernel.pid_max = 4194304
```

Apply it:

```sh
sudo sysctl --system
```

The live `sysctl -w` change alone would be lost at the next reboot. The drop-in file under `/etc/sysctl.d/` together with `sysctl --system` makes the value both immediate and permanent. Do not edit the baseline file `01-pid-max-baseline.conf`: the grader ignores it and looks for your own file.

**Check your progress:** run `astrona submit -c sections/section-010/module-02/labs/lab-01` from your own computer. The `pid_max` check should now pass. The other two still fail, which is expected.

---

## Step 4: Check the second ceiling, `ulimit -u` for the `dataproc` user

```bash
sudo -iu dataproc bash -c 'ulimit -u'
```

This shows a low value, far below what a thread-heavy workload needs. The setup put it in `/etc/security/limits.d/00-dataproc-baseline.conf`.

Raise it permanently with a file under `/etc/security/limits.d/`. `pam_limits` reads these files when a session starts. When two files set the same limit, the file read later wins, so your new file must sort after the baseline file in alphabetical order.

Save this as `/etc/security/limits.d/50-dataproc.conf`:

```text
dataproc soft nproc 32768
dataproc hard nproc 65536
```

There is no apply command: `pam_limits` reads the file at the next login. Confirm that a fresh session for that user picks it up:

```bash
sudo -iu dataproc bash -c 'ulimit -u'
# 32768
```

`-iu dataproc` starts a full login session as `dataproc`, and that is what makes `pam_limits` read the limit files again. A shell that was already open would not pick up the change without a fresh login.

---

## Step 5: Check the third ceiling, `TasksMax=` on the systemd unit

```bash
systemctl show data-ingest.service --property=TasksMax,TasksCurrent
```

The setup started this unit with a low `TasksMax=` written straight into its unit file. Raise it with a systemd override. `systemctl edit` opens an editor on a new drop-in file:

```bash
sudo systemctl edit data-ingest.service
```

Add these lines, then save and close the editor:

```ini
[Service]
TasksMax=infinity
```

Apply it to the running unit:

```bash
sudo systemctl daemon-reload
sudo systemctl restart data-ingest.service
```

`daemon-reload` makes systemd read the override. The restart makes sure the running cgroup gets the new limit too. The grader reads the value with `systemctl show`, which reports `infinity` once systemd has loaded the override.

---

## Step 6: Verify all three

```bash
sysctl -n kernel.pid_max
# 4194304

cat /etc/sysctl.d/98-pid-max.conf
# kernel.pid_max = 4194304

sudo -iu dataproc bash -c 'ulimit -u'
# 32768

grep dataproc /etc/security/limits.d/50-dataproc.conf
# dataproc soft nproc 32768
# dataproc hard nproc 65536

systemctl show data-ingest.service --property=TasksMax
# TasksMax=infinity
```

Then send it for grading from your own computer:

```sh
astrona submit -c sections/section-010/module-02/labs/lab-01
```

All three checks should pass. If one fails, its message names the ceiling and the value it found.

---

## Command Summary

```bash
free -m
sysctl -n kernel.pid_max

sudo sysctl -w kernel.pid_max=4194304
# save /etc/sysctl.d/98-pid-max.conf  (kernel.pid_max = 4194304)
sudo sysctl --system

sudo -iu dataproc bash -c 'ulimit -u'
# save /etc/security/limits.d/50-dataproc.conf  (dataproc soft nproc 32768 / dataproc hard nproc 65536)

systemctl show data-ingest.service --property=TasksMax,TasksCurrent
sudo systemctl edit data-ingest.service
# [Service]
# TasksMax=infinity
sudo systemctl daemon-reload
sudo systemctl restart data-ingest.service
```
