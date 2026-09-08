# Solution Walkthrough

## 1. Read the verdict

```bash
systemctl status metricsd
```

```text
× metricsd.service - Metrics sampling daemon
     Active: failed (Result: exit-code) since ...
    Process: 901 ExecStart=/usr/local/sbin/metricsd (code=exited, status=1/FAILURE)
```

`status=1/FAILURE` — the program *ran* and returned an error of its own
(contrast with lab-01's `203/EXEC`, where it could not run at all). So the
cause is in the program's own logs.

## 2. Get the evidence

```bash
journalctl -xeu metricsd
```

```text
metricsd[901]: metricsd: cannot open /var/lib/metricsd/metrics.log: Permission denied
```

## 3. Confirm the access problem

```bash
systemctl show -p User --value metricsd     # metricsd
ls -ld /var/lib/metricsd
```

```text
drwxr-xr-x 2 root root 4096 ... /var/lib/metricsd
```

The unit runs as `metricsd`, but `/var/lib/metricsd` is owned `root:root` and
mode `0755` — the `metricsd` user has no write access. DAC is the problem;
`ls -ld` shows it plainly.

## 4. Fix — grant the service user access to its own state dir

The direct fix:

```bash
sudo chown -R metricsd:metricsd /var/lib/metricsd
sudo chmod 0750 /var/lib/metricsd
```

The more idiomatic systemd fix (also acceptable) is to let systemd own the
directory lifecycle — add to the unit via `sudo systemctl edit metricsd`:

```ini
[Service]
StateDirectory=metricsd
```

`StateDirectory=metricsd` makes systemd create `/var/lib/metricsd` with the
service user as owner on every start. (If you use this, the pre-existing
root-owned directory should be removed first so systemd can recreate it.)

## 5. Apply and verify

```bash
sudo systemctl restart metricsd
systemctl is-active metricsd      # active
systemctl is-enabled metricsd     # enabled
systemctl show -p User --value metricsd   # still 'metricsd', not root
sleep 5
tail -n 3 /var/lib/metricsd/metrics.log
```

The daemon now writes its log every few seconds, still as an unprivileged
user. If it had also been `disabled`, finish with
`sudo systemctl enable --now metricsd`.
