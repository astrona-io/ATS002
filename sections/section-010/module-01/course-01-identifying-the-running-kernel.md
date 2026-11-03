# Identifying The Running Kernel

Astronaut, before you turn any dial on your ship, you must know which reactor you are flying with. The **kernel** is the ship's reactor core: it runs everything and hands out power and time to every program. This part shows you how to name the running kernel exactly, and how to get that name into a file without breaking it.

You will learn three things here: which `uname` field is which, where the same facts live in the filesystem, and one redirection trap that makes a correct command look like it did nothing.

## `uname` fields are not interchangeable

A task says: "record the kernel release." The command `uname` prints facts about the running kernel. Each option picks one fact, and the facts answer different questions.

<!-- astrona:playground:renew -->

Run this on any machine. You do not need `sudo`:

```bash
# shell: any host, unprivileged
uname -r
```

```text
6.8.0-45-generic
```

The kernel keeps a small identity card about itself. `uname` reads that card and prints the field you ask for. Here are the fields side by side:

| Flag | Field | Example | What it actually is |
|---|---|---|---|
| `-r` | **release** | `6.8.0-45-generic` | the kernel version string — what package tools, DKMS, and graders mean by "kernel version" |
| `-v` | **version** | `#45-Ubuntu SMP PREEMPT_DYNAMIC Wed Sep 4 …` | the **build** banner: build number, configuration flags, build date. Not a version number. |
| `-s` | sysname | `Linux` | the kernel name |
| `-m` | machine | `x86_64` | hardware architecture |
| `-n` | nodename | `web01` | the hostname |
| `-a` | all of the above | one space-joined line | everything, in a fixed but easy-to-misread order |

The trap is `uname -a`. It puts the kernel name, host name, release, build banner, hardware type and more on one line. Under time pressure it is easy to grab the wrong piece. The name "version" for `-v` makes it worse: it sounds like the answer, but it is a build date. So always ask for the one field you want.

`man uname` lists every single-letter option side by side. Checking that `-r` means "release" takes ten seconds and removes the doubt.

### The same facts as files

The same identity can be read straight from the filesystem. This matters on a stripped-down machine that has no `uname` command:

```bash
cat /proc/sys/kernel/osrelease    # == uname -r
cat /proc/sys/kernel/ostype       # == uname -s   -> Linux
cat /proc/sys/kernel/version      # == uname -v   -> the build banner
cat /proc/version                 # all three, plus the compiler, on one line
```

The files under `/proc/sys/kernel/` are kernel parameters. So the values `uname` prints are kernel parameters too, and you can read them like any other one.

### Try it: the same fact, three ways

On your playground, run the release command, read the matching file, and then ask for the build banner:

```bash
uname -r
cat /proc/sys/kernel/osrelease
uname -v
```

Expect something like:

```text
6.8.0-45-generic
6.8.0-45-generic
#45-Ubuntu SMP PREEMPT_DYNAMIC Wed Sep  4 12:34:56 UTC 2025
```

The first two lines match exactly: `uname -r` reads the same value as `/proc/sys/kernel/osrelease`. The third line, from `-v`, is a different string: the build banner. Your version numbers depend on the image. What matters is that `-r` and `-v` are not the same field.

## Redirection creates the file, never the folder

A task often says "write it to `/opt/course/1/kernel`." The first idea is this:

```bash
uname -r > /opt/course/1/kernel
```

If the folder `/opt/course/1` does not exist yet, this fails with `bash: /opt/course/1/kernel: No such file or directory`. In a busy terminal that one line can scroll past. You move on and believe the file is there.

### Why it fails

The shell (`bash`, the bridge console where you type orders) opens the target file **before** `uname` even runs. To open it, the shell makes a **system call**: a request to the kernel, like a crew member asking the reactor core to open a hatch. The call it uses is `open(O_CREAT|O_WRONLY|O_TRUNC)`. `O_CREAT` creates the last part of the path, the file itself, but only if its folder already exists. It never creates folders.

So always make the folder first, then write, then read the file back:

```bash
mkdir -p /opt/course/1
uname -r > /opt/course/1/kernel
cat /opt/course/1/kernel          # verify — always read it back
```

`mkdir -p` creates every missing folder on the path. It does not complain if the folder already exists, so it is safe to run every time. On a machine where `/opt` belongs to `root`, run the `mkdir` with `sudo` and then make the folder yours (`sudo chown $USER /opt/course/1`), or the shell cannot write the file.

### Try it: watch the redirect fail, then fix it

On your playground, first write into a folder that does not exist, and print the exit code. Then create the folder and try again:

```bash
uname -r > /tmp/deep/kernel; echo "exit=$?"
mkdir -p /tmp/deep && uname -r > /tmp/deep/kernel && cat /tmp/deep/kernel
```

Expect something like:

```text
bash: /tmp/deep/kernel: No such file or directory
exit=1
6.8.0-45-generic
```

The first command writes nothing and exits with `1`, because `/tmp/deep` does not exist and the shell could not open the target. After `mkdir -p`, the write works, and reading the file back proves it.

> [!TIP]
> Make "write, then read it back with `cat`" a habit for every answer file. One `cat` catches a missing folder, an empty file or the wrong field before a grader does.

## Common pitfalls

> [!WARNING]
> - **Piping `uname -a` into `awk` or `cut`** to "extract" the release. The field order is fixed but hard to read. `uname -r` gives one field, with no parsing and no chance of grabbing the build date.
> - **Mixing up `-r` and `-v`.** `-r` is the release that tools and graders mean by "kernel version". `-v` is the build banner.
> - **Writing into a path whose folder is missing.** The command exits with an error and writes nothing. Run `mkdir -p` on the folder first, then read the file back to confirm.
