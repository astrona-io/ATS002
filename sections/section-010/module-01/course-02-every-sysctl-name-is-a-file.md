# Every Sysctl Name Is A File

Astronaut, your reactor core has a control panel full of dials. Each dial is a **kernel parameter**: one setting that changes how the kernel behaves, such as whether it passes network traffic on, or how many process numbers it can hand out. The tool you use to read and turn these dials is `sysctl`.

`sysctl` looks like a program with its own settings, but it is not. It is a thin reader and writer on top of a special folder that the kernel shows as files. Once you see how names turn into file paths, every `sysctl` command becomes easy to predict. You can even do the same job with `cat` when `sysctl` is missing.

## The name and the path

Start with one real dial. Does this machine pass network packets from one network card to another? The kernel parameter for that is `net.ipv4.ip_forward`.

<!-- astrona:playground:renew -->

Read it on any machine. You do not need `sudo`:

```bash
# shell: any host, unprivileged
sysctl net.ipv4.ip_forward
```

```text
net.ipv4.ip_forward = 0
```

`0` means "off": this machine does not forward packets.

### `/proc/sys` is the live gauge panel

The folder `/proc` holds **procfs**, a virtual filesystem. Its "files" are not stored on any disk. Each time you read one, the kernel answers on the spot. Think of the subfolder `/proc/sys` as the reactor's live gauge panel: each file is one dial, and you can read and turn it while the reactor runs.

The rule from name to path is simple: **replace each `.` with `/` and put `/proc/sys/` in front**.

```
  net.ipv4.ip_forward
   │   │    │
   ▼   ▼    ▼
  /proc/sys/net/ipv4/ip_forward
```

So this command reads exactly the same value:

```bash
cat /proc/sys/net/ipv4/ip_forward
```

```text
0
```

Under the hood, `sysctl` opens and reads that same file, then adds the name in front of the value. Nothing more.

### How the dials are grouped

The top-level folders group the dials by area:

- `kernel/` holds identity facts, `pid_max` and `panic`.
- `net/` holds networking settings, per protocol and per network card.
- `vm/` holds memory settings, such as `swappiness` and overcommit.
- `fs/` holds file settings, such as `file-max` and inotify.
- `dev/` holds device settings.

`sysctl -a` prints every dial in the tree. `sysctl -a --pattern 'net.ipv4.conf.*'` prints only the ones whose names match the pattern.

### Try it: the name and the path are the same file

On your playground, read the same dial three ways:

```bash
sysctl net.ipv4.ip_forward
cat /proc/sys/net/ipv4/ip_forward
sysctl -n net.ipv4.ip_forward
```

Expect something like:

```text
net.ipv4.ip_forward = 0
0
0
```

Line 1 is the human form, `key = value`. Lines 2 and 3 are the bare value: one from the `/proc/sys` path and one from `sysctl -n`. All three asked the kernel the same question. The bare forms are the ones you send into an answer file.

> [!TIP]
> When you meet a new kernel parameter, turn its dots into slashes in your head. If you know the `/proc/sys` path, you can read the dial even on a machine where `sysctl` is not installed.

## Common pitfalls

> [!WARNING]
> - **Forgetting the `/proc/sys/` prefix.** `/net/ipv4/ip_forward` does not exist. The full path is `/proc/sys/net/ipv4/ip_forward`.
> - **Thinking `/proc/sys` files are stored on disk.** They are the kernel answering live. Editing a backup copy of one, or searching the disk for it, tells you nothing.
> - **Treating `sysctl` as the only way in.** It is a wrapper. `cat` on the `/proc/sys` path reads the same value.
