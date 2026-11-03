# Rootless Podman Container Lab

Welcome to a rootless docking mission, astronaut. A normal crew member must dock a pod and keep it flying after logout.

Your job is to run a container as the user `pilot`, save its image ID, and keep the user's services running after logout.

## Launching the Lab

Run this command to start the virtual machine:

```bash
astrona run --git git@github.com:astrona-io/ATS002.git -c sections/section-020/module-06/labs/lab-01
```

Open a terminal on it:

```bash
astrona ssh ats-002-lab-026
```

When you think you have finished, send it for grading:

```bash
astrona submit -c sections/section-020/module-06/labs/lab-01
```

When you are done, remove the lab:

```bash
astrona destroy ats-002-lab-026
```
