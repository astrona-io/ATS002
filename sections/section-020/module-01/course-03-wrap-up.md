# Wrap-Up: Mission Debrief

Well flown, astronaut. You have finished both parts and the mission in this module. Before you move on, look back at what you learned, check yourself, and clean up anything still running.

## What you learned

This module was about where the `cron` daemon finds its standing orders, how the line format changes with the place, and how to move a job without losing it or doubling it.

**From [Where A Cron Job Lives](./course-01-where-a-cron-job-lives.md):**

- The `cron` daemon checks the per-user spool (`/var/spool/cron/crontabs/<user>`), `/etc/crontab` and `/etc/cron.d/*` once a minute. The `/etc/cron.daily/` style folders hold scripts that `run-parts` runs, not cron lines.
- System-wide lines have six fields: five time fields, then the username, then the command. Per-user lines have five time fields and then the command.
- A username pasted into a per-user crontab becomes the command name, and the job fails without a word.
- Each time field takes a value, a list (`TUE,FRI`), a range (`1-5`), a step (`*/10`) or a name. `@daily` and the other `@` shortcuts replace all five fields.

**From [Migrating A Job Safely](./course-02-migrating-a-job-safely.md):**

- `sudo crontab -u <user> -e` edits that account's crontab. Plain `crontab -e` as root edits root's own.
- `crontab -e` checks the syntax on save and installs the file with the right owner, group and mode. Editing the spool file by hand skips all of that.
- The safe order is: recreate, check with `crontab -u <user> -l`, delete the original, and search again with `grep -rn`.
- Cron never removes duplicates, so a job left in both places runs twice.

## Your missions

You proved these skills in a graded mission, right after the part that taught the last of them:

| Mission | After the part | What you proved |
| --- | --- | --- |
| [Per-User Cron Job Scheduling Lab](./labs/lab-01/README.md) | Migrating A Job Safely | moved a system-wide job into a service account's crontab, added a two-day weekly job, and removed the original |

If you skipped it, go back to it now. It is short, and the exam asks for exactly these skills.

## Check yourself

Try to answer each question before you open the answer.

<details>
<summary>1. Which places does the cron daemon read cron lines from on Ubuntu?</summary>

The per-user spool files in `/var/spool/cron/crontabs/`, the single file `/etc/crontab`, and the drop-in files in `/etc/cron.d/`. The folders such as `/etc/cron.daily/` hold scripts that `run-parts` runs, not cron lines.
</details>

<details>
<summary>2. Why may only root edit <code>/etc/crontab</code> and <code>/etc/cron.d/</code>?</summary>

Their lines carry a username field, so one line can run any command as any account on the machine.
</details>

<details>
<summary>3. You paste <code>0 22 * * * archivist /home/archivist/archive-logs.sh</code> unchanged into the <code>archivist</code> crontab. What happens at 22:00?</summary>

Cron reads `archivist` as the command and tries to run a program with that name. It fails, and nothing tells you. Remove the username field from per-user lines.
</details>

<details>
<summary>4. Write a per-user cron line that runs <code>/opt/tools/check.sh</code> at 07:30 every Monday and Wednesday.</summary>

`30 7 * * MON,WED /opt/tools/check.sh`. Minute first, then the hour on a 24-hour clock, then `*` for day of month and month, then the weekday list.
</details>

<details>
<summary>5. You are root. Which command opens the crontab of the account <code>dataproc</code>?</summary>

`sudo crontab -u dataproc -e` (or `crontab -u dataproc -e` when you are already root). Without `-u`, you edit root's own crontab.
</details>

<details>
<summary>6. Why should you not edit <code>/var/spool/cron/crontabs/&lt;user&gt;</code> with a text editor?</summary>

You skip the syntax check, and the file may be saved with the wrong owner or mode. Cron then stops trusting it and its jobs never run.
</details>

<details>
<summary>7. In which order do you move a job from <code>/etc/cron.d/</code> into a user's crontab?</summary>

Recreate it in the user's crontab, check it with `crontab -u <user> -l`, delete the original, then search `/etc/crontab` and `/etc/cron.d/` again with `grep -rn` and expect no output.
</details>

## Clean up

Each mission runs a virtual machine on your computer. When you are done with this module, remove any mission that is still running.

First, see what is still running:

```sh
astrona list
```

If the mission is still there, remove it. The command takes its **name**, not its folder path:

```sh
astrona destroy ats-002-lab-021
```
