# SELinux Fix Script Lab

Welcome to a repair mission, astronaut. A web server on a RHEL-family ship is refused three times by the security chief: wrong label, switch off, unknown channel. This training ship runs AppArmor, so it cannot run SELinux. You write the fix as a script, and the grader checks the script.

## Launching the Lab

Run this command to start the virtual machine:

```bash
astrona run --git git@github.com:astrona-io/ATS002.git -c sections/section-040/module-02/labs/lab-01
```

Open a terminal on it:

```bash
astrona ssh ats-002-lab-043
```

When you think you have finished, send it for grading:

```bash
astrona submit -c sections/section-040/module-02/labs/lab-01
```

When you are done, remove the lab:

```bash
astrona destroy ats-002-lab-043
```
