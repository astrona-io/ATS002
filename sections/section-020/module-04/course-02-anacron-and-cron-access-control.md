# anacron And Cron Access Control

Astronaut, cron runs standing orders only while the ship is switched on. If the ship was off at 02:00, the order is skipped. `anacron` is the catch-up officer: when the ship starts, it checks which orders are overdue and runs them. This part also shows how to decide which users may write on the roster at all.

## How anacron works

`anacron` does not care about the clock time. It cares about days. For each job it asks: "How many days since this last ran?" If the answer is greater than the job's period, it runs the job.

### See it in your playground

Look at the file that holds the jobs:

<!-- astrona:playground:renew -->

```bash
# shell: any user
cat /etc/anacrontab
```

Every job line has four fields:

| Field | Meaning |
| --- | --- |
| Period | Days between runs. `1`, `7` and `30` are common. Words such as `@daily`, `@weekly` and `@monthly` also work |
| Delay | Minutes to wait after anacron starts before the job runs |
| Job identifier | A short name. It names the timestamp file and appears in the log |
| Command | What to run |

Lines that start with `#` are comments. Lines such as `SHELL=` or `PATH=` set variables for all the jobs.

### Add a weekly job

Add this line at the end of `/etc/anacrontab`. Use `sudo nano /etc/anacrontab` or another editor:

```text
7	10	weekly-archive	/usr/local/sbin/archive-logs.sh
```

The fields are separated by tabs or spaces. This job runs every 7 days, 10 minutes after anacron starts. Test the file for mistakes:

```bash
# shell: any user with sudo
sudo anacron -T
```

`anacron -T` tests the file only. It prints nothing and exits with success when the file is fine.

### Where the timestamps live

After a job runs, anacron writes the date into a file named after the job identifier:

```bash
# shell: any user with sudo
sudo ls -l /var/spool/anacron/
```

On a real run, the file `weekly-archive` appears here. The next run compares today with that date. If you delete a timestamp file, anacron treats the job as never run, and runs it at the next start.

## Where run-parts and cron.daily fit

The folders `/etc/cron.daily`, `/etc/cron.weekly` and `/etc/cron.monthly` hold plain scripts. The program `run-parts` runs every executable script in one folder. On Ubuntu, `/etc/anacrontab` calls `run-parts` for these folders. The standard `/etc/crontab` calls it only when `anacron` is not installed, so the scripts do not run twice.

## Who may use crontab

Two files control access to the `crontab` command. `/etc/cron.allow` lists the users who may use it. If that file exists, only the listed users may. If only `/etc/cron.deny` exists, the listed users are refused and everyone else may use it.

### Refuse a user

Save this as `/etc/cron.deny`:

```text
ops-monitor
```

One user name per line. Then check the result:

```bash
# shell: any user with sudo
sudo -u ops-monitor crontab -l
```

`crontab` refuses with a message that the user is not allowed to use this program. Remove the file again when you finish your own tests, unless a task tells you to keep it.

## Your mission: One-Shot And Missed Jobs Lab

You can now queue one-time jobs, add an anacron job, and refuse a user for cron. The mission asks you to do all three with a log-archiving script.

First, pause your playground:

```sh
astrona stop at-anacron-bay
```

Then start the mission and open a terminal on it:

```sh
astrona run --git git@github.com:astrona-io/ATS002.git -c sections/section-020/module-04/labs/lab-01
astrona ssh ats-002-lab-024
```

Read the task in [`question.md`](./labs/lab-01/question.md) and solve it on your own first. When you think you are done, send it for grading:

```sh
astrona submit -c sections/section-020/module-04/labs/lab-01
```

When the mission is done, remove it and start your playground again:

```sh
astrona destroy ats-002-lab-024
astrona start at-anacron-bay
```

## Common pitfalls

> [!WARNING]
> - **A wrong number of fields.** An anacrontab line needs all four fields. Run `anacron -T` after every edit.
> - **Expecting a fixed time.** anacron runs a job some minutes after it starts, not at a clock time. Use cron for exact times.
> - **Creating `cron.allow` by accident.** Once that file exists, only the users in it may use `crontab`. A `cron.deny` file is then ignored.
> - **Wrong file name.** The files are `cron.allow` and `cron.deny`, without an extension, in `/etc`.

*anacron catches up on jobs by days, `/etc/anacrontab` has four fields per job, and `cron.allow` beats `cron.deny`.*
