# Container Images, Volumes And Networks Lab

Welcome to a packing mission, astronaut. A web page waits in a folder, and a pod must be built around it.

Your job is to build an image from a `Dockerfile`, create a named volume and a network, and start one container that uses all three.

## Launching the Lab

Run this command to start the virtual machine:

```bash
astrona run --git git@github.com:astrona-io/ATS002.git -c sections/section-020/module-05/labs/lab-01
```

Open a terminal on it:

```bash
astrona ssh ats-002-lab-025
```

When you think you have finished, send it for grading:

```bash
astrona submit -c sections/section-020/module-05/labs/lab-01
```

When you are done, remove the lab:

```bash
astrona destroy ats-002-lab-025
```
