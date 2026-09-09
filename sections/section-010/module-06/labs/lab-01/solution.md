# Solution Walkthrough

## 1. Read the verdict

```bash
systemctl status reportd
```

```text
× reportd.service - Report collection daemon
     Loaded: loaded (/etc/systemd/system/reportd.service; enabled; preset: enabled)
     Active: failed (Result: exit-code) since ...
    Process: 812 ExecStart=/usr/local/bin/reportd (code=exited, status=203/EXEC)
```

`status=203/EXEC` is the specific fingerprint: systemd could not **exec** the
`ExecStart=` program at all. `Loaded: ... enabled` confirms boot wiring is
already fine — only the start is broken.

## 2. Get the evidence

```bash
journalctl -xeu reportd
```

```text
reportd.service: Failed to locate executable /usr/local/bin/reportd: No such file or directory
reportd.service: Failed at step EXEC spawning /usr/local/bin/reportd: No such file or directory
```

The unit points at `/usr/local/bin/reportd`, which does not exist.

## 3. Find the real binary

```bash
systemctl cat reportd            # see the effective ExecStart
which reportd 2>/dev/null; ls -l /usr/local/sbin/reportd /usr/local/bin/reportd 2>&1
```

The daemon is actually at **`/usr/local/sbin/reportd`** — the unit has the
wrong directory (`bin` instead of `sbin`).

## 4. Fix the unit

Use a drop-in (clean, survives package updates):

```bash
sudo systemctl edit reportd
```

```ini
[Service]
ExecStart=
ExecStart=/usr/local/sbin/reportd
```

The empty `ExecStart=` first line is required — `ExecStart=` is a list, so a
bare second line would *append* a second command. Editing the unit file
directly and running `sudo systemctl daemon-reload` is equally valid.

## 5. Apply and verify

```bash
sudo systemctl daemon-reload      # needed if you edited the file by hand; `edit` does it for you
sudo systemctl restart reportd

systemctl is-active reportd       # active
systemctl is-enabled reportd      # enabled
sleep 5
tail -n 3 /var/lib/reportd/heartbeat.log   # new lines appearing
journalctl -u reportd -n 10 --no-pager     # clean, no EXEC errors
```

`is-active` and `is-enabled` answer two separate questions — running now, and
starts on boot. This unit was already `enabled`, so only the start needed
fixing; on a unit that was also `disabled` you would add
`sudo systemctl enable --now reportd`.
