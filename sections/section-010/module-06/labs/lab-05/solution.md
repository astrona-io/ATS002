# Solution Walkthrough

## 1. See the current state

```bash
journalctl --header | grep -iE 'storage|/run/log|/var/log'
# ... files under /run/log/journal  -> volatile

journalctl --disk-usage
# Archived and active journals take up 24.0M in the file system.  (in /run)
```

## 2. Configure journald

Use a drop-in (clean, does not fight the shipped `journald.conf`):

```bash
sudo mkdir -p /etc/systemd/journald.conf.d
sudo tee /etc/systemd/journald.conf.d/persistent.conf >/dev/null <<'EOF'
[Journal]
Storage=persistent
SystemMaxUse=200M
EOF
```

- `Storage=persistent` — always keep the journal under `/var/log/journal/`,
  creating it if needed (`auto` only persists if the directory already
  exists).
- `SystemMaxUse=200M` — hard ceiling on total on-disk journal size;
  journald rotates and deletes the oldest data to stay under it.

## 3. Apply it

```bash
sudo systemctl restart systemd-journald
```

On restart journald creates `/var/log/journal/<machine-id>/` and starts
writing there. (`sudo systemd-tmpfiles --create --prefix /var/log/journal`
also creates the directory with correct ownership if you prefer to do it
explicitly first.)

## 4. Verify

```bash
ls /var/log/journal/*/                       # system.journal etc. now here
journalctl --header | grep /var/log/journal  # store is persistent
journalctl --disk-usage                      # within 200M
journalctl --verify                          # optional integrity check
```

To reclaim space immediately rather than waiting for rotation:
`sudo journalctl --vacuum-size=150M` or `--vacuum-time=7d`.
