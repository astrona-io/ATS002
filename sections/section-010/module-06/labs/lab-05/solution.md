# Solution Walkthrough

Look at where the journal lives now, write the two settings in a drop-in file, restart the log keeper, and check that it writes to disk.

## 1. See the current state

Check where the journal files are and how much space they use:

```bash
journalctl --header | grep -iE 'storage|/run/log|/var/log'
# ... files under /run/log/journal  -> volatile

journalctl --disk-usage
# Archived and active journals take up 24.0M in the file system.  (in /run)
```

The journal files are under `/run/log/journal`, which lives in memory. That is why the log is lost at every reboot.

## 2. Configure journald

Use a drop-in file. It keeps your settings apart from the shipped `journald.conf`. First create the folder for it:

```bash
sudo mkdir -p /etc/systemd/journald.conf.d
```

Save this as `/etc/systemd/journald.conf.d/persistent.conf`:

```ini
[Journal]
Storage=persistent
SystemMaxUse=200M
```

- `Storage=persistent` always keeps the journal under `/var/log/journal/`, and creates that folder if it is missing. (`auto` only keeps it on disk if the folder already exists.)
- `SystemMaxUse=200M` is the upper limit for the journal's total size on disk. `journald` deletes the oldest archived files to stay under it.

## 3. Apply it

`journald` reads its settings when it starts, so restart it:

```sh
sudo systemctl restart systemd-journald
```

When it starts again, `journald` creates `/var/log/journal/<machine-id>/` and writes there. If you want to create the folder yourself first, with the right owner and permissions, `sudo systemd-tmpfiles --create --prefix /var/log/journal` does that too.

## 4. Verify

Then check the result:

```bash
ls /var/log/journal/*/                       # system.journal etc. now here
journalctl --header | grep /var/log/journal  # store is persistent
journalctl --disk-usage                      # within 200M
journalctl --verify                          # optional integrity check
```

To free space at once instead of waiting for `journald` to clean up, run `sudo journalctl --vacuum-size=150M` or `sudo journalctl --vacuum-time=7d`.

The grader checks that `/var/log/journal` holds journal files, that `journald.conf` or a drop-in sets `Storage=persistent` and a `SystemMaxUse=` of 200 MB or less, and that `journalctl --disk-usage` answers. When all of that holds, send it for grading:

```sh
astrona submit -c sections/section-010/module-06/labs/lab-05
```
