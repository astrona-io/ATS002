# Part 1 — Identifying the running kernel

> Prerequisite: [module landing page](./course.md). Next: [Part 2 — /proc/sys and the live value](./course-02-proc-sys-and-the-live-value.md).

Before you tune anything you have to be able to state, precisely and reproducibly, what kernel is running — and get that string into a file without mangling it. This part is the small set of facts that make `uname` predictable: which field is which, where the same information lives in the filesystem, and the one redirection gotcha that makes a correct command look like it did nothing.

## `uname` fields are not interchangeable

Concrete: a task says "record the kernel release."

```bash
# shell: any host, unprivileged
uname -r
```

```text
6.8.0-45-generic
```

`uname` prints fields from the kernel's own `new_utsname` identity. Each flag selects one, and they answer *different* questions:

| Flag | Field | Example | What it actually is |
|---|---|---|---|
| `-r` | **release** | `6.8.0-45-generic` | the kernel version string — what package tools, DKMS, and graders mean by "kernel version" |
| `-v` | **version** | `#45-Ubuntu SMP PREEMPT_DYNAMIC Wed Sep 4 …` | the **build** banner: build number, config flags, build date. Not a version number. |
| `-s` | sysname | `Linux` | the kernel name |
| `-m` | machine | `x86_64` | hardware architecture |
| `-n` | nodename | `web01` | the hostname |
| `-a` | all of the above | one space-joined line | everything, in a fixed but easy-to-misread order |

The trap is `uname -a`: it joins sysname, nodename, release, version, machine and more onto one line, and under pressure it is easy to grab the wrong whitespace-delimited chunk — especially because the `-v` "version" field *sounds* like the answer to "what version is the kernel" but is a build timestamp. Ask for the one field you want. `man uname` lists every single-letter flag side by side; confirming `-r` = release takes ten seconds and removes the ambiguity.

The same identity is readable straight from the filesystem, which matters on a stripped image with no `uname`:

```bash
cat /proc/sys/kernel/osrelease    # == uname -r
cat /proc/sys/kernel/ostype       # == uname -s   -> Linux
cat /proc/sys/kernel/version      # == uname -v   -> the build banner
cat /proc/version                 # all three, plus the compiler, on one line
```

Those `/proc/sys/kernel/*` files are the first hint of Part 2's model: the values `uname` prints are just sysctl parameters.

> [!TIP]
> **Try it — the same fact, three ways.** On the playground host (`astrona ssh astro-sysctl-live-kernel`):
>
> ```bash
> uname -r
> cat /proc/sys/kernel/osrelease
> uname -v
> ```
>
> Expect something like:
>
> ```text
> 6.8.0-45-generic
> 6.8.0-45-generic
> #45-Ubuntu SMP PREEMPT_DYNAMIC Wed Sep  4 12:34:56 UTC 2025
> ```
>
> The first two match exactly — `uname -r` is reading the same value as `/proc/sys/kernel/osrelease`. The third, `-v`, is a completely different string: the build banner. Version numbers vary by image; the point is that `-r` and `-v` are not the same field.

## Redirection creates the file, never the directory

A task often says "write it to `/opt/course/1/kernel`." The instinct is:

```bash
uname -r > /opt/course/1/kernel
```

If `/opt/course/1` does not already exist this fails with `bash: /opt/course/1/kernel: No such file or directory` — and in a busy terminal that one line can scroll past looking like nothing happened, so you move on believing the file is there.

The mechanism: the shell opens the redirection target with `open(O_CREAT|O_WRONLY|O_TRUNC)` **before** `uname` even runs. `O_CREAT` creates the *final path component* if its parent directory exists; it never creates parent directories. So always make the directory first:

```bash
mkdir -p /opt/course/1
uname -r > /opt/course/1/kernel
cat /opt/course/1/kernel          # verify — always read it back
```

`mkdir -p` creates every missing parent and does not error if the directory already exists, so it is safe to run unconditionally.

> [!TIP]
> **Try it — watch the redirect fail, then fix it.** On the host:
>
> ```bash
> uname -r > /tmp/deep/kernel; echo "exit=$?"
> mkdir -p /tmp/deep && uname -r > /tmp/deep/kernel && cat /tmp/deep/kernel
> ```
>
> Expect something like:
>
> ```text
> bash: /tmp/deep/kernel: No such file or directory
> exit=1
> 6.8.0-45-generic
> ```
>
> The first line writes nothing and exits `1` because `/tmp/deep` does not exist — the shell could not open the target. `mkdir -p` first, then the redirect lands and reading it back confirms it.

> [!WARNING]
> Two ways this bites on a timed exam:
> - **`uname -a` piped into `awk`/`cut`** to "extract" the release. The field order is stable but not obvious; `uname -r` is one field, no parsing, no chance of grabbing the build date.
> - **Redirecting into a path whose directory is missing.** The command exits non-zero and writes nothing. Run `mkdir -p` on the directory first, then read the file back to confirm.

> *`uname -r` is the release string graders and package tools mean by "kernel version"; `-v` is the build banner, `-a` mixes fields — and `>` creates the file but never its parent directory, so `mkdir -p` first.*

## Reference

- `man uname` — every field flag in one table; the ten-second check that `-r` is "release".
- `man 5 proc` — `/proc/version` and the `/proc/sys/kernel/{ostype,osrelease,version}` files that mirror `uname`.
- `man 1 mkdir` — `-p`: create parents, succeed silently if the target exists.
