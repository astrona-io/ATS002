# Solution Walkthrough

## 1. See both units, and the dependency

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

`ingest.service` has `Requires=ingest-db.service`. `Requires=` propagates
failure: because `ingest-db` never comes up, `ingest` is pulled straight to
failed, restarts (`Restart=always`), and quickly trips `StartLimitBurst` →
`start-limit-hit`. The **root cause is `ingest-db`**, not `ingest`.

## 2. Fix the root cause — ingest-db's ExecStart

```bash
journalctl -xeu ingest-db
# Failed to locate executable /usr/local/sbin/ingest-db: No such file or directory
ls -l /usr/local/sbin/ | grep -i ingest
```

```text
-rwxr-xr-x 1 root root ... ingestdb          <-- no dash
```

The unit says `ingest-db`, the binary is `ingestdb`. Fix the unit:

```bash
sudo systemctl edit ingest-db
```

```ini
[Service]
ExecStart=
ExecStart=/usr/local/sbin/ingestdb
```

## 3. Clear the flap and start the chain

```bash
sudo systemctl reset-failed ingest.service     # clear 'start-limit-hit'
sudo systemctl start ingest.service            # Requires= pulls in ingest-db
```

Starting `ingest` starts `ingest-db` first (via `Requires=` + `After=`).

## 4. Make it survive a reboot

```bash
sudo systemctl enable ingest-db.service ingest.service
```

`Requires=` guarantees start *order and coupling* at runtime, but it does
**not** enable the dependency — each unit needs its own `enable` for boot.

## 5. Verify

```bash
systemctl is-active ingest-db ingest      # active / active
systemctl is-enabled ingest-db ingest     # enabled / enabled
systemctl show -p SubState -p Result --value ingest    # running / success
sleep 5
tail -n 3 /var/lib/ingest/ingest.log
```
