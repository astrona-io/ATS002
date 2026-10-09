# Reading The Live Value

Astronaut, a gauge on the reactor panel shows what the reactor is doing right now. A page in the ship's manual only says what it *should* be doing. This part teaches you to read the gauge, not the manual, and to write just the value into a file, with nothing around it.

You will also use the same "one clean field" habit for a setting that is not a kernel parameter at all: the system timezone.

## `-n` gives the bare value

By default `sysctl` prints `net.ipv4.ip_forward = 0`. That form is for a person reading a terminal. If a file must hold *only* the number, the name and the ` = ` are junk in it. The option `-n` (long form `--values`) prints the value without the name.

<!-- astrona:playground:renew -->

The commands below write into `/opt/course/1/`. `/opt` belongs to `root`, so if that folder does not exist yet, create it with `sudo mkdir -p /opt/course/1` and make it yours with `sudo chown $USER /opt/course/1`.

```bash
sysctl -n net.ipv4.ip_forward > /opt/course/1/ip_forward   # -> "0\n"
```

Reading the `/proc/sys` file directly also gives the bare value, with no option needed:

```bash
cat /proc/sys/net/ipv4/ip_forward > /opt/course/1/ip_forward
```

Both forms are worth knowing. A small container or rescue image may not have the `procps` package, so there is no `sysctl` command at all. On a running Linux system `/proc` is always mounted, so the `/proc/sys` path still works.

## "Live" means in memory, not what a file says

This is the most important property of a read: **`sysctl -n` reports the kernel's current value in memory. It asks the kernel. It does not read any configuration file.**

Here is an example. Someone ran `sysctl -w net.ipv4.ip_forward=1` earlier and saved it nowhere. `sysctl -n` still returns `1`, because that is what the kernel is doing right now. Configuration files under `/etc` only describe what the value should be at the next start. A read never looks at them.

### Try it: a read reports the kernel, not a file

On your playground, search the configuration folders for the setting, then change it live with `sudo sysctl -w` and read it again. `sysctl -w` turns a dial by hand: the kernel changes the value at once, and no file is written.

```bash
grep -rs ip_forward /etc/sysctl.conf /etc/sysctl.d/ /usr/lib/sysctl.d/ || echo '(no config file mentions it)'
sudo sysctl -w net.ipv4.ip_forward=1
sysctl -n net.ipv4.ip_forward
```

Expect something like:

```text
(no config file mentions it)
net.ipv4.ip_forward = 1
1
```

No file on disk says `ip_forward = 1`, yet `sysctl -n` returns `1`. It asked the running kernel, which you just changed. Set it back with `sudo sysctl -w net.ipv4.ip_forward=0` before you go on.

## The same habit for the timezone

The timezone is not a kernel parameter, but the same habit works: ask for the one clean field a script can use. The tool is `timedatectl`, which talks to the `systemd-timedated` service.

### Ask `timedatectl` for one field

This command asks for exactly one field and drops the `Timezone=` label:

```bash
timedatectl show --property=Timezone --value > /opt/course/1/timezone
```

```text
UTC
```

`timedatectl show` asks `systemd-timedated` over D-Bus, the message bus that services on the machine use to talk to each other. `--property=Timezone --value` returns only the zone name. That is safer for a script than searching the human-friendly `timedatectl` screen with `grep`.

### What sits underneath

Underneath, the timezone is a link between files. `/etc/localtime` is a symbolic link (a shortcut) into `/usr/share/zoneinfo/<Area>/<City>`, and every program that cares about time follows it. On Debian and Ubuntu a plain file, `/etc/timezone`, also records the zone name:

```bash
cat /etc/timezone > /opt/course/1/timezone     # Debian/Ubuntu only
```

The two can disagree if someone re-points `/etc/localtime` by hand without `timedatectl`. RHEL-family systems and openSUSE have no `/etc/timezone` at all. That makes `timedatectl` the choice that works everywhere systemd runs.

## Common pitfalls

> [!WARNING]
> - **Redirecting the default `key = value` output** into a file that must hold only a number. Use `sysctl -n`, or `cat` the `/proc/sys` path.
> - **Reading a configuration file to learn the current value.** `/etc/sysctl.d/*.conf` says what *should* happen at the next start, not what is happening now. Only `sysctl -n <key>` (or the `/proc/sys` file) tells you what the kernel is doing.
> - **Assuming `/etc/timezone` exists.** Only Debian and Ubuntu have it. `timedatectl show --value` works everywhere systemd runs.

## Your mission: sysctl Live Kernel State Lab

You can now name the running kernel, read a live kernel value without extra text, and read the timezone as one clean field. The mission asks you to write all three into answer files on a fresh training ship, where one dial has already been changed for you.

The mission runs on its own training ship. Your playground cannot be paused, so remove it first. It always starts clean, so you lose nothing you need:

```sh
astrona destroy sysctl-live-kernel
```

Then start the mission and open a terminal on it:

```sh
astrona run --git git@github.com:astrona-io/ATS002.git -c sections/section-010/module-01/labs/lab-01
astrona ssh ats-002-lab-011
```

Read the task in [`question.md`](./labs/lab-01/question.md) and solve it on your own first. When you think you are done, send it for grading:

```sh
astrona submit -c sections/section-010/module-01/labs/lab-01
```

When the mission is done, remove it and start your playground again:

```sh
astrona destroy ats-002-lab-011
astrona run --git git@github.com:astrona-io/ATS002.git -c sections/section-010/module-01/playground
```
