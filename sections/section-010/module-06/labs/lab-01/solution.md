# Solution Walkthrough

The order is the same for every service that will not start: read the verdict, read the evidence, find the cause, fix it, then prove the fix.

## 1. Read the verdict

Ask the duty officer (`systemd`) for its summary of the unit:

```bash
systemctl status reportd
```

```text
× reportd.service - Report collection daemon
     Loaded: loaded (/etc/systemd/system/reportd.service; enabled; preset: enabled)
     Active: failed (Result: exit-code) since ...
    Process: 812 ExecStart=/usr/local/bin/reportd (code=exited, status=203/EXEC)
```

`status=203/EXEC` is the key fingerprint. `systemd` could not **run** (execute) the `ExecStart=` program at all, so the program never started. `Loaded: ... enabled` shows that the unit is already wired for boot. Only the start is broken.

## 2. Get the evidence

Read the unit's journal, jumping to the newest lines with an explanation:

```bash
journalctl -xeu reportd
```

```text
reportd.service: Failed to locate executable /usr/local/bin/reportd: No such file or directory
reportd.service: Failed at step EXEC spawning /usr/local/bin/reportd: No such file or directory
```

The unit points at `/usr/local/bin/reportd`, and that file does not exist.

## 3. Find the real program

Show the effective unit, then look for the program on disk:

```bash
systemctl cat reportd            # see the effective ExecStart
which reportd 2>/dev/null; ls -l /usr/local/sbin/reportd /usr/local/bin/reportd 2>&1
```

`ls` lists `/usr/local/sbin/reportd` and reports that `/usr/local/bin/reportd` does not exist. The daemon is really at **`/usr/local/sbin/reportd`**. The unit names the wrong folder: `bin` instead of `sbin`.

## 4. Fix the unit

Use a drop-in: a small override file that changes only the start command and survives package updates. `sudo systemctl edit reportd` opens the drop-in file `/etc/systemd/system/reportd.service.d/override.conf` in an editor. Run it:

```bash
sudo systemctl edit reportd
```

Save this content in the editor, then close it:

```ini
[Service]
ExecStart=
ExecStart=/usr/local/sbin/reportd
```

The empty `ExecStart=` line is required. `ExecStart=` holds a list of commands, so a single new line would *add* a second command instead of replacing the wrong one. When you save, `systemctl edit` runs `daemon-reload` for you.

Editing `/etc/systemd/system/reportd.service` directly and then running `sudo systemctl daemon-reload` works just as well.

## 5. Apply and verify

Restart the service, then prove that it runs, is enabled and really works:

```bash
sudo systemctl daemon-reload      # needed if you edited the file by hand; `edit` does it for you
sudo systemctl restart reportd

systemctl is-active reportd       # active
systemctl is-enabled reportd      # enabled
sleep 5
tail -n 3 /var/lib/reportd/heartbeat.log   # new lines appearing
journalctl -u reportd -n 10 --no-pager     # clean, no EXEC errors
```

`is-active` and `is-enabled` answer two separate questions: is it running now, and will it start at boot? This unit was already `enabled`, so only the start needed fixing. On a unit that was also `disabled`, you would add `sudo systemctl enable --now reportd`.

The grader checks that the unit is active and enabled, that its `ExecStart=` points at a file that can be run, and that `heartbeat.log` keeps growing. When all of that holds, send it for grading:

```sh
astrona submit -c sections/section-010/module-06/labs/lab-01
```
