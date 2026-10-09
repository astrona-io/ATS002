# Solution Walkthrough

Each task needs a `.service` that says what to run and a `.timer` that says when. You write the unit files, tell systemd to read them, and then enable and start the **timer**, not the service.

---

## Task 1: the report timer

### Step 1: Write the two unit files

Save this as `/etc/systemd/system/report.service`:

```ini
[Unit]
Description=Weekly report

[Service]
Type=oneshot
ExecStart=/usr/local/sbin/report.sh
```

Save this as `/etc/systemd/system/report.timer`:

```ini
[Unit]
Description=Run the weekly report

[Timer]
OnCalendar=Mon,Thu 11:15
Persistent=true

[Install]
WantedBy=timers.target
```

`report.timer` starts `report.service` because both share the base name `report`. `Persistent=true` makes systemd catch up a run that was missed while the machine was off.

### Step 2: Check the schedule

Check that the schedule means what you meant:

```bash
systemd-analyze calendar 'Mon,Thu 11:15'
#   Normalized form: Mon,Thu *-*-* 11:15:00
```

### Step 3: Load and arm the timer

Apply it:

```bash
sudo systemctl daemon-reload
sudo systemctl enable --now report.timer
```

You enable the **`.timer`**. `report.service` stays `dead` between runs, which is correct for a oneshot service.

---

## Task 2: convert the dbclean cron job

### Step 4: Read the cron line

The cron line in `/etc/cron.d/dbclean` is `0 */6 * * * root /usr/local/sbin/dbclean.sh`: minute 0 of every sixth hour, as root. System services run as root by default, so the service needs no `User=` line.

### Step 5: Write the two unit files

Save this as `/etc/systemd/system/dbclean.service`:

```ini
[Unit]
Description=Database cleanup

[Service]
Type=oneshot
ExecStart=/usr/local/sbin/dbclean.sh
```

Save this as `/etc/systemd/system/dbclean.timer`:

```ini
[Unit]
Description=Run database cleanup every 6 hours

[Timer]
OnCalendar=*-*-* 0/6:00:00
Persistent=true

[Install]
WantedBy=timers.target
```

Apply it:

```bash
sudo systemctl daemon-reload
sudo systemctl enable --now dbclean.timer
```

`0 */6 * * *` (minute 0, every sixth hour) maps to `OnCalendar=*-*-* 0/6:00:00`, which fires at 00:00, 06:00, 12:00 and 18:00. `systemd-analyze calendar '*-*-* 0/6:00:00' --iterations=4` confirms it.

### Step 6: Remove the cron job

systemd does not remove duplicates either, so if you leave both in place, `dbclean.sh` runs twice:

```bash
sudo rm /etc/cron.d/dbclean
```

The grader searches `/etc/crontab`, `/etc/cron.d/` and the per-user crontabs for the word `dbclean`, so remove the whole file, including its comment line.

---

## Step 7: Check both timers

```bash
systemctl list-timers report.timer dbclean.timer
```

```text
NEXT                        LEFT       LAST  PASSED  UNIT            ACTIVATES
Thu 2026-09-11 11:15:00 UTC  2 days     n/a   n/a     report.timer    report.service
Wed 2026-09-09 06:00:00 UTC  3h left    n/a   n/a     dbclean.timer   dbclean.service
```

The dates in this sample are an example; your machine prints its own. Check that both timers are listed and that the ACTIVATES column names the right service.

To test either job, start the service (not the timer):

```bash
sudo systemctl start report.service
journalctl -u report.service -n 5
cat /var/log/maint/report.log
```

`report.sh` adds a line with the time and `report generated` to `/var/log/maint/report.log` on each run, so a new line there proves the service works.

When both timers look right, send the lab for grading:

```sh
astrona submit -c sections/section-020/module-03/labs/lab-01
```
