# Solution Walkthrough

Follow these steps to find the guilty process, resolve its executable, and clean it up.

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

---

## Step 2: Attach strace to each PID, filtered to the `kill` syscall

```bash
sudo strace -p 1234 -e trace=kill &
sudo strace -p 1235 -e trace=kill &
sudo strace -p 1236 -e trace=kill &
wait
```

Watch for at least 15-20 seconds — the forbidden syscall fires periodically, not necessarily instantly. You should see a line like:

```text
kill(1235, 0)                          = 0
```

attributed to `collector2`'s session — that process is confirmed guilty. `collector1` and `collector3` should show nothing over the same window.

---

## Step 3: Resolve the actual executable backing the guilty PID

```bash
sudo readlink -f /proc/1235/exe
```

```text
/usr/local/bin/collector2
```

Do this **before** terminating the process — once it's killed, `/proc/1235/` no longer exists.

---

## Step 4: Terminate the confirmed process

```bash
sudo kill 1235
sleep 2
ps -p 1235
```

Escalate if it's still alive:

```bash
sudo kill -9 1235
```

---

## Step 5: Remove the confirmed executable

```bash
sudo rm /usr/local/bin/collector2
```

Use the exact path captured in Step 3 — not a path guessed from the process name.

---

## Step 6: Leave the innocent processes alone

`collector1` and `collector3` showed no `kill()` calls — leave them running with their executables intact.

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

Once verified, run the local validation suite to pass the lab!
