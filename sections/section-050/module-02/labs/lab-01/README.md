# dpkg Low-Level Package Management Lab

Welcome to a loading-bay mission, astronaut. A colleague left a standalone `.deb` file for the internal tool `logtail-utils` on this training ship, and an earlier install of `cowsay` was cut short.

Your job is to inspect the `.deb` before installing it, install it directly with `dpkg -i`, answer who-owns-what questions in both directions, and bring the half-configured `cowsay` back to a clean state.

## Launching the Lab

Run this command to start the virtual machine:

```bash
astrona run --git git@github.com:astrona-io/ATS002.git -c sections/section-050/module-02/labs/lab-01
```

Open a terminal on it:

```bash
astrona ssh ats-002-lab-052
```

When you think you have finished, send it for grading:

```bash
astrona submit -c sections/section-050/module-02/labs/lab-01
```

When you are done, remove the lab:

```bash
astrona destroy ats-002-lab-052
```
