# Part 2 — /proc/sys and the live value

> Prerequisite: [Part 1 — Identifying the running kernel](./course-01-identifying-the-running-kernel.md). Next: [Part 3 — Runtime vs. persistent changes](./course-03-runtime-vs-persistent-changes.md).

`sysctl` looks like a program that has settings. It is not — it is a thin reader/writer over a filesystem the kernel exposes. Once you see the mapping, every `sysctl` command becomes predictable, you can do the same thing with `cat` when `sysctl` is missing, and you understand exactly what "the live value" means versus what a config file claims.

## Every sysctl name is a path under /proc/sys

Concrete: read whether this host forwards IP packets between interfaces.

```bash
# shell: any host, unprivileged
sysctl net.ipv4.ip_forward
```

```text
net.ipv4.ip_forward = 0
```

`procfs`, mounted at `/proc`, is a virtual filesystem: its "files" are not on disk, they are function calls into the kernel dressed up as files. The subtree `/proc/sys/` is the **sysctl tree** — one file per tunable. The name-to-path rule is mechanical: **replace each `.` with `/` and prepend `/proc/sys/`**.

```
  net.ipv4.ip_forward
   │   │    │
   ▼   ▼    ▼
  /proc/sys/net/ipv4/ip_forward
```

So this reads the identical value:

```bash
cat /proc/sys/net/ipv4/ip_forward
```

```text
0
```

`sysctl` is doing exactly that `open`/`read` under the hood, plus formatting. The top-level directories group the tunables by area: `kernel/` (identity, `pid_max`, `panic`), `net/` (per-protocol, per-interface networking), `vm/` (paging, `swappiness`, overcommit), `fs/` (`file-max`, inotify), `dev/`. `sysctl -a` dumps the whole tree; `sysctl -a --pattern 'net.ipv4.conf.*'` filters it.

> [!TIP]
> **Try it — the name and the path are the same file.** On the playground host:
>
> ```bash
> sysctl net.ipv4.ip_forward
> cat /proc/sys/net/ipv4/ip_forward
> sysctl -n net.ipv4.ip_forward
> ```
>
> Expect something like:
>
> ```text
> net.ipv4.ip_forward = 0
> 0
> 0
> ```
>
> Line 1 is the human form (`key = value`); lines 2 and 3 are the bare value — one via the procfs path, one via `sysctl -n`. All three asked the kernel the same question. The bare forms are what you redirect into a file.

## `-n` gives the bare value; the default gives `key = value`

The default output — `net.ipv4.ip_forward = 0` — is for a human reading a terminal. Pipe it into a file that is supposed to hold *just* the number and the ` = ` is garbage. `-n` (`--values`) prints the value with no key:

```bash
sysctl -n net.ipv4.ip_forward > /opt/course/1/ip_forward   # -> "0\n"
```

Reading the procfs file directly gives you the bare value with no flag needed — another reason to know both forms:

```bash
cat /proc/sys/net/ipv4/ip_forward > /opt/course/1/ip_forward
```

On a minimal container or rescue image with no `procps` package there is no `sysctl` binary at all, but as long as `/proc` is mounted (always, on a running Linux system) the `/proc/sys` path works.

## "Live" means in-memory — not what a file says

The single most important property: **`sysctl -n` reports the kernel's current in-memory value, obtained by asking the kernel, not by reading a config file.** If someone ran `sysctl -w net.ipv4.ip_forward=1` earlier in the session and saved it nowhere, `sysctl -n` still returns `1`, because that is what the kernel is actually doing right now. Config files under `/etc` describe what the value *should* be set to at boot; they are not consulted on a read. Part 3 is entirely about that gap.

> [!TIP]
> **Try it — read reports the kernel, not a file.** On the host:
>
> ```bash
> grep -rs ip_forward /etc/sysctl.conf /etc/sysctl.d/ /usr/lib/sysctl.d/ || echo '(no config file mentions it)'
> sudo sysctl -w net.ipv4.ip_forward=1
> sysctl -n net.ipv4.ip_forward
> ```
>
> Expect something like:
>
> ```text
> (no config file mentions it)
> net.ipv4.ip_forward = 1
> 1
> ```
>
> No file on disk says `ip_forward = 1`, yet `sysctl -n` returns `1` — because it asked the running kernel, which you just changed. Set it back with `sudo sysctl -w net.ipv4.ip_forward=0` before the next section.

## The same instinct elsewhere: timezone

Timezone is not in the sysctl tree, but the "prefer the one clean machine-readable field" habit carries over:

```bash
timedatectl show --property=Timezone --value > /opt/course/1/timezone
```

```text
UTC
```

`timedatectl show` queries `systemd-timedated` over D-Bus; `--property=Timezone --value` returns exactly that one field with no `Timezone=` label — script-safe, unlike grepping the human `timedatectl` status output.

Underneath, the timezone *is* a file relationship: `/etc/localtime` is a symlink into `/usr/share/zoneinfo/<Area>/<City>`, and every timezone-aware tool resolves against it. On Debian/Ubuntu a flat `/etc/timezone` also records the zone name:

```bash
cat /etc/timezone > /opt/course/1/timezone     # Debian/Ubuntu only
```

The two can disagree if someone re-points `/etc/localtime` by hand without going through `timedatectl`. RHEL and openSUSE have no `/etc/timezone` at all — so `timedatectl` is the portable choice.

> [!WARNING]
> - **Redirecting the default `key = value` output** into a file that must hold only a number. Use `sysctl -n`, or `cat` the `/proc/sys` path.
> - **Reading a config file to learn the current value.** `/etc/sysctl.d/*.conf` is intent, not state. Only `sysctl -n <key>` (or the procfs file) tells you what the kernel is doing now.
> - **Assuming `/etc/timezone` exists.** It is Debian/Ubuntu-specific; `timedatectl show --value` works everywhere systemd runs.

> *`/proc/sys/<dots→slashes>` is the file behind every sysctl name; `sysctl -n` and `cat` of that path read the same live in-memory value, which is what the kernel is doing now — not what any `/etc` file claims.*

## Reference

- `man 5 proc` — the `/proc/sys` hierarchy and the dot-to-slash naming convention, stated explicitly.
- `man 8 sysctl` — `-n`, `-a`, `-p`, `--pattern`, `--system`; the read/write flags.
- `man 1 timedatectl` — `show --property= --value` for scripting; how it relates to `/etc/localtime`.
