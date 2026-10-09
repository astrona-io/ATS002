# New Toolchain, New Host Capstone Lab

Welcome to your capstone mission, astronaut. In one maintenance window you set up a new build-agent host. First you build a small reporting tool from a kit of parts and bolt it into an exact place with one feature switched off. Then you file the blueprint for a new smaller ship in the hangar, make it launch whenever the hangar opens, and launch it.

At the end, the tool you built reports on the ship you launched. If either half is wrong, that last report fails.

## Launching the Lab

Run this command to start the virtual machine:

```bash
astrona run --git git@github.com:astrona-io/ATS002.git -c sections/section-030/capstone/labs/lab-01
```

Open a terminal on it:

```bash
astrona ssh ats-002-lab-030
```

When you think you have finished, send it for grading:

```bash
astrona submit -c sections/section-030/capstone/labs/lab-01
```

When you are done, remove the lab:

```bash
astrona destroy ats-002-lab-030
```
