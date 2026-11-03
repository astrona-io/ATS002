# Solution Walkthrough

Five separate incident items, five separate fixes. None of them depends on another, but work through them in the order they were reported.

---

## Task 1: Record the live kernel state

**Why:** Before you touch any configuration, record what the machine looks like right now. `uname -r` gives the running kernel's release string. (`uname -v` gives the build date, not the release.) `sysctl -n` gives the bare value of a kernel parameter, with no name and no `=` sign. That is exactly what an audit file for scripts needs.

**Commands:**

```bash
sudo mkdir -p /opt/course/audit

uname -r > /tmp/kernel-release && sudo mv /tmp/kernel-release /opt/course/audit/kernel-release
sysctl -n vm.swappiness > /tmp/vm-swappiness && sudo mv /tmp/vm-swappiness /opt/course/audit/vm-swappiness
```

If your user can write to `/opt/course/audit`, you can redirect straight into the files. `uname -r | sudo tee /opt/course/audit/kernel-release > /dev/null` works too.

**Check:**

```bash
cat /opt/course/audit/kernel-release
cat /opt/course/audit/vm-swappiness
sysctl -n vm.swappiness   # cross-check: should match the file exactly
```

---

## Task 2: Raise the `pid_max` limit

**Why:** `kernel.pid_max` sets the size of the whole system's shared pool of process and thread ID numbers: the number of crew badges the ship can print. A `sysctl -w` change alone only turns the live dial in memory. Nothing on disk changes, so the value goes back at the next reboot. To keep it, write a drop-in file under `/etc/sysctl.d/` and apply it with `sysctl --system`.

**Commands:**

Turn the live value up now:

```bash
sudo sysctl -w kernel.pid_max=1048576
```

Save this as `/etc/sysctl.d/99-pid-max.conf`:

```ini
kernel.pid_max = 1048576
```

Apply it:

```sh
sudo sysctl --system
```

The number at the front of the file name, `99-`, puts this file late in the order in which `sysctl --system` reads `/etc/sysctl.d/`. So it wins even if the machine already has a lower value in a file that sorts earlier.

**Check:**

```bash
sysctl -n kernel.pid_max
# 1048576

cat /etc/sysctl.d/99-pid-max.conf
```

---

## Task 3: Kernel modules: load and persist `dummy`, blacklist `pcspkr`

**Why:** These are two separate module jobs, and the persistent half of each uses a different family of configuration files. `/etc/modules-load.d/` answers "should this module load at boot?". `/etc/modprobe.d/` answers "with which parameters?" and, separately, "may it ever load automatically?".

**Check the parameters before loading:**

```bash
modinfo -p dummy
```

**Load `dummy` now with the parameter:**

```bash
sudo modprobe dummy numdummies=4
lsmod | grep dummy
cat /sys/module/dummy/parameters/numdummies
# 4
```

**Persist the load and the parameter:**

Save this as `/etc/modules-load.d/dummy.conf`:

```ini
dummy
```

Save this as `/etc/modprobe.d/dummy.conf`:

```ini
options dummy numdummies=4
```

Apply it, and prove that the configuration file, not the earlier command, now sets the value. Unload the module and load it again with no parameter:

```bash
sudo modprobe -r dummy
sudo modprobe dummy
cat /sys/module/dummy/parameters/numdummies
# 4
```

`systemd-modules-load` reads `/etc/modules-load.d/` at every boot and loads `dummy`, and `modprobe` adds the `options` line from `/etc/modprobe.d/` each time it loads the module.

**Blacklist and unload `pcspkr`:**

Save this as `/etc/modprobe.d/blacklist-pcspkr.conf`:

```ini
blacklist pcspkr
```

Apply it by unloading the module that is loaded now:

```bash
sudo modprobe -r pcspkr
```

**Then check that the blacklist holds during a simulated hardware detection pass:**

```bash
sudo udevadm trigger
lsmod | grep pcspkr
# (no output)
```

A blacklist entry only blocks the *automatic* load that hardware detection starts. It does not stop an explicit `sudo modprobe pcspkr`, and it does not unload a module that is already loaded. That is why the `modprobe -r` above was still needed.

---

## Task 4: A stable udev name for the new telemetry disk

**Why:** The kernel hands out device letters (`/dev/vdb`, `/dev/vdc`) in the order it finds the disks, so a letter can change at the next boot. The fix is a udev rule that matches something the disk itself carries, its serial number, instead of the letter it happened to get this time. udev is the dock master who names each arriving cargo bay, and the rule is its rule card.

**Find the disk and its stable attribute:**

```bash
lsblk
udevadm info --attribute-walk --name=/dev/vdX
```

Replace `vdX` with the new disk's name from `lsblk`. Look for `ATTRS{serial}=="..."` in the output: that is the attribute the rule matches. If you look in `/dev/disk/by-id/` instead, the serial is usually part of the link name there too.

**Write the rule:**

Save this as `/etc/udev/rules.d/99-telemetry-disk.rules`, with the serial you found in place of `<the-serial-you-found>`:

```bash
SUBSYSTEM=="block", ATTRS{serial}=="<the-serial-you-found>", SYMLINK+="telemetry-disk"
```

**Apply it now, without rebooting. Both steps are needed:**

```bash
sudo udevadm control --reload-rules
sudo udevadm trigger --subsystem-match=block
```

`--reload-rules` only tells the running `udevd` to read the rule files from disk again. It does not, on its own, check disks that are already attached. Skipping `udevadm trigger` is the most common way this task quietly fails.

**Then check the result:**

```bash
ls -l /dev/telemetry-disk
# lrwxrwxrwx ... /dev/telemetry-disk -> vdX
```

---

## Task 5: Diagnose and stop the hung `telemetry-agent`

**Why:** A process with zero CPU use and no output is not always "doing nothing". It may be blocked inside a system call, waiting for something that will never arrive. `strace -p` is a flight recorder you clip onto one crew member: it attaches to the process and shows exactly which system call it is sitting in. That turns a guess into hard evidence before you act.

**Find the process ID:**

```bash
pgrep -a -f telemetry-agent
```

**Attach and watch:**

```bash
sudo strace -p <PID>
```

Watch the output. Instead of a fast stream of different system calls, you see the process sitting in repeated `pause()` calls. `pause()` blocks a process until a signal arrives. A process parked in `pause()`, with no timer, no outside event and no signal on the way, is really hung, not just slow or quiet between bursts of work. Press `Ctrl+C` to detach `strace`.

**Stop it:**

```bash
sudo kill <PID>
sleep 2
ps -p <PID>
```

`kill` sends `SIGTERM` ("finish up and leave"). If the process is still there after that, send `SIGKILL` ("out of the airlock now"):

```bash
sudo kill -9 <PID>
```

**Check:**

```bash
pgrep -f telemetry-agent
# (no output)
```

The unit has no `Restart=` setting, so `systemd` does not start the agent again.

---

## Checklist

Before you submit, check every item:

| Task | What must be true | Check |
| --- | --- | --- |
| 1 | `/opt/course/audit/kernel-release` and `/opt/course/audit/vm-swappiness` match the live values | `cat` both files, compare with `uname -r` and `sysctl -n vm.swappiness` |
| 2 | `kernel.pid_max` is at least `1048576` live and in `/etc/sysctl.d/99-pid-max.conf` | `sysctl -n kernel.pid_max` |
| 3 | `dummy` loaded with `numdummies=4`; `/etc/modules-load.d/dummy.conf` and `/etc/modprobe.d/dummy.conf` exist; `pcspkr` blacklisted in `/etc/modprobe.d/blacklist-pcspkr.conf` and not loaded | `cat /sys/module/dummy/parameters/numdummies`, `lsmod \| grep pcspkr` after `sudo udevadm trigger` |
| 4 | `/etc/udev/rules.d/99-telemetry-disk.rules` exists and `/dev/telemetry-disk` points at the disk with that serial | `ls -l /dev/telemetry-disk` |
| 5 | No `telemetry-agent` process is running | `pgrep -f telemetry-agent` |

When everything is in place, send it for grading:

```sh
astrona submit -c sections/section-010/capstone/labs/lab-01
```
