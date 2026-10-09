# Process & Thread Ceilings Lab

Welcome to a repair mission, astronaut. A batch job on this training ship keeps failing with "cannot fork" errors, even though CPU and memory are idle. Three separate ceilings decide how many processes and threads it may start: the machine-wide pool (`kernel.pid_max`), the `dataproc` user's limit (`ulimit -u`), and the service's own cap (`TasksMax=`).

Your job is to raise all three, live and so that the change lasts.

## Launching the Lab

Run this command to start the virtual machine:

```bash
astrona run --git git@github.com:astrona-io/ATS002.git -c sections/section-010/module-02/labs/lab-01
```

Open a terminal on it:

```bash
astrona ssh ats-002-lab-012
```

When you think you have finished, send it for grading:

```bash
astrona submit -c sections/section-010/module-02/labs/lab-01
```

When you are done, remove the lab:

```bash
astrona destroy ats-002-lab-012
```
