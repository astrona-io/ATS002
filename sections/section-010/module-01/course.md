# Chapter 1: Reading and Reshaping the Live Kernel with sysctl

Imagine the Linux kernel as a massive control room, humming quietly in the basement of every server you administer. Thousands of dials and switches line the walls — some govern how aggressively the system swaps memory, some decide whether the box forwards network packets between interfaces, others control esoteric scheduling behavior nobody touches from one decade to the next. Every one of those dials has a current position, and every one of those dials is readable, and often writable, while the system is running.

That control room has a name: `/proc/sys`. And the friendliest way to walk in and read or turn those dials is a tool called `sysctl`.

In this chapter we will learn to read the kernel's live state precisely — kernel release, network parameters, timezone — and then go one step further into a distinction that trips up almost every new administrator at least once: the difference between turning a dial that resets itself the instant the machine reboots, and turning a dial that stays exactly where you left it forever.

---

## Part I: Asking the Kernel What It Is

Before you can report on a system, you need to know what it actually is. The `uname` command is your primary tool for asking the currently running kernel to identify itself:

```bash
uname -r
```

```text
6.8.0-45-generic
```

That single flag, `-r`, asks specifically for the **release** — the version string associated with this exact kernel build. It's tempting to reach for `uname -a` instead and eyeball the output, mentally slicing out the field you want with your own two eyes. Resist that temptation. `uname -a` prints hostname, release, version, machine architecture, and operating system name all jammed onto one line, and it is disturbingly easy under exam pressure to grab the wrong whitespace-delimited chunk — especially since `uname -v` reports something that *sounds* like what you want (the kernel "version") but is actually a build timestamp, not the release string a grader is checking for. When in doubt, run `man uname` — it lays out every single-letter flag side by side, and confirming `-r` really means "release" takes ten seconds and eliminates the ambiguity entirely.

If a task asks you to record the kernel release into a file, redirect the output directly rather than parsing anything:

```bash
uname -r > /opt/course/1/kernel
```

One detail here catches almost everyone at least once: shell redirection (`>`) will happily create the *file* named at the end of a path, but it will never create the *directories* leading up to it. If `/opt/course/1` doesn't already exist, that command fails with `No such file or directory`, and the failure can look confusingly like nothing happened at all. Always `mkdir -p` the destination directory first:

```bash
mkdir -p /opt/course/1
uname -r > /opt/course/1/kernel
```

---

## Part II: Reading a Live Kernel Parameter Two Ways

Now let's turn to one of those dials in the control room. A classic example is `net.ipv4.ip_forward` — the switch that decides whether this machine will forward IP packets between network interfaces, turning it from an ordinary host into a router.

The friendly way to read it is `sysctl`:

```bash
sysctl net.ipv4.ip_forward
```

```text
net.ipv4.ip_forward = 0
```

Notice the output includes the parameter's full name and an `=` sign — helpful for a human eyeballing a terminal, but a nuisance if you need to pipe that value into a file that's supposed to hold *just* the number. That's exactly what the `-n` flag is for. Check `man sysctl` and you'll find it documented plainly under `OPTIONS`: it disables printing of the key, leaving you with the bare value only.

```bash
sysctl -n net.ipv4.ip_forward > /opt/course/1/ip_forward
```

Here's the part worth sitting with for a moment: every dotted sysctl name maps directly onto a path under `/proc/sys`, with each dot becoming a `/`. `net.ipv4.ip_forward` is nothing more than a friendly alias for the file `/proc/sys/net/ipv4/ip_forward`. `man 5 proc` documents this convention directly. That means there is a second, completely equivalent way to read the exact same live value:

```bash
cat /proc/sys/net/ipv4/ip_forward > /opt/course/1/ip_forward
```

Both commands ask the kernel the identical question and get the identical answer, because `sysctl` really is just a friendlier face bolted onto the same `/proc/sys` filesystem. Knowing both matters in practice: some minimal or heavily-stripped environments ship without the `sysctl` binary at all, but as long as `procfs` is mounted (which it always is on a normal Linux system), `/proc/sys` is there waiting for you.

One more thing worth internalizing: this reads the kernel's *current, in-memory* state — not whatever some config file on disk claims the value should be. If someone changed this value earlier in the session without saving it anywhere permanent, `sysctl -n` still faithfully reports whatever the kernel is actually doing right now, because it asks the kernel directly rather than consulting a file.

---

## Part III: Reading the System's Timezone

Timezone configuration lives in a slightly different neighborhood, but the same instinct applies: prefer the tool that gives you a single, clean, script-friendly value.

```bash
timedatectl show --property=Timezone --value > /opt/course/1/timezone
```

```text
UTC
```

`timedatectl show` with `--property=Timezone --value` asks systemd's time management service for exactly one field, with no label attached — far more reliable for scripting than grepping the human-oriented output of a bare `timedatectl` call.

On Debian and Ubuntu systems there's also a flat file, `/etc/timezone`, that records the same information:

```bash
cat /etc/timezone > /opt/course/1/timezone
```

Both should agree, because `/etc/localtime` is a symlink pointing into `/usr/share/zoneinfo/<zone>`, and both tools ultimately resolve against that same symlink. They *can* drift apart if someone hand-edits `/etc/localtime` directly without going through `timedatectl` — a good reason to prefer `timedatectl` when it's available, since it's the tool actually managing that symlink. It's also worth knowing that `/etc/timezone` is a Debian/Ubuntu convention specifically; RHEL and openSUSE-family systems may not have that file at all, which is another point in favor of `timedatectl` as the more portable choice.

---

## Part IV: The Dial That Forgets — Non-Persistent Changes

Now we arrive at the distinction the exam objective is actually built around: **"persistent and non-persistent"** kernel parameters.

Suppose you want this machine to start forwarding packets right now:

```bash
sudo sysctl -w net.ipv4.ip_forward=1
```

This works immediately. Run `sysctl -n net.ipv4.ip_forward` again and you'll see `1`. But look closely at what actually happened: `sysctl -w` pokes the *live, in-memory* kernel value through `/proc/sys` — and nothing else. No file on disk changed. No configuration was recorded anywhere. The instant this machine reboots, the kernel starts fresh, reads whatever its persistent configuration says (or falls back to its compiled-in default if nothing overrides it), and your change is gone as if it never happened.

Think of `sysctl -w` as scribbling on a whiteboard. It's visible right now, it's completely real right now — but nobody has photographed it, and the cleaning crew wipes the board clean every night.

---

## Part V: The Dial That Remembers — Persistent Changes

To make a change survive a reboot, you need to write it into a file the kernel's startup process actually reads. That location is `/etc/sysctl.d/`:

```bash
echo "net.ipv4.ip_forward = 1" | sudo tee /etc/sysctl.d/99-ip-forward.conf
sudo sysctl --system
```

The first command drops a config file with the setting written in `key = value` form. The second, `sysctl --system`, is the command that ties everything together: it reads every `*.conf` file under `/etc/sysctl.d/`, `/run/sysctl.d/`, and `/usr/lib/sysctl.d/` (plus the legacy `/etc/sysctl.conf`) in a defined precedence order, and applies all of them to the running kernel in one pass. That single command gives you both halves at once — the value takes effect immediately, *and* it will be re-applied automatically on every future boot, because the same startup process runs `sysctl --system`-equivalent logic before your applications ever start.

If you're naming these drop-in files, `man 5 sysctl.d` is worth a glance — it explains that files are read in lexical order, and if the same key appears in two different files, the one that sorts later wins. That's why you'll see conventional numeric prefixes like `99-` on filenames meant to take priority: it's a simple, readable way to control which file wins a conflict.

---

## Self-Check and Verification

Before moving on to the hands-on lab, make sure you can answer these without looking back:

1. **Release vs. version**: Which `uname` flag gives you the kernel *release* string, and why is `uname -a` risky for scripted extraction? *(Answer: `-r`; `uname -a` mixes multiple fields on one line and invites picking the wrong one.)*
2. **Name-to-path mapping**: What file does `net.ipv4.ip_forward` correspond to under `/proc/sys`? *(Answer: `/proc/sys/net/ipv4/ip_forward` — dots become slashes.)*
3. **The persistence test**: If you run `sysctl -w kernel.something=1` and then immediately reboot, what value will the kernel have for that parameter afterward? *(Answer: whatever `/etc/sysctl.d/` or the compiled default says — the `-w` change is gone.)*
4. **Making it stick**: What two things do you need to do to make a sysctl change both immediate and reboot-proof? *(Answer: write it into a file under `/etc/sysctl.d/*.conf`, then run `sysctl --system`.)*

You now have the complete read/write/persist model that every other kernel-tuning topic in this section builds on — process limits, kernel modules, and udev rules all follow the exact same "live value vs. persistent config file" pattern you just learned here. Head to the lab and put it into practice.
