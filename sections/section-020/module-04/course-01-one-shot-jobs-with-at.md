# One-Shot Jobs With at

Astronaut, a cron job is a standing order that repeats. An `at` job is a single order card: do this once, at this time, then forget it. This part shows how to write the card, check the queue and tear a card up.

## Queue your first job

The `at` command reads commands and keeps them until the time you name. The `atd` service, the duty officer for these cards, runs them when the time comes.

<!-- astrona:playground:renew -->

### See it in your playground

Check that the duty officer is on watch:

```bash
# shell: any user
systemctl is-active atd
```

The answer is `active`. Now queue a job for two minutes from now:

```bash
# shell: any user
echo 'date >> ~/at-demo.txt' | at now + 2 minutes
```

`at` prints a line with the job number and the time it will run. It also prints a warning that it uses `/bin/sh`. That is normal: `at` runs your commands with `sh`, not `bash`.

## Look at the queue

`atq` lists the cards that wait. Each line holds the job number, the run time, a queue letter and the owner.

### See it in your playground

List the queue, then show what the job will do:

```bash
# shell: same user
atq
at -c 1
```

Use the job number from your own `atq` output in place of `1`. `at -c` prints the whole job. You see the environment that `at` saved from your shell, and your command at the very end. That saved environment is why a job runs with the same variables you had when you queued it.

Remove the job again:

```bash
# shell: same user
atrm 1
atq
```

The queue is now empty, because `atrm` removed the job.

## Time words that `at` understands

You can write the time in many ways. The next table shows the ones to know.

| You write | It means |
| --- | --- |
| `at 03:00` | The next time the clock reads 03:00 |
| `at now + 30 minutes` | Thirty minutes from now. Units are `minutes`, `hours`, `days` and `weeks` |
| `at 14:30 tomorrow` | Tomorrow at 14:30 |
| `at midnight` / `at noon` / `at teatime` | 00:00, 12:00 and 16:00 |
| `at 10am Dec 24` | A date with a time |

You can also keep the commands in a file and queue it with `at -f /path/to/file 03:00`.

## What happens to the output

A job has no terminal. Anything it prints is sent as mail to the user who queued it. If the ship has no mail system, that output is lost. So write results to a file yourself, as the demo did with `>> ~/at-demo.txt`.

## batch: run when the ship is quiet

`batch` is `at` with no time. It runs the job when the load average falls below 1.5. The load average is a gauge of how busy the reactor is. This is the default limit of the `atd` service.

```bash
# shell: any user
echo 'sleep 1' | batch
atq
```

The job waits in the queue and starts when the load is low enough. `at -b` does the same.

## Who may use at

Two files decide who may queue jobs. `/etc/at.allow` lists the users who may. If it exists, only those users may use `at`. If it does not exist, `/etc/at.deny` lists the users who are refused. A user who is refused sees a message such as "You do not have permission to use at".

Each file holds one user name per line. Look at them on your machine:

```bash
# shell: any user
ls -l /etc/at.allow /etc/at.deny
```

Do not worry if one of them is missing. The rules above say which file counts.

## Common pitfalls

> [!WARNING]
> - **Expecting `bash` features.** `at` runs the job with `/bin/sh`. Arrays and other `bash` extras may fail.
> - **Losing the output.** Without a mail system, printed output is thrown away. Redirect to a file.
> - **Checking the wrong queue.** `atq` as a normal user shows only your own jobs. Root sees all of them.
> - **Forgetting `atd`.** If the service is not running, jobs wait forever. Check with `systemctl is-active atd`.

*`at` queues one job for one time, `atq` shows the queue, `atrm` removes a job, and `batch` waits for a quiet reactor.*
