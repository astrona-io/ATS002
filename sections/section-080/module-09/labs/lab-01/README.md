# Disk Health Diagnosis Lab

Welcome, astronaut. One of the two spare disks on your training ship has thrown an I/O error, and the monitoring crew wants a diagnosis report. You find the right disk by its serial number, collect the evidence in a few files and scan it without harming its data.

The work happens on the spare disks only, so your ship stays reachable over SSH the whole time.

## Launching the Lab

Run this command to start the virtual machine:

```bash
astrona run --git git@github.com:astrona-io/ATS002.git -c sections/section-080/module-09/labs/lab-01
```

Open a terminal on it:

```bash
astrona ssh ats-002-lab-08a
```

When you think you have finished, send it for grading:

```bash
astrona submit -c sections/section-080/module-09/labs/lab-01
```

When you are done, remove the lab:

```bash
astrona destroy ats-002-lab-08a
```
