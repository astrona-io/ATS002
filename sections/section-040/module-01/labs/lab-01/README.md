# AppArmor Profile Enforcement Lab

Welcome to a security mission, astronaut. The `appservice` daemon on this training ship now writes its heartbeat log to `/srv/applogs`. The file permissions are correct, but its AppArmor profile, in enforce mode, only knows the old log folder, so every write is denied.

Your job is to find the denial in the kernel log, add the missing rule to the profile, reload it, and leave the profile enforcing.

## Launching the lab

Start the virtual machine:

```bash
astrona run --git git@github.com:astrona-io/ATS002.git -c sections/section-040/module-01/labs/lab-01
```

Open a terminal on it:

```bash
astrona ssh ats-002-lab-041
```

When you think you have finished, send it for grading:

```bash
astrona submit -c sections/section-040/module-01/labs/lab-01
```

When you are done, remove the lab:

```bash
astrona destroy ats-002-lab-041
```
