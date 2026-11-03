# Initramfs Rebuild Lab

Welcome, astronaut. This ship's boot crate, the initramfs image the kernel unpacks to find the root filesystem, has gone missing from `/boot`. The ship is still flying, because the kernel is already loaded. But the next reboot would stop at a rescue prompt.

You find the missing image, rebuild it for the running kernel, and prove it is a real image. Nothing reboots the machine during the lab.

## Launching the Lab

Run this command to start the virtual machine:

```bash
astrona run --git git@github.com:astrona-io/ATS002.git -c sections/section-080/module-06/labs/lab-01
```

Open a terminal on it:

```bash
astrona ssh ats-002-lab-087
```

When you think you have finished, send it for grading:

```bash
astrona submit -c sections/section-080/module-06/labs/lab-01
```

When you are done, remove the lab:

```bash
astrona destroy ats-002-lab-087
```
