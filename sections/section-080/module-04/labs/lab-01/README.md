# GRUB Corruption Recovery Lab

Welcome to a launch computer repair, astronaut. On a real machine, this failure shows up as a bare `grub>` prompt with no menu, at a console the grader cannot reach. So this mission sets it up safely on your training ship itself: the setup script removes `/boot/grub/grub.cfg`, GRUB's launch checklist.

The kernel your ship is running now was loaded before the file went missing, and GRUB's installed boot code is not touched. Your SSH session keeps working. Only the next reboot would fail, so your job is to fix it before that reboot happens.

## Launching the Lab

Run this command to start the virtual machine:

```bash
astrona run --git git@github.com:astrona-io/ATS002.git -c sections/section-080/module-04/labs/lab-01
```

Open a terminal on it:

```bash
astrona ssh ats-002-lab-084
```

When you think you have finished, send it for grading:

```bash
astrona submit -c sections/section-080/module-04/labs/lab-01
```

When you are done, remove the lab:

```bash
astrona destroy ats-002-lab-084
```
