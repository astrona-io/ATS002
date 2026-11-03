# Raising The Kernel And User Ceilings

Astronaut, now you know the three ceilings. Each one has the same shape as any reactor dial: a **live change** that works right now, and a **file** that a start-up or login step reads again later. This part raises the first two ceilings, the machine-wide pool and the per-user limit, both live and for good.

The per-user limit has one surprise: a session that is already open keeps its old limit. You will see why.

## Ceiling 1: `kernel.pid_max`

`kernel.pid_max` is a normal kernel parameter, so you raise it the normal sysctl way: turn the dial live, then write it into the start-up checklist.

<!-- astrona:playground:renew -->

Turn the dial live. This needs `root`:

```bash
# shell: host, root
sudo sysctl -w kernel.pid_max=4194304
```

Now make it permanent. Save this as `/etc/sysctl.d/98-pid-max.conf`:

```ini
kernel.pid_max = 4194304
```

Apply it:

```sh
sudo sysctl --system
```

`sysctl -w` writes the new value into `/proc/sys/kernel/pid_max` now. The drop-in file plus `sysctl --system` makes it immediate *and* safe across reboots. The value takes effect the moment `--system` runs, and the `systemd-sysctl.service` applies the file again on every boot.

## Ceiling 2: `ulimit -u` / `RLIMIT_NPROC`

The per-user limit has two layers too: a live change with the `ulimit` shell command, and a file that the login process reads. They behave differently, so look at each one.

### The live change

Run this as the workload's user. It raises the soft limit for the current shell:

```bash
# shell: as the workload's user
ulimit -u 32768        # raise the SOFT limit (up to the hard limit; root to exceed)
```

This changes **only this shell and the programs it starts from now on**. It does not reach an already-running service, another terminal, or a process that has already started. It is also gone when you log out, and of course after a reboot.

### The permanent change, through PAM

**PAM** (Pluggable Authentication Modules) is the set of steps Linux runs every time someone logs in. One of those steps, `pam_limits`, reads the limit files and sets the limits for the new session.

Save this as `/etc/security/limits.d/data-processing.conf`:

```text
dataproc   soft   nproc   32768
dataproc   hard   nproc   65536
```

Each line has four columns: the user, `soft` or `hard`, the kind of limit (`nproc` is the number of processes), and the value. There is no apply command. `pam_limits` reads the file at the next login. Then check the result in a fresh login session for that user, which should now print `32768`:

```sh
sudo -iu dataproc bash -c 'ulimit -u'
```

### Why an open session keeps its old limit

`man 5 limits.conf` explains it: `pam_limits` reads the file **at login time**. It sets the limits on the first process of the new session, and every program started from it inherits them. So a shell or session that was **already open when you edited the file keeps its old limit**. The file only affects sessions that log in *after* it is in place.

To pick up the new value, log out and back in, or restart the service so it gets a fresh session. That is not a bug. It is `pam_limits` doing what its manual says. `sudo -iu dataproc` works as a check because `-i` starts a full login session, and that login runs `pam_limits` again.

A systemd *service* does not go through `pam_limits`. For a service, the setting is `LimitNPROC=` in the unit file, not `limits.conf`. For a service, though, you usually want the per-service ceiling, `TasksMax=`, instead.

> [!TIP]
> When several files under `/etc/security/limits.d/` set the same limit for the same user, the file read last wins. Give your file a name that sorts after any existing one, and check the result with a fresh `sudo -iu <user>` session rather than in the shell you already have open.

## Common pitfalls

> [!WARNING]
> - **`ulimit -u` in a script, expecting it to last.** It dies with the shell. For login sessions, the permanent place is `/etc/security/limits.d/`. For services, it is `LimitNPROC=`.
> - **Editing `limits.conf` and testing in the same open session.** `pam_limits` ran at login, before your edit. Log in again to get the new value.
> - **Raising only the soft limit above the hard limit.** The soft limit can never be higher than the hard limit. Set both lines.

## Your mission: Process Limits: Diagnose the Single Clamp (ulimit -u) Lab

You can now read all three ceilings and raise the per-user limit so that it lasts. The mission gives you a workload that cannot start enough processes: find the one ceiling that is really too low, raise only that one, and leave the other two alone.

The mission runs on its own training ship. Your playground cannot be paused, so remove it first. It always starts clean, so you lose nothing you need:

```sh
astrona destroy process-limits-ceilings
```

Then start the mission and open a terminal on it:

```sh
astrona run --git git@github.com:astrona-io/ATS002.git -c sections/section-010/module-02/labs/lab-02
astrona ssh ats-002-lab-012b
```

Read the task in [`question.md`](./labs/lab-02/question.md) and solve it on your own first. When you think you are done, send it for grading:

```sh
astrona submit -c sections/section-010/module-02/labs/lab-02
```

When the mission is done, remove it and start your playground again:

```sh
astrona destroy ats-002-lab-012b
astrona run --git git@github.com:astrona-io/ATS002.git -c sections/section-010/module-02/playground
```
