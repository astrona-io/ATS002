# Wrap-Up: Mission Debrief

Well flown, astronaut. You have worked through every part and the mission in this module. Before you move on, look back at what you learned, check yourself, and clean up anything still running.

## What you learned

This module was about the dials on the reactor's control panel: how to read them, how to turn them for now, and how to make a setting stick.

**From [Identifying The Running Kernel](./course-01-identifying-the-running-kernel.md):**

- `uname -r` is the release string that graders and package tools mean by "kernel version". `-v` is the build banner, and `-a` mixes all the fields on one line.
- The same facts live in `/proc/sys/kernel/osrelease`, `/proc/sys/kernel/ostype`, `/proc/sys/kernel/version` and `/proc/version`.
- `>` creates the file but never its folder, so run `mkdir -p` first and read the file back with `cat`.

**From [Every Sysctl Name Is A File](./course-02-every-sysctl-name-is-a-file.md):**

- Every sysctl name is a file under `/proc/sys`: turn the dots into slashes and put `/proc/sys/` in front.
- `/proc/sys` is not on disk. The kernel answers each read live.
- `sysctl` is a thin wrapper. `cat` on the path reads the same value.

**From [Reading The Live Value](./course-03-reading-the-live-value.md):**

- `sysctl -n` and `cat` of the `/proc/sys` path give the bare value, ready for an answer file.
- A read shows the kernel's current value in memory, not what any file under `/etc` says.
- `timedatectl show --property=Timezone --value` gives the timezone as one clean field, on every system that runs systemd.

**From [Runtime Changes Live In Memory](./course-04-runtime-changes-live-in-memory.md):**

- `sysctl -w` (or `echo` into the `/proc/sys` file as `root`) changes memory only and touches no file.
- At every boot, `systemd-sysctl` builds the values again from the files, so a `-w` change is gone after a reboot.

**From [Persistent Changes And Which File Wins](./course-05-persistent-changes-and-which-file-wins.md):**

- A `*.conf` drop-in under `/etc/sysctl.d/` plus `sysctl --system` makes a change both immediate and reboot-proof.
- Files are applied in alphabetical order of their names, and the file that sorts last wins a key collision. That is why drop-ins start with a number such as `99-`.
- `sysctl --system 2>&1 | grep <key>` shows which file set the final value.

## Your missions

You proved these skills in a graded mission, right after the part that taught the last of them:

| Mission | After the part | What you proved |
| --- | --- | --- |
| [sysctl Live Kernel State Lab](./labs/lab-01/README.md) | Reading The Live Value | wrote the kernel release, a live kernel parameter and the timezone into answer files, with nothing extra in them |

If you skipped it, go back to it now. It is short, and the exam asks for exactly these skills.

## Check yourself

Try to answer each question before you open the answer.

<details>
<summary>1. A task asks for the kernel version. Which <code>uname</code> option do you use, and why not <code>-v</code>?</summary>

`uname -r`. It prints the release string, such as `6.8.0-45-generic`. `-v` prints the build banner with a build date, which only sounds like a version.
</details>

<details>
<summary>2. <code>uname -r > /opt/course/1/kernel</code> prints "No such file or directory". What is wrong?</summary>

The folder `/opt/course/1` does not exist. The shell creates the file, but never its folder. Run `mkdir -p /opt/course/1` first, then write the file and read it back.
</details>

<details>
<summary>3. Which file does <code>sysctl net.ipv4.ip_forward</code> read?</summary>

`/proc/sys/net/ipv4/ip_forward`. Turn the dots into slashes and put `/proc/sys/` in front.
</details>

<details>
<summary>4. An answer file must hold only the number. Which two commands give you that?</summary>

`sysctl -n <key>` and `cat /proc/sys/<path>`. The default `sysctl <key>` adds the name and ` = `.
</details>

<details>
<summary>5. No file under <code>/etc</code> mentions <code>ip_forward</code>, yet <code>sysctl -n net.ipv4.ip_forward</code> prints <code>1</code>. How?</summary>

Someone changed it live with `sysctl -w`. A read asks the running kernel, not a file, so it shows the value in memory.
</details>

<details>
<summary>6. You ran <code>sudo sysctl -w vm.swappiness=10</code>. What is the value after a reboot?</summary>

Whatever the sysctl files say, or the kernel's built-in default (`60`) if no file sets it. `-w` changed memory only, and the boot builds the values again from the files.
</details>

<details>
<summary>7. <code>10-swappiness.conf</code> sets 42 and <code>99-swappiness.conf</code> sets 10. Which value is live after <code>sudo sysctl --system</code>?</summary>

`10`. The files are applied in alphabetical order of their names, and `99-` sorts last, so it wins.
</details>

## Clean up the playground

Your playground is a whole virtual machine running on your computer. When you are done with this module, remove it, and any mission that is still running.

First, see what is still running:

```sh
astrona list
```

Remove the playground. The command takes its **name**, not its folder path:

```sh
astrona destroy sysctl-live-kernel
```

If `astrona list` also showed the mission, remove it the same way:

```sh
astrona destroy ats-002-lab-011
```

Then run `astrona list` again to check that everything is gone. You can start the playground again at any time. It always starts clean:

```sh
astrona run --git git@github.com:astrona-io/ATS002.git -c sections/section-010/module-01/playground
```

> *A read shows the kernel's memory; `sysctl -w` changes only memory; a drop-in under `/etc/sysctl.d/` plus `sysctl --system` changes it now and on every boot.*
