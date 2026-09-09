# Solution

## Task 1: Write the Linux Kernel release into /opt/course/kernel

**Reasoning:** `uname -r` prints the release (e.g. `6.8.0-45-generic`); `uname -v` prints the build timestamp/metadata instead — these answer different questions and graders check for the release specifically. Check `man uname` first — it lists every single-letter flag (`-s`, `-n`, `-r`, `-v`, `-m`, `-a`) side by side, the fastest way to confirm `-r` really is "kernel release" and not "kernel version" under exam pressure.

**Command:**

```bash
uname -r > /opt/course/kernel
```

Using `-r` specifically (rather than parsing the full `uname -a` line with `awk`/`cut`) avoids any ambiguity about which whitespace-delimited field is the "release" versus the hostname, build date, or architecture — all of which also appear in the unfiltered line.

**Verify:**

```bash
cat /opt/course/kernel
# 6.8.0-45-generic
```

---

## Task 2: Write the current value of ip_forward into /opt/course/ip_forward

**Reasoning:** `man sysctl` documents `-n` under OPTIONS as "use this option to disable printing of the key when printing values" — that's the exact flag that gives a bare value instead of `net.ipv4.ip_forward = 0`. Every dot in a sysctl name becomes a `/` in the `/proc/sys` path (see `man 5 proc`), so `net.ipv4.ip_forward` is `/proc/sys/net/ipv4/ip_forward` — `sysctl -n` and reading that path directly are two ways of asking the kernel the exact same question.

**Command:**

```bash
sysctl -n net.ipv4.ip_forward > /opt/course/ip_forward
```

This reads the kernel's *current in-memory* state, not whatever a config file says — if someone ran `sysctl -w net.ipv4.ip_forward=1` earlier in the session without persisting it, this command still correctly reports `1` because it asks the kernel directly.

**Equivalent /proc read** (useful when the `sysctl` binary isn't installed but `procfs` is mounted):

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

---

## Task 3: Write the system timezone into /opt/course/timezone

**Reasoning:** `timedatectl show --property=Timezone --value` reads the systemd-managed timezone; `/etc/timezone` is the flat-file record used on Debian/Ubuntu. Both should agree because `/etc/localtime` is a symlink into `/usr/share/zoneinfo/<zone>` that both tools resolve against — but on a system where someone hand-edited `/etc/localtime` without going through `timedatectl`, they can drift. On RHEL/openSUSE-family systems `/etc/timezone` may not exist at all, so `timedatectl` is the more portable choice when available.

**Command:**

```bash
timedatectl show --property=Timezone --value > /opt/course/timezone
```

`--property=Timezone --value` asks for exactly one field with no label, more script-friendly than grepping human-formatted `timedatectl` output.

**Fallback** (minimal containers without systemd tooling):

```bash
cat /etc/timezone > /opt/course/timezone
```

**Verify:**

```bash
cat /opt/course/timezone
# UTC
```

---

## Bonus (persistence teaching point): making ip_forward survive a reboot

The scenario only asks you to *read* `ip_forward`, but the exam objective is "persistent and non-persistent" kernel parameters, so understand both directions.

`sysctl -w` only pokes the live kernel value in memory via `/proc/sys` — nothing on disk changes, so a reboot reverts to whatever the persistent config (or kernel default) says:

```bash
sysctl -w net.ipv4.ip_forward=1
```

To make it stick, drop a file under `/etc/sysctl.d/` and apply it:

```bash
echo "net.ipv4.ip_forward = 1" > /etc/sysctl.d/99-ip-forward.conf
sysctl --system
```

Check `man 5 sysctl.d` for precedence rules before naming this file — files are read in lexical order across `/etc/sysctl.d/`, `/run/sysctl.d/`, and `/usr/lib/sysctl.d/`, and a numeric prefix like `99-` is the conventional way to force a file to win when the same key appears twice.

`sysctl --system` reads `/etc/sysctl.d/*.conf`, `/run/sysctl.d/*.conf`, and `/etc/sysctl.conf` in a defined precedence order and applies all of them to the live kernel in one pass — so the file takes effect immediately *and* survives the next reboot.

---

## Command Summary

```bash
mkdir -p /opt/course
uname -r > /opt/course/kernel
sysctl -n net.ipv4.ip_forward > /opt/course/ip_forward
timedatectl show --property=Timezone --value > /opt/course/timezone

# persistence example (not required by the scenario, but the deeper skill)
sysctl -w net.ipv4.ip_forward=1
echo "net.ipv4.ip_forward = 1" > /etc/sysctl.d/99-ip-forward.conf
sysctl --system
```