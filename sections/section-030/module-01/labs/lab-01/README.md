# Compile & Install From Source Lab

Welcome to a build mission, astronaut. A kit of parts has arrived on this training ship: the source code of the `links` terminal web browser, packed in a tarball in `/tools`. The build tools are already on board.

Your job is to build it and bolt it into one exact place, `/usr/bin/links`, with IPv6 support switched off. The grader checks the installed program itself, not the commands you typed.

## Launching the Lab

Run this command to start the virtual machine:

```bash
astrona run --git git@github.com:astrona-io/ATS002.git -c sections/section-030/module-01/labs/lab-01
```

Open a terminal on it:

```bash
astrona ssh ats-002-lab-031
```

When you think you have finished, send it for grading:

```bash
astrona submit -c sections/section-030/module-01/labs/lab-01
```

When you are done, remove the lab:

```bash
astrona destroy ats-002-lab-031
```
