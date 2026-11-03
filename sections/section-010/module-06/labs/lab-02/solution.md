# Solution Walkthrough

Read the verdict, read the evidence, confirm who is denied what, then give the service's own user access and prove the fix.

## 1. Read the verdict

Ask `systemd` for its summary of the unit:

```bash
systemctl status metricsd
```

```text
× metricsd.service - Metrics sampling daemon
     Active: failed (Result: exit-code) since ...
    Process: 901 ExecStart=/usr/local/sbin/metricsd (code=exited, status=1/FAILURE)
```

`status=1/FAILURE` means the program *ran* and returned an error of its own. That is different from `203/EXEC`, where `systemd` could not run the program at all. So the cause is in the program's own log lines.

## 2. Get the evidence

Read the unit's journal:

```bash
journalctl -xeu metricsd
```

```text
metricsd[901]: metricsd: cannot open /var/lib/metricsd/metrics.log: Permission denied
```

## 3. Confirm the access problem

Check which user the service runs as, and who owns the folder:

```bash
systemctl show -p User --value metricsd     # metricsd
ls -ld /var/lib/metricsd
```

```text
drwxr-xr-x 2 root root 4096 ... /var/lib/metricsd
```

The unit runs as `metricsd`, but `/var/lib/metricsd` is owned by `root:root` with mode `0755`. Only `root` may write there, so the `metricsd` user has no write access. Ordinary file permissions are the problem, and `ls -ld` shows it plainly.

## 4. Fix: give the service user access to its own folder

The direct fix is to hand the folder to the service's user:

```bash
sudo chown -R metricsd:metricsd /var/lib/metricsd
sudo chmod 0750 /var/lib/metricsd
```

A fix that uses `systemd` itself is also accepted: let `systemd` manage the folder. `sudo systemctl edit metricsd` opens the drop-in file `/etc/systemd/system/metricsd.service.d/override.conf` in an editor. Save this content in it:

```ini
[Service]
StateDirectory=metricsd
```

`StateDirectory=metricsd` tells `systemd` to create `/var/lib/metricsd` owned by the service's user every time the service starts. If the folder already exists with another owner, as it does here, `systemd` changes its owner to the service's user. `systemctl edit` runs `daemon-reload` for you when you save.

## 5. Apply and verify

Restart the service, then prove that it runs, is enabled, is still non-root and really writes:

```bash
sudo systemctl restart metricsd
systemctl is-active metricsd      # active
systemctl is-enabled metricsd     # enabled
systemctl show -p User --value metricsd   # still 'metricsd', not root
sleep 5
tail -n 3 /var/lib/metricsd/metrics.log
```

The daemon now writes its log every few seconds, still as a user without special rights. If the unit had also been `disabled`, you would finish with `sudo systemctl enable --now metricsd`.

The grader checks that the unit is active and enabled, that its `User=` is set and is not `root`, and that `metrics.log` keeps growing. When all of that holds, send it for grading:

```sh
astrona submit -c sections/section-010/module-06/labs/lab-02
```
