# Password Reset & Single-User Recovery Lab

Welcome to a lockout mission, astronaut. The root password on the `data-001` host is lost, and no other account can use `sudo`. On a real server you would interrupt the GRUB menu for one boot (`rd.break` or `init=/bin/bash`), but that needs a console the grader cannot reach.

So the mission adds a second, disposable 1 GB disk (serial `lab082-data001`). It holds a stand-in `data-001` root filesystem whose `/etc/shadow` has root locked (password field `!`). Your own ship's boot is never touched. You mount the stand-in, step into it with `chroot`, and write a real password hash for root.

## Launching the Lab

Run this command to start the virtual machine:

```bash
astrona run --git git@github.com:astrona-io/ATS002.git -c sections/section-080/module-02/labs/lab-01
```

Open a terminal on it:

```bash
astrona ssh ats-002-lab-082
```

When you think you have finished, send it for grading:

```bash
astrona submit -c sections/section-080/module-02/labs/lab-01
```

When you are done, remove the lab:

```bash
astrona destroy ats-002-lab-082
```
