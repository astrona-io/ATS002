# Service Won't Start: Permission Denied Lab

Astronaut, `metricsd.service` on this training ship runs as its own non-root user, and it fails with `status=1/FAILURE` every time it starts. The program itself runs, but that user has no key to the hatch it needs: it cannot write to its data folder under `/var/lib`.

Your job: find the cause in the daemon's own journal lines, fix the access problem (ownership, or a `StateDirectory=` setting), and prove that the service is running, enabled for boot and still not running as `root`.

## Launching the lab

Start the virtual machine:

```sh
astrona run --git git@github.com:astrona-io/ATS002.git -c sections/section-010/module-06/labs/lab-02
```

Open a terminal on it:

```sh
astrona ssh ats-002-lab-017
```

When you think you have finished, send it for grading:

```sh
astrona submit -c sections/section-010/module-06/labs/lab-02
```

When you are done, remove the lab:

```sh
astrona destroy ats-002-lab-017
```
