# Two Services, Two Denials Capstone Lab

Welcome to the section's final mission, astronaut. Two services on this training ship are blocked by AppArmor. `logshipper` cannot write to its new log folder, and `metrics-agent` cannot read its new configuration file. The file permissions are correct everywhere.

Your job is to find each denial in the kernel log, add the missing rule to each profile, reload both, and leave both profiles enforcing.

## Launching the lab

Start the virtual machine:

```bash
astrona run --git git@github.com:astrona-io/ATS002.git -c sections/section-040/capstone/labs/lab-01
```

Open a terminal on it:

```bash
astrona ssh ats-002-lab-040
```

When you think you have finished, send it for grading:

```bash
astrona submit -c sections/section-040/capstone/labs/lab-01
```

When you are done, remove the lab:

```bash
astrona destroy ats-002-lab-040
```
