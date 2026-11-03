# Kernel Module Loading & Blacklisting Lab

Welcome to a reactor-parts mission, astronaut. On this training ship, one plug-in reactor part (the `dummy` network module) must be fitted with a setting that survives every launch, and another part (the `pcspkr` beep driver) must never be fitted automatically again.

The ship is an Ubuntu 24.04 virtual machine with its own real kernel, so `modprobe` really loads and unloads modules. The `pcspkr` module is already loaded when the mission starts.

## Launching the Lab

Start the virtual machine:

```bash
astrona run --git git@github.com:astrona-io/ATS002.git -c sections/section-010/module-03/labs/lab-01
```

Open a terminal on it:

```bash
astrona ssh ats-002-lab-013
```

When you think you have finished, send it for grading:

```bash
astrona submit -c sections/section-010/module-03/labs/lab-01
```

When you are done, remove the lab:

```bash
astrona destroy ats-002-lab-013
```
