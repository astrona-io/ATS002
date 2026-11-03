# Configure journald: Persistent & Bounded Lab

Astronaut, the ship's log on this training ship is written on a whiteboard that is wiped at every restart: the journal lives only in memory, so it is lost at each reboot. It also has no size limit of its own.

Your job: set up `systemd-journald`, the log keeper, so it keeps the journal on disk under `/var/log/journal/`, caps its size at 200 MB or less with `SystemMaxUse=`, and uses the new settings now. Check the result with `journalctl --disk-usage`.

## Launching the lab

Start the virtual machine:

```sh
astrona run --git git@github.com:astrona-io/ATS002.git -c sections/section-010/module-06/labs/lab-05
```

Open a terminal on it:

```sh
astrona ssh ats-002-lab-016e
```

When you think you have finished, send it for grading:

```sh
astrona submit -c sections/section-010/module-06/labs/lab-05
```

When you are done, remove the lab:

```sh
astrona destroy ats-002-lab-016e
```
