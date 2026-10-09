# Zypper Package Information Lookup Lab

Welcome to a research mission, astronaut. Before anyone orders a crate, the quartermaster needs answers: which package does a job, what exactly is in one package, which package supplies a missing command, and what is already on board. You will find each answer with `zypper` and save it to a file. Nothing gets installed, removed or updated.

The training ship runs Ubuntu 24.04, which has no `zypper`. The setup starts Docker and runs a real openSUSE Leap 15.6 container called `zypperbox` on it, with `python3-base` and `python3-pip` installed and an empty `/root/answers` directory. Do all your work inside it:

```bash
docker exec -it zypperbox bash
```

If Docker refuses with a permission error, run the same command with `sudo` in front.

## Launching the Lab

Run this command to start the virtual machine:

```bash
astrona run --git git@github.com:astrona-io/ATS002.git -c sections/section-070/module-02/labs/lab-01
```

Open a terminal on it:

```bash
astrona ssh ats-002-lab-072
```

When you think you have finished, send it for grading:

```bash
astrona submit -c sections/section-070/module-02/labs/lab-01
```

When you are done, remove the lab:

```bash
astrona destroy ats-002-lab-072
```
