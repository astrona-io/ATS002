# New App Server Onboarding Capstone Lab

Welcome to the section's final mission, astronaut. This training ship is a freshly built application server, and you are the one who gets it ready for service.

The mission joins every Debian packaging skill into one onboarding pass: install a toolchain in one transaction, trust a vendor repository and install and hold its exact build, recover a package stuck in the middle of an install, hold a whole package family found by pattern, and research a package to answer an onboarding question without installing it.

## Launching the Lab

Run this command to start the virtual machine:

```bash
astrona run --git git@github.com:astrona-io/ATS002.git -c sections/section-050/capstone/labs/lab-01
```

Open a terminal on it:

```bash
astrona ssh ats-002-lab-050
```

When you think you have finished, send it for grading:

```bash
astrona submit -c sections/section-050/capstone/labs/lab-01
```

When you are done, remove the lab:

```bash
astrona destroy ats-002-lab-050
```
