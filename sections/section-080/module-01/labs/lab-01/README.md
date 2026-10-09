# Root-Filesystem Repair via chroot Lab

Welcome to a rescue mission, astronaut. The `data-001` host had a new data volume added to its `/etc/fstab`, and someone mistyped one character of its UUID. On its next boot, systemd would wait on that mount and drop to an emergency shell.

The grader reaches your training ship only over SSH, so it cannot work with a ship that really fails to boot. Instead, the mission adds a second, disposable 2 GB disk (serial `lab081-data001`). It holds a stand-in `data-001` system: a small root partition with its own `/etc/fstab`, and a data partition. Your own ship's root filesystem and boot are never touched. You mount the stand-in, step into it with `chroot`, and fix the typo with the same steps as a real repair.

## Launching the Lab

Run this command to start the virtual machine:

```bash
astrona run --git git@github.com:astrona-io/ATS002.git -c sections/section-080/module-01/labs/lab-01
```

Open a terminal on it:

```bash
astrona ssh ats-002-lab-081
```

When you think you have finished, send it for grading:

```bash
astrona submit -c sections/section-080/module-01/labs/lab-01
```

When you are done, remove the lab:

```bash
astrona destroy ats-002-lab-081
```
