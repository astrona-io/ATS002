# Zypper Basic Package Operations Lab

Welcome to a maintenance mission, astronaut. You will refresh an openSUSE host's catalogue, check updates and patches separately, apply only the patches, install one package, remove another, and read the history log that records it all.

The training ship runs Ubuntu 24.04, which has no `zypper`. The setup starts Docker and runs a real openSUSE Leap 15.6 container called `zypperbox` on it, with `telnet-server` installed and `fail2ban` not installed. Inside that container, `zypper`, the RPM database and the openSUSE repositories are all real. Do all your work inside it:

```bash
docker exec -it zypperbox bash
```

If Docker refuses with a permission error, run the same command with `sudo` in front.

## Launching the Lab

Run this command to start the virtual machine:

```bash
astrona run --git git@github.com:astrona-io/ATS002.git -c sections/section-070/module-01/labs/lab-01
```

Open a terminal on it:

```bash
astrona ssh ats-002-lab-071
```

When you think you have finished, send it for grading:

```bash
astrona submit -c sections/section-070/module-01/labs/lab-01
```

When you are done, remove the lab:

```bash
astrona destroy ats-002-lab-071
```
