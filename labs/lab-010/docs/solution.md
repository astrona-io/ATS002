# Solution Walkthrough

Five independent incident items, five independent fixes. Work through them in order — none of them depend on each other, but this is the order they were reported in.

---

## Task 1: Audit the live kernel state

**Reasoning:** Before touching any configuration, record what the machine actually looks like right now. `uname -r` gives the running kernel's release string (not `uname -v`, which is a build timestamp, not the release). `sysctl -n` gives a bare parameter value with no key name or `=` sign attached — exactly what a script-friendly audit file needs.

**Commands:**

```bash
sudo mkdir -p /opt/course/audit

uname -r > /tmp/kernel-release && sudo mv /tmp/kernel-release /opt/course/audit/kernel-release
sysctl -n vm.swappiness > /tmp/vm-swappiness && sudo mv /tmp/vm-swappiness /opt/course/audit/vm-swappiness
```

(Or, if `/opt/course/audit` is writable by your user, redirect directly — `uname -r | sudo tee /opt/course/audit/kernel-release > /dev/null` works too.)

**Verify:**

```bash
cat /opt/course/audit/kernel-release
cat /opt/course/audit/vm-swappiness
sysctl -n vm.swappiness   # cross-check: should match the file exactly
```

---

## Task 2: Raise the pid_max fork ceiling

**Reasoning:** `kernel.pid_max` governs the whole system's shared pool of PID/TID numbers. A `sysctl -w` change alone only pokes the live, in-memory value — nothing on disk changes, so it reverts on the next reboot. Persisting it means writing a drop-in file under `/etc/sysctl.d/` and re-applying with `sysctl --system`.

**Commands:**

```bash
sudo sysctl -w kernel.pid_max=1048576

echo "kernel.pid_max = 1048576" | sudo tee /etc/sysctl.d/99-pid-max.conf
sudo sysctl --system
```

A numeric prefix like `99-` places this file late in udev's — sorry, `sysctl.d`'s — lexical read order, so it wins even if the box already ships a lower baseline value in an earlier-sorting file.

**Verify:**

```bash
sysctl -n kernel.pid_max
# 1048576

cat /etc/sysctl.d/99-pid-max.conf
```

---

## Task 3: Kernel modules — load-and-persist `dummy`, blacklist `pcspkr`

**Reasoning:** These are two entirely separate module operations, and the persistence half of each uses two entirely separate config file families: `/etc/modules-load.d/` answers "should this load at boot," `/etc/modprobe.d/` answers "with what parameters" (and, separately, "should it ever auto-load at all").

**Check parameters before loading:**

```bash
modinfo -p dummy
```

**Load `dummy` live with the parameter:**

```bash
sudo modprobe dummy numdummies=4
lsmod | grep dummy
cat /sys/module/dummy/parameters/numdummies
# 4
```

**Persist the load and the parameter:**

```bash
echo "dummy" | sudo tee /etc/modules-load.d/dummy.conf
echo "options dummy numdummies=4" | sudo tee /etc/modprobe.d/dummy.conf
```

Prove the config file — not the earlier interactive command — is actually driving the value:

```bash
sudo modprobe -r dummy
sudo modprobe dummy
cat /sys/module/dummy/parameters/numdummies
# 4
```

**Blacklist and unload `pcspkr`:**

```bash
echo "blacklist pcspkr" | sudo tee /etc/modprobe.d/blacklist-pcspkr.conf
sudo modprobe -r pcspkr
```

**Confirm the blacklist holds against a simulated re-detection pass:**

```bash
sudo udevadm trigger
lsmod | grep pcspkr
# (no output)
```

A blacklist entry only blocks the *automatic*, hardware-detection-driven load path — it does not stop an explicit `sudo modprobe pcspkr`, and it does not retroactively unload an already-loaded module, which is why the manual `modprobe -r` above was still required.

---

## Task 4: A stable udev name for the new telemetry disk

**Reasoning:** Kernel-assigned device letters (`/dev/vdb`, `/dev/vdc`) are assigned purely in discovery order and can shift on the next boot. The fix is a udev rule that matches on something the device itself carries — a serial number — rather than the slot the kernel happened to give it this time.

**Find the disk and its stable attribute:**

```bash
lsblk
udevadm info --attribute-walk --name=/dev/vdX
```

Look for `ATTRS{serial}=="..."` in the output — that's the attribute the rule below will match against. (If you're working from `/dev/disk/by-id/`, the serial is usually right there in the symlink name too.)

**Write the rule:**

```bash
# /etc/udev/rules.d/99-telemetry-disk.rules
SUBSYSTEM=="block", ATTRS{serial}=="<the-serial-you-found>", SYMLINK+="telemetry-disk"
```

```bash
echo 'SUBSYSTEM=="block", ATTRS{serial}=="<the-serial-you-found>", SYMLINK+="telemetry-disk"' | sudo tee /etc/udev/rules.d/99-telemetry-disk.rules
```

**Apply it live, without rebooting — both steps are required:**

```bash
sudo udevadm control --reload-rules
sudo udevadm trigger --subsystem-match=block
```

`--reload-rules` only tells the running `udevd` to re-read rule files from disk; it does not, by itself, re-evaluate hardware that's already attached. Skipping `udevadm trigger` is the single most common way this task silently fails to apply.

**Verify:**

```bash
ls -l /dev/telemetry-disk
# lrwxrwxrwx ... /dev/telemetry-disk -> vdX
```

---

## Task 5: Diagnose and terminate the hung telemetry-agent

**Reasoning:** A process showing zero CPU usage and no output isn't necessarily "doing nothing" — it may be legitimately blocked inside a syscall, waiting on something that will never arrive. `strace -p` lets you attach and see exactly which syscall it's sitting in, turning a guess into hard evidence before you act.

**Find the PID:**

```bash
pgrep -a -f telemetry-agent
```

**Attach and observe:**

```bash
sudo strace -p <PID>
```

Watch the output: rather than a fast-scrolling torrent of unrelated syscalls, you'll see the process sitting inside repeated `pause()` calls — the syscall that blocks a process indefinitely until a signal arrives. A process parked in `pause()` with no timer, no external event, and no signal ever coming is the textbook definition of genuinely hung, not just slow or quiet between bursts of real work.

**Terminate it:**

```bash
sudo kill <PID>
sleep 2
ps -p <PID>
```

If it's still present after a `SIGTERM`, escalate:

```bash
sudo kill -9 <PID>
```

**Verify:**

```bash
pgrep -f telemetry-agent
# (no output)
```

---

## Command Summary

```bash
# 1. Audit
sudo mkdir -p /opt/course/audit
uname -r | sudo tee /opt/course/audit/kernel-release > /dev/null
sysctl -n vm.swappiness | sudo tee /opt/course/audit/vm-swappiness > /dev/null

# 2. pid_max
sudo sysctl -w kernel.pid_max=1048576
echo "kernel.pid_max = 1048576" | sudo tee /etc/sysctl.d/99-pid-max.conf
sudo sysctl --system

# 3. Kernel modules
sudo modprobe dummy numdummies=4
echo "dummy" | sudo tee /etc/modules-load.d/dummy.conf
echo "options dummy numdummies=4" | sudo tee /etc/modprobe.d/dummy.conf

echo "blacklist pcspkr" | sudo tee /etc/modprobe.d/blacklist-pcspkr.conf
sudo modprobe -r pcspkr
sudo udevadm trigger

# 4. udev
lsblk
udevadm info --attribute-walk --name=/dev/vdX
echo 'SUBSYSTEM=="block", ATTRS{serial}=="<serial>", SYMLINK+="telemetry-disk"' | sudo tee /etc/udev/rules.d/99-telemetry-disk.rules
sudo udevadm control --reload-rules
sudo udevadm trigger --subsystem-match=block

# 5. strace + kill
pgrep -a -f telemetry-agent
sudo strace -p <PID>
sudo kill <PID>
```

Once verified, run the local validation suite to pass the lab!
