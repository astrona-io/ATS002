# Solution Walkthrough

The unit that shows the loudest error is not the broken one. Follow the `Requires=` chain to the bottom, fix that unit, clear the restart limit, and enable both units.

## 1. See both units, and the dependency

Read the summary of both units and the dependency tree:

```bash
systemctl status ingest
systemctl status ingest-db
systemctl list-dependencies ingest
```

```text
ingest.service: Failed with result 'start-limit-hit'.
ingest.service: Start request repeated too quickly.
...
× ingest-db.service - Ingest database backend
    Process: ... ExecStart=/usr/local/sbin/ingest-db (code=exited, status=203/EXEC)
```

`ingest.service` has `Requires=ingest-db.service`. `Requires=` passes failure along: because `ingest-db` never comes up, `ingest` is pulled straight to `failed`. It restarts (`Restart=always`) and quickly hits its `StartLimitBurst`, which ends in `start-limit-hit`. The **root cause is `ingest-db`**, not `ingest`.

## 2. Fix the root cause: the `ExecStart` of ingest-db

Read the journal of `ingest-db`, then look for the real program:

```bash
journalctl -xeu ingest-db
# Failed to locate executable /usr/local/sbin/ingest-db: No such file or directory
ls -l /usr/local/sbin/ | grep -i ingest
```

```text
-rwxr-xr-x 1 root root ... ingestdb          <-- no dash
```

The unit says `ingest-db`, but the program is called `ingestdb`. Fix the unit with a drop-in. `sudo systemctl edit ingest-db` opens the drop-in file `/etc/systemd/system/ingest-db.service.d/override.conf` in an editor:

```bash
sudo systemctl edit ingest-db
```

Save this content in the editor, then close it:

```ini
[Service]
ExecStart=
ExecStart=/usr/local/sbin/ingestdb
```

The empty `ExecStart=` line clears the old command first. `systemctl edit` runs `daemon-reload` for you when you save.

## 3. Clear the restart limit and start the chain

The `start-limit-hit` state stays until you clear it:

```bash
sudo systemctl reset-failed ingest.service     # clear 'start-limit-hit'
sudo systemctl start ingest.service            # Requires= pulls in ingest-db
```

Starting `ingest` starts `ingest-db` first, because of `Requires=` together with `After=`.

## 4. Make it survive a reboot

Enable both units:

```bash
sudo systemctl enable ingest-db.service ingest.service
```

`Requires=` ties the two units together at run time, but it does **not** enable the dependency. Each unit needs its own `enable` to start at boot.

## 5. Verify

Prove every requirement:

```bash
systemctl is-active ingest-db ingest      # active / active
systemctl is-enabled ingest-db ingest     # enabled / enabled
systemctl show -p SubState -p Result --value ingest    # running / success
sleep 5
tail -n 3 /var/lib/ingest/ingest.log
```

The grader checks that both units are active and enabled, that `ingest` has `SubState` `running` and `Result` `success`, that the `ExecStart=` of `ingest-db` points at a file that can be run, and that `ingest.log` keeps growing. When all of that holds, send it for grading:

```sh
astrona submit -c sections/section-010/module-06/labs/lab-04
```
