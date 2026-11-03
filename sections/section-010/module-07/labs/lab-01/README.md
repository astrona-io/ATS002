# Process Inspection And Control Lab

Welcome to a crew duty mission, astronaut. Three crew members work in the background of this training ship: one burns a whole CPU, one ignores polite orders, and one just sleeps.

Your job is to end the stubborn one, lower the priority of the busy one, and write down the badge number of the quiet one.

## Launching the Lab

Run this command to start the virtual machine:

```bash
astrona run --git git@github.com:astrona-io/ATS002.git -c sections/section-010/module-07/labs/lab-01
```

Open a terminal on it:

```bash
astrona ssh ats-002-lab-01a
```

When you think you have finished, send it for grading:

```bash
astrona submit -c sections/section-010/module-07/labs/lab-01
```

When you are done, remove the lab:

```bash
astrona destroy ats-002-lab-01a
```
