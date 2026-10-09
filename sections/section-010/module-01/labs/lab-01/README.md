# sysctl Live Kernel State Lab

Welcome to a reporting mission, astronaut. Mission control wants three facts from this training ship: which kernel it runs, the live value of one reactor dial, and its timezone.

Your job is to write each fact into its own answer file under `/opt/course`, with nothing extra in it. One dial has already been changed for you, so read what the kernel really uses, not what you expect.

## Launching the Lab

Run this command to start the virtual machine:

```bash
astrona run --git git@github.com:astrona-io/ATS002.git -c sections/section-010/module-01/labs/lab-01
```

Open a terminal on it:

```bash
astrona ssh ats-002-lab-011
```

When you think you have finished, send it for grading:

```bash
astrona submit -c sections/section-010/module-01/labs/lab-01
```

When you are done, remove the lab:

```bash
astrona destroy ats-002-lab-011
```
