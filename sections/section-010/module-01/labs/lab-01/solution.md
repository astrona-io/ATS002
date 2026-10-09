# Solution

Three answer files, three clean values. Each step below gives the reasoning, the command, and a check that reads the file back. The folder `/opt/course` already exists and belongs to you, so no `sudo` is needed for the answer files.

## Task 1: Write the Linux kernel release into /opt/course/kernel

**Reasoning:** `uname -r` prints the release, for example `6.8.0-45-generic`. `uname -v` prints the build banner with a build date instead. They answer different questions, and the grader checks for the release. If you are unsure, check `man uname` first. It lists every single-letter option (`-s`, `-n`, `-r`, `-v`, `-m`, `-a`) side by side, so you can confirm in seconds that `-r` means "kernel release".

**Command:**

```bash
uname -r > /opt/course/kernel
```

Use `-r` itself rather than cutting a piece out of the full `uname -a` line with `awk` or `cut`. That line also holds the host name, the build date and the hardware type, and it is easy to grab the wrong piece.

**Verify:**

```bash
cat /opt/course/kernel
# 6.8.0-45-generic
```

Your release string depends on the image. It must match what `uname -r` prints on this machine.

---

## Task 2: Write the current value of ip_forward into /opt/course/ip_forward

**Reasoning:** `man sysctl` describes `-n` as the option that stops `sysctl` from printing the key name. That gives you the bare value instead of `net.ipv4.ip_forward = 0`. Every dot in a sysctl name becomes a `/` in the `/proc/sys` path, so `net.ipv4.ip_forward` is the file `/proc/sys/net/ipv4/ip_forward`. `sysctl -n` and reading that file ask the kernel exactly the same question.

**Command:**

```bash
sysctl -n net.ipv4.ip_forward > /opt/course/ip_forward
```

This reads the kernel's *current value in memory*, not what a configuration file says. If someone ran `sysctl -w net.ipv4.ip_forward=1` earlier without saving it, this command still reports `1`, because it asks the kernel directly.

**The same read through `/proc`** (useful when the `sysctl` command is not installed but `/proc` is mounted):

```bash
cat /proc/sys/net/ipv4/ip_forward > /opt/course/ip_forward
```

**Verify:**

```bash
cat /opt/course/ip_forward
# 0

# cross-check the live value matches what /proc reports
diff <(sysctl -n net.ipv4.ip_forward) <(cat /proc/sys/net/ipv4/ip_forward)
# (no output = identical)
```

Note: the `0` above is the value on a fresh machine. On this lab machine the setup has already turned forwarding on (in `/etc/sysctl.d/99-ip-forward.conf`), so your file should say `1`. That is exactly the value the grader expects.

---

## Task 3: Write the system timezone into /opt/course/timezone

**Reasoning:** `timedatectl show --property=Timezone --value` reads the timezone that systemd manages. `/etc/timezone` is the plain-file record that Debian and Ubuntu keep. Both normally agree, because `/etc/localtime` is a symbolic link into `/usr/share/zoneinfo/<zone>` and both follow it. They can drift apart if someone edits `/etc/localtime` by hand without `timedatectl`. RHEL-family and openSUSE systems may have no `/etc/timezone` at all, so `timedatectl` is the choice that works everywhere systemd runs.

**Command:**

```bash
timedatectl show --property=Timezone --value > /opt/course/timezone
```

`--property=Timezone --value` asks for exactly one field with no label. That is easier for a script than searching the human-friendly `timedatectl` screen.

**Fallback** (small containers without the systemd tools):

```bash
cat /etc/timezone > /opt/course/timezone
```

**Verify:**

```bash
cat /opt/course/timezone
# UTC
```

---

## Send it for grading

From your own computer (not inside the lab machine), run:

```sh
astrona submit -c sections/section-010/module-01/labs/lab-01
```

If a check fails, its message names the file and shows the value it found and the value it expected. Fix that one file, read it back with `cat`, and submit again.

---

## Bonus (persistence): making ip_forward survive a reboot

The task only asks you to *read* `ip_forward`. The exam objective, though, is "persistent and non-persistent" kernel parameters, so it pays to know both directions.

`sysctl -w` changes only the live value in memory, through `/proc/sys`. Nothing on disk changes, so a reboot brings back whatever the files (or the kernel's built-in default) say:

```bash
sysctl -w net.ipv4.ip_forward=1
```

To make it stick, put the setting in a file under `/etc/sysctl.d/` and apply it. Run both steps as `root`.

Save this as `/etc/sysctl.d/99-ip-forward.conf`:

```ini
net.ipv4.ip_forward = 1
```

Apply it:

```sh
sysctl --system
```

Check `man 5 sysctl.d` for the order rules before you name such a file. Files are read in alphabetical order of their names across `/etc/sysctl.d/`, `/run/sysctl.d/` and `/usr/lib/sysctl.d/`. A number in front, such as `99-`, is the usual way to make a file win when two files set the same key.

`sysctl --system` reads `/etc/sysctl.d/*.conf`, `/run/sysctl.d/*.conf` and `/etc/sysctl.conf` in a fixed order and applies all of them to the live kernel in one pass. So the file takes effect at once *and* survives the next reboot.

---

## Command Summary

```bash
mkdir -p /opt/course
uname -r > /opt/course/kernel
sysctl -n net.ipv4.ip_forward > /opt/course/ip_forward
timedatectl show --property=Timezone --value > /opt/course/timezone
```

The persistence example (`sysctl -w`, the `99-ip-forward.conf` file and `sysctl --system`) is in the bonus step above. The task does not need it.
