# Raising TasksMax And The Triage Order

Astronaut, the last ceiling belongs to systemd, the ship's duty officer. Every service is a station with a **unit file**, its duty card. `TasksMax=` on that card says how many crew members the station may hold. This part raises it with a **drop-in override**: a sticky note on the duty card that changes one line without touching the card itself.

Then you put all three ceilings together into one fixed order of checks, so an incident does not come back an hour later.

## Ceiling 3: `TasksMax=`

Raising `TasksMax=` takes three moves: write the sticky note, tell the duty officer to read the cards again, and restart the station. Each move does something different.

### Write the override

<!-- astrona:playground:renew -->

`systemctl edit` opens an editor on a new drop-in file for the unit. Run it as `root`:

```bash
# shell: host, root
sudo systemctl edit data-ingest.service
```

Write these lines in the editor, then save and close it:

```ini
[Service]
TasksMax=200000
```

Apply it, and then check the result:

```bash
sudo systemctl daemon-reload
sudo systemctl restart data-ingest.service
sudo systemctl show data-ingest.service -p TasksMax -p TasksCurrent
```

### Why both `daemon-reload` and `restart`

Neither step is optional, and each does a different job:

- **`daemon-reload`** tells the duty officer to read the duty cards again. systemd parses the unit files from disk into its memory. Without it, systemd does not see a drop-in file you wrote by hand.
- **`restart`** makes the change reach the running station. systemd writes the cgroup limit when it creates the unit's cgroup, at start. `daemon-reload` updates the *plan*. The cgroup that is already running keeps the old `TasksMax` until the unit restarts into a fresh cgroup.

`systemctl edit` already runs a reload for you when you close the editor. Running `daemon-reload` yourself does no harm, and you need it whenever you write a drop-in file by hand. On some systemd versions the reload also updates the running cgroup straight away. The restart makes sure in every case, so always do both.

### Finite or `infinity`

`TasksMax=infinity` removes the per-unit cap completely. Then only the machine-wide pool and the per-user limit apply. On a real server a large finite number is safer. It stops one runaway unit from using up the whole machine's PID space, and that safety rail is the reason `TasksMax=` exists.

### Try it: see why `daemon-reload` alone is not enough

On your playground, raise `data-ingest.service`'s cap with a drop-in you write by hand, so you can watch each step.

Create the drop-in folder:

```sh
sudo mkdir -p /etc/systemd/system/data-ingest.service.d
```

Save this as `/etc/systemd/system/data-ingest.service.d/override.conf`:

```ini
[Service]
TasksMax=200000
```

Before you reload, check what systemd uses:

```sh
systemctl show data-ingest.service -p TasksMax           # still 64 — manager hasn't re-read
```

Apply it to systemd's plan, and compare the plan with the live cgroup:

```sh
sudo systemctl daemon-reload
systemctl show data-ingest.service -p TasksMax           # now the PLAN says 200000
cat /sys/fs/cgroup/system.slice/data-ingest.service/pids.max   # but the live cgroup still says 64
```

Restart the unit, and read the live cgroup again:

```sh
sudo systemctl restart data-ingest.service
cat /sys/fs/cgroup/system.slice/data-ingest.service/pids.max   # now 200000
```

`daemon-reload` updated the plan. The running cgroup's `pids.max`, the kernel's live limit for the group, changed for certain only when `restart` created a fresh cgroup. That is why the fix is *both* commands.

## The triage order

When "cannot fork" lands on your desk, check the ceilings from the widest to the narrowest. Check **all three**, because a fix at one level hides nothing until the real limit also moves:

```
  1. GLOBAL     sysctl -n kernel.pid_max
                vs  ps -eLf | wc -l          → is the whole pool full?

  2. PER-USER   sudo -u <user> bash -c 'ulimit -u'
                                             → is this account capped below what it needs?

  3. PER-UNIT   systemctl show <unit> -p TasksMax,TasksCurrent
                                             → if it's a service, is its cgroup capped
                                               independently of 1 and 2?
```

A diagnosis that looks only at `kernel.pid_max` answers about a third of the question. The other two ceilings tend to show up again at the worst moment. Equally, do not raise a ceiling that is already generous. Change only the ones that are below what the workload needs.

## Common pitfalls

> [!WARNING]
> - **Writing a drop-in by hand without `daemon-reload` and `restart`.** The file on disk does nothing for a cgroup that is already running under the old `TasksMax`.
> - **Raising only `pid_max`.** If the real limit is the per-user or per-service ceiling, the workload recovers only until the next spike, then fails in exactly the same way.
> - **Raising all three by reflex.** If one ceiling is already generous, raising it changes nothing and hides your real diagnosis.

## Your mission: Process & Thread Ceilings Lab

You can now raise every ceiling, live and for good, and apply a `TasksMax=` change to a running service. The mission gives you a workload held back by all three ceilings at once: raise each one to the level the task asks for.

The mission runs on its own training ship. Your playground cannot be paused, so remove it first. It always starts clean, so you lose nothing you need:

```sh
astrona destroy process-limits-ceilings
```

Then start the mission and open a terminal on it:

```sh
astrona run --git git@github.com:astrona-io/ATS002.git -c sections/section-010/module-02/labs/lab-01
astrona ssh ats-002-lab-012
```

Read the task in [`question.md`](./labs/lab-01/question.md) and solve it on your own first. When you think you are done, send it for grading:

```sh
astrona submit -c sections/section-010/module-02/labs/lab-01
```

When the mission is done, remove it and start your playground again:

```sh
astrona destroy ats-002-lab-012
astrona run --git git@github.com:astrona-io/ATS002.git -c sections/section-010/module-02/playground
```

## Your mission: Process Limits: Diagnose the Single Clamp (TasksMax) Lab

You can now follow the triage order and tell a generous ceiling from the one that is really too low. The mission asks you to check all three ceilings on a service that hits a hard task limit, raise only the one that is too low, and apply it to the running service.

The mission runs on its own training ship. Your playground cannot be paused, so remove it first. It always starts clean, so you lose nothing you need:

```sh
astrona destroy process-limits-ceilings
```

Then start the mission and open a terminal on it:

```sh
astrona run --git git@github.com:astrona-io/ATS002.git -c sections/section-010/module-02/labs/lab-03
astrona ssh ats-002-lab-012c
```

Read the task in [`question.md`](./labs/lab-03/question.md) and solve it on your own first. When you think you are done, send it for grading:

```sh
astrona submit -c sections/section-010/module-02/labs/lab-03
```

When the mission is done, remove it and start your playground again:

```sh
astrona destroy ats-002-lab-012c
astrona run --git git@github.com:astrona-io/ATS002.git -c sections/section-010/module-02/playground
```
