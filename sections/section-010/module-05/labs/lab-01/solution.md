# Solution Walkthrough

This walkthrough finds the guilty process with `strace`, records its real program file, ends it, and removes that file. The two innocent processes stay untouched. You can run `astrona submit` after any step: each failing check names the one thing still missing.

---

## Step 1: Find the PIDs of all three candidate processes

```bash
pgrep -a -f collector
```

```text
1234 /usr/local/bin/collector1
1235 /usr/local/bin/collector2
1236 /usr/local/bin/collector3
```

Your PIDs will differ, so use the ones `pgrep` prints in every command below. On this lab machine, each service also passes a Python script as an argument (for example `/opt/lab-scripts/collector2.py`), so your command lines will probably be longer than the sample above, which shows only the program path.

---

## Step 2: Attach strace to each PID, filtered to the `kill` syscall

```bash
sudo strace -p 1234 -e trace=kill &
sudo strace -p 1235 -e trace=kill &
sudo strace -p 1236 -e trace=kill &
wait
```

The processes run as another user, and `kernel.yama.ptrace_scope` only lets root attach to a process you did not start, so `sudo` is needed. Watch for at least 15 to 20 seconds: the forbidden call happens at regular intervals, not necessarily at once. You should see a line like this:

```text
kill(1235, 0)                          = 0
```

The line comes from `collector2`'s session, so that process is confirmed guilty. `collector1` and `collector3` should show nothing over the same time.

---

## Step 3: Resolve the real program file behind the guilty PID

```bash
sudo readlink -f /proc/1235/exe
```

```text
/usr/local/bin/collector2
```

Do this **before** you end the process. Once it is gone, the kernel removes `/proc/1235/`, and the path can no longer be read there.

---

## Step 4: Terminate the confirmed process

```bash
sudo kill 1235
sleep 2
ps -p 1235
```

`kill` sends `SIGTERM`, which asks the process to finish and leave. If `ps` still lists it, escalate to `SIGKILL`, which the kernel carries out at once:

```bash
sudo kill -9 1235
```

---

## Step 5: Remove the confirmed program file

```bash
sudo rm /usr/local/bin/collector2
```

Use the exact path you captured in Step 3, not a path guessed from the process name.

---

## Step 6: Leave the innocent processes alone

`collector1` and `collector3` showed no `kill()` calls. Leave them running, with their program files in place.

---

## Verification

```bash
pgrep -a -f collector1
pgrep -a -f collector3

pgrep -a -f collector2
# (no output)

ls -l /usr/local/bin/collector2
# ls: cannot access '/usr/local/bin/collector2': No such file or directory
```

Then send the mission for grading:

```bash
astrona submit -c sections/section-010/module-05/labs/lab-01
```

---

## Command Summary

```bash
pgrep -a -f collector
sudo strace -p 1234 -e trace=kill &
sudo strace -p 1235 -e trace=kill &
sudo strace -p 1236 -e trace=kill &
wait
sudo readlink -f /proc/1235/exe
sudo kill 1235
sleep 2
ps -p 1235          # escalate to `sudo kill -9 1235` if still alive
sudo rm /usr/local/bin/collector2
pgrep -a -f collector2   # verify gone
```
