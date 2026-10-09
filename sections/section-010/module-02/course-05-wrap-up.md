# Wrap-Up: Mission Debrief

Well flown, astronaut. You have worked through every part and every mission in this module. Before you move on, look back at what you learned, check yourself, and clean up anything still running.

## What you learned

This module was about the three officers who must all say yes before a new crew member can come aboard.

**From [The Shared PID Pool](./course-01-the-shared-pid-pool.md):**

- Every process and every thread takes one slot from a single pool. Its size is `kernel.pid_max`, which is one more than the highest PID.
- When the pool is full, `fork()` and `clone()` fail with `EAGAIN`, even while CPU and memory sit idle.
- Confirm exhaustion with a healthy `free -m` and `top`, a `fork: … Resource temporarily unavailable` message, and `ps -eLf | wc -l` close to the ceiling.

**From [The Three Independent Ceilings](./course-02-the-three-independent-ceilings.md):**

- A `fork()` must pass `kernel.pid_max` (the whole machine), `RLIMIT_NPROC` / `ulimit -u` (per real user, across all sessions) and `TasksMax=` (per unit cgroup, threads included).
- The lowest ceiling that applies is the real limit, and each ceiling is kept in a different file.
- A unit without its own `TasksMax=` takes `DefaultTasksMax=`, often 15% of `pid_max`, worked out once when systemd starts.

**From [Raising The Kernel And User Ceilings](./course-03-raising-the-kernel-and-user-ceilings.md):**

- Raise `pid_max` with `sysctl -w` now, and with a drop-in under `/etc/sysctl.d/` plus `sysctl --system` for good.
- Raise `ulimit -u` for good with a file under `/etc/security/limits.d/`. `pam_limits` reads it at login, so log in again to see it.
- A service does not go through `pam_limits`. Its per-user limit is `LimitNPROC=` in the unit.

**From [Raising TasksMax And The Triage Order](./course-04-raising-tasksmax-and-the-triage-order.md):**

- Raise `TasksMax=` with a drop-in override, then `daemon-reload` and `restart` so the running cgroup gets the new limit.
- A large finite `TasksMax=` is safer than `infinity` on a real server.
- Check in the order whole machine, user, service, and raise every ceiling that is below what the workload needs, and only those.

## Your missions

You proved each skill in a graded mission, right after the part that taught it:

| Mission | After the part | What you proved |
| --- | --- | --- |
| [Process Limits: Diagnose the Single Clamp (ulimit -u) Lab](./labs/lab-02/README.md) | Raising The Kernel And User Ceilings | found that only the user's `ulimit -u` was too low, and raised just that one for good |
| [Process & Thread Ceilings Lab](./labs/lab-01/README.md) | Raising TasksMax And The Triage Order | raised `kernel.pid_max`, the user's `ulimit -u` and a service's `TasksMax=`, live and for good |
| [Process Limits: Diagnose the Single Clamp (TasksMax) Lab](./labs/lab-03/README.md) | Raising TasksMax And The Triage Order | found that only the service's `TasksMax=` was too low, and raised just that one on the running unit |

If you skipped one, go back to it now. Each mission is short, and the exam asks for exactly these skills.

## Check yourself

Try to answer each question before you open the answer.

<details>
<summary>1. A service runs 500 threads. How many slots of the PID pool does it use?</summary>

About 500. Inside the kernel a thread is a task, and each thread gets its own ID from the same pool as process IDs.
</details>

<details>
<summary>2. <code>kernel.pid_max</code> is <code>32768</code>. What is the highest PID the kernel hands out?</summary>

`32767`. `pid_max` is one more than the largest PID or TID.
</details>

<details>
<summary>3. A job fails with <code>fork: retry: Resource temporarily unavailable</code>, but <code>ps -eLf | wc -l</code> is far below <code>kernel.pid_max</code>. What next?</summary>

The pool is not full, so check the narrower ceilings: the user's `ulimit -u` and, if it runs as a service, the unit's `TasksMax=`.
</details>

<details>
<summary>4. You added a file under <code>/etc/security/limits.d/</code>, but <code>ulimit -u</code> in your open shell still shows the old value. Why?</summary>

`pam_limits` reads the files at login. A session that was open before the edit keeps its old limit. Log in again, or check with `sudo -iu <user> bash -c 'ulimit -u'`.
</details>

<details>
<summary>5. Does a <code>limits.d</code> file raise the process limit of a systemd service?</summary>

No. Services do not go through `pam_limits`. For a service, use `LimitNPROC=` in the unit, or more often raise its `TasksMax=`.
</details>

<details>
<summary>6. You wrote a <code>TasksMax=</code> drop-in by hand and ran only <code>daemon-reload</code>. What else do you need, and why?</summary>

A `restart` of the unit. `daemon-reload` updates systemd's plan. The running cgroup's `pids.max` is set for certain only when the unit starts in a fresh cgroup.
</details>

<details>
<summary>7. Only <code>TasksMax=</code> is too low, but you also raise <code>kernel.pid_max</code> "to be safe". Is that a good idea?</summary>

No. `pid_max` was never the limit, so raising it changes nothing and hides your real diagnosis. Raise only the ceilings that are below what the workload needs.
</details>

## Clean up the playground

Your playground is a whole virtual machine running on your computer. When you are done with this module, remove it, and any mission that is still running.

First, see what is still running:

```sh
astrona list
```

Remove the playground. The command takes its **name**, not its folder path:

```sh
astrona destroy process-limits-ceilings
```

If `astrona list` also showed a mission, remove it the same way, for example:

```sh
astrona destroy ats-002-lab-012c
```

Then run `astrona list` again to check that everything is gone. You can start the playground again at any time. It always starts clean:

```sh
astrona run --git git@github.com:astrona-io/ATS002.git -c sections/section-010/module-02/playground
```

> *Every process and every thread needs a slot in the pool, a place under its user's limit and a place under its service's limit. Check all three, and raise only the one that is really too low.*
