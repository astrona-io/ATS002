# Solution Walkthrough

This walkthrough queues a one-time job, adds an anacron job and refuses a user for `crontab`. After each step you can run `astrona submit` from your own computer to see how far the grader agrees.

---

## Step 1: Check the script and the duty officer

```bash
ls -l /usr/local/sbin/archive-logs.sh
systemctl is-active atd
```

The script is there and `atd`, the service that runs `at` jobs, answers `active`. Without a running `atd`, a queued job would wait for ever.

---

## Step 2: Queue the job for 03:00

```bash
echo /usr/local/sbin/archive-logs.sh | sudo at 03:00
sudo atq
```

`at` reads the command from the pipe and keeps it until the next 03:00. `sudo` makes the job belong to `root`. `atq` shows one line with the job number and a time that reads `03:00:00`.

Check the content of the job. Use your own job number:

```bash
sudo at -c 1
```

The script path is the last line of the output.

Run `astrona submit -c sections/section-020/module-04/labs/lab-01`. The `at` check should pass.

---

## Step 3: Add the anacron job

Add this line at the end of `/etc/anacrontab`. Open it with `sudo nano /etc/anacrontab`:

```text
7	10	weekly-archive	/usr/local/sbin/archive-logs.sh
```

The four fields are the period in days (`7`), the delay in minutes (`10`), the job identifier (`weekly-archive`) and the command. Test the file:

```bash
sudo anacron -T
```

It prints nothing when the file is fine. Run `astrona submit` again. The anacrontab check should pass.

---

## Step 4: Refuse ops-monitor for crontab

Save this as `/etc/cron.deny`:

```text
ops-monitor
```

Then check the result:

```bash
ls /etc/cron.allow
sudo -u ops-monitor crontab -l
```

The first command reports that `/etc/cron.allow` does not exist, which is what you want. If it existed, only the users listed in it could use `crontab`. The second command shows that `ops-monitor` is not allowed to use `crontab`.

Run `astrona submit` a last time. All three checks should pass.

---

## Command Summary

```bash
echo /usr/local/sbin/archive-logs.sh | sudo at 03:00
sudo atq
sudo at -c 1
sudo nano /etc/anacrontab    # add: 7  10  weekly-archive  /usr/local/sbin/archive-logs.sh
sudo anacron -T
sudo nano /etc/cron.deny     # add: ops-monitor
sudo -u ops-monitor crontab -l
```
