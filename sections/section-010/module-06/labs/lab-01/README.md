# Service Won't Start: Bad ExecStart Path Lab

Astronaut, one station on this training ship will not come up. `reportd.service` fails the moment it starts, with `status=203/EXEC`: the duty officer (`systemd`) cannot even run the program, because the unit's `ExecStart=` line points at a path that does not exist. The real program is somewhere else on disk.

Your job: read the failure with `systemctl status` and `journalctl -xeu`, point the unit at the real program, and prove that the service is running, enabled for boot, and really doing its work.

## Launching the lab

Start the virtual machine:

```sh
astrona run --git git@github.com:astrona-io/ATS002.git -c sections/section-010/module-06/labs/lab-01
```

Open a terminal on it:

```sh
astrona ssh ats-002-lab-016
```

When you think you have finished, send it for grading:

```sh
astrona submit -c sections/section-010/module-06/labs/lab-01
```

When you are done, remove the lab:

```sh
astrona destroy ats-002-lab-016
```
