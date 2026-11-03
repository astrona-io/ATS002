# APT Pinning (not a hold) Lab

Welcome to a supply mission, astronaut. On this training ship, `curl` has a higher version in Ubuntu's `noble-updates` pocket than in the `noble` release pocket, so APT prefers the updates version.

Your job is to change that preference with APT **pinning**: a file under `/etc/apt/preferences.d/` with `Pin: release a=noble` and a `Pin-Priority` above `500`. Do not use `apt-mark hold`. You check the result with `apt-cache policy curl`.

## Launching the Lab

Run this command to start the virtual machine:

```bash
astrona run --git git@github.com:astrona-io/ATS002.git -c sections/section-050/module-01/labs/lab-02
```

Open a terminal on it:

```bash
astrona ssh ats-002-lab-051b
```

When you think you have finished, send it for grading:

```bash
astrona submit -c sections/section-050/module-01/labs/lab-02
```

When you are done, remove the lab:

```bash
astrona destroy ats-002-lab-051b
```
