# Solution Walkthrough

This walkthrough ends one stubborn process, lowers the priority of a busy one, and records the badge number of a quiet one. After each step you can run `astrona submit` from your own computer to see how far the grader agrees.

---

## Step 1: Find the three crew members

```bash
ps -u crew -o pid,ni,pcpu,stat,comm
```

This lists every process that belongs to the user `crew`. You should see `cpuburn.sh`, `stubborn.sh` and `crew-sleeper.sh`, plus short-lived `sleep` helpers. Note the niceness (`NI`) of `cpuburn.sh`, and that it uses far more CPU than the others.

---

## Step 2: End the stubborn process

```bash
PID=$(pgrep -f /opt/crew/stubborn.sh | head -1)
sudo kill "$PID"
ps -p "$PID" -o pid,stat,comm
```

The default signal is `SIGTERM`. `stubborn.sh` ignores it, so `ps` still lists the process. Now send the signal that cannot be ignored:

```bash
sudo kill -KILL "$PID"
ps -p "$PID" -o pid,stat,comm
```

This time `ps` prints only its heading line. The kernel ended the process, so it had no chance to ignore the order.

Run `astrona submit -c sections/section-010/module-07/labs/lab-01` now. The stubborn check should pass. The other two checks still fail.

---

## Step 3: Lower the priority of the CPU burner

```bash
PID=$(pgrep -f /opt/crew/cpuburn.sh | head -1)
sudo renice -n 15 -p "$PID"
ps -o pid,ni,comm -p "$PID"
```

`renice` changes the niceness of a running process. A higher niceness means the process is more polite and gives way to others. Only root may lower a niceness value, but any owner may raise it, and `sudo` makes this command work either way. The `NI` column now shows `15`.

Run `astrona submit` again. The niceness check should pass.

---

## Step 4: Record the sleeper's PID

```bash
pgrep -f /opt/crew/crew-sleeper.sh | head -1 | sudo tee /opt/course/7/sleeper-pid
cat /opt/course/7/sleeper-pid
```

`pgrep -f` matches against the whole command line and prints the PID. `tee` writes it to the file. The file holds only the number, followed by a newline, which the grader accepts.

Run `astrona submit` a last time. All three checks should pass.

---

## Command Summary

```bash
ps -u crew -o pid,ni,pcpu,stat,comm
PID=$(pgrep -f /opt/crew/stubborn.sh | head -1)
sudo kill "$PID"
sudo kill -KILL "$PID"
PID=$(pgrep -f /opt/crew/cpuburn.sh | head -1)
sudo renice -n 15 -p "$PID"
pgrep -f /opt/crew/crew-sleeper.sh | head -1 | sudo tee /opt/course/7/sleeper-pid
```
