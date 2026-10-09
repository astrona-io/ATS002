# Service Won't Start: Failed Dependency & Restart Flap Lab

Astronaut, the data pipeline on this training ship is down. `ingest.service` needs the station `ingest-db.service` staffed first (`Requires=`), and that station fails with `203/EXEC` because of a wrong `ExecStart=` path. So `ingest` is pulled down with it, keeps restarting because of `Restart=always`, and finally hits `start-limit-hit`: the duty officer gives up.

Your job: fix the station at the bottom of the chain, clear the restart limit with `reset-failed`, start the chain, and enable **both** units for boot.

## Launching the lab

Start the virtual machine:

```sh
astrona run --git git@github.com:astrona-io/ATS002.git -c sections/section-010/module-06/labs/lab-04
```

Open a terminal on it:

```sh
astrona ssh ats-002-lab-019
```

When you think you have finished, send it for grading:

```sh
astrona submit -c sections/section-010/module-06/labs/lab-04
```

When you are done, remove the lab:

```sh
astrona destroy ats-002-lab-019
```
