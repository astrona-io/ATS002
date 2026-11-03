# Summary

Well flown, astronaut. You have finished every part and the mission in this module. Before you move on, look back at what you learned, check yourself, and clean up anything still running.

## What you learned

This module was about one-time jobs, jobs that were missed, and who may use the roster.

**From [One-Shot Jobs With at](./course-01-one-shot-jobs-with-at.md):**

- `at <time>` queues one job. `atq` lists the queue, `at -c <ID>` shows the job and `atrm <ID>` removes it.
- Time words include `now + 5 minutes`, `tomorrow`, `midnight` and `teatime`.
- `batch` runs a job when the load average is below 1.5 by default. The `atd` service runs all the jobs.
- If `/etc/at.allow` exists, only the users in it may use `at`. Otherwise `/etc/at.deny` lists the users who are refused.

**From [anacron And Cron Access Control](./course-02-anacron-and-cron-access-control.md):**

- An `/etc/anacrontab` line has four fields: period in days, delay in minutes, job identifier and command.
- anacron keeps one timestamp file per job in `/var/spool/anacron/`, and `anacron -T` tests the file.
- `run-parts` runs every script in a folder such as `/etc/cron.daily`.
- If `/etc/cron.allow` exists, only the users in it may use `crontab`. If only `/etc/cron.deny` exists, the users in it are refused.

## Your missions

| Mission | After the part | What you proved |
| --- | --- | --- |
| [One-Shot And Missed Jobs Lab](./labs/lab-01/README.md) | anacron And Cron Access Control | queued an `at` job, added an anacron job and refused a user for `crontab` |

If you skipped it, go back to it now.

## Check yourself

Try to answer each question before you open the answer.

<details>
<summary>1. How do you see what an <code>at</code> job will run?</summary>

Find its number with `atq`, then run `at -c <ID>`. The command is at the end of the output.
</details>

<details>
<summary>2. When does <code>batch</code> run a job?</summary>

When the load average drops below 1.5, which is the default limit.
</details>

<details>
<summary>3. What are the four fields of an anacrontab line?</summary>

Period in days, delay in minutes, job identifier and command.
</details>

<details>
<summary>4. Where does anacron remember when a job last ran?</summary>

In a file named after the job identifier in `/var/spool/anacron/`.
</details>

<details>
<summary>5. <code>cron.allow</code> and <code>cron.deny</code> both exist. Which one counts?</summary>

`cron.allow`. Only the users listed there may use `crontab`.
</details>

## Clean up

Your playground is a whole virtual machine running on your computer. When you are done with this module, remove it, and any mission that is still running.

First, see what is still running:

```sh
astrona list
```

Remove the playground. The command takes its **name**, not its folder path:

```sh
astrona destroy at-anacron-bay
```

If `astrona list` also showed the mission, remove it the same way:

```sh
astrona destroy ats-002-lab-024
```

*One card for one time, a catch-up officer for missed days, and a crew list for who may write on the roster.*

<!-- astrona:playground:destroy -->
