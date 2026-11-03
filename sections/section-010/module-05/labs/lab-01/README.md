# Process Forensics with strace Lab

Welcome to an investigation mission, astronaut. Three crew members on this training ship, the `collector` processes, look alike, but one of them keeps making a forbidden request to the reactor core: the `kill()` system call.

Your job is to clip the flight recorder, `strace`, onto them, catch the guilty one with evidence, record its real program file, end it, and remove that file, while the innocent processes keep running.

## Launching the Lab

Start the virtual machine:

```bash
astrona run --git git@github.com:astrona-io/ATS002.git -c sections/section-010/module-05/labs/lab-01
```

Open a terminal on it:

```bash
astrona ssh ats-002-lab-015
```

When you think you have finished, send it for grading:

```bash
astrona submit -c sections/section-010/module-05/labs/lab-01
```

When you are done, remove the lab:

```bash
astrona destroy ats-002-lab-015
```
