# Solution Walkthrough

## Task 1 — the report timer

```bash
sudo tee /etc/systemd/system/report.service >/dev/null <<'EOF'
[Unit]
Description=Weekly report

[Service]
Type=oneshot
ExecStart=/usr/local/sbin/report.sh
EOF

sudo tee /etc/systemd/system/report.timer >/dev/null <<'EOF'
[Unit]
Description=Run the weekly report

[Timer]
OnCalendar=Mon,Thu 11:15
Persistent=true

[Install]
WantedBy=timers.target
EOF
```

Check the schedule parses to what you meant:

```bash
systemd-analyze calendar 'Mon,Thu 11:15'
#   Normalized form: Mon,Thu *-*-* 11:15:00
```

Load and arm it:

```bash
sudo systemctl daemon-reload
sudo systemctl enable --now report.timer
```

You enable the **`.timer`** — `report.service` stays `dead` between runs,
which is correct for a oneshot.

## Task 2 — convert the dbclean cron job

The cron line is `0 */6 * * * root /usr/local/sbin/dbclean.sh`. Build the
pair:

```bash
sudo tee /etc/systemd/system/dbclean.service >/dev/null <<'EOF'
[Unit]
Description=Database cleanup

[Service]
Type=oneshot
ExecStart=/usr/local/sbin/dbclean.sh
EOF

sudo tee /etc/systemd/system/dbclean.timer >/dev/null <<'EOF'
[Unit]
Description=Run database cleanup every 6 hours

[Timer]
OnCalendar=*-*-* 0/6:00:00
Persistent=true

[Install]
WantedBy=timers.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable --now dbclean.timer
```

`0 */6 * * *` (minute 0, every 6th hour) maps to `OnCalendar=*-*-*
0/6:00:00` — fires at 00:00, 06:00, 12:00, 18:00. `systemd-analyze calendar
'*-*-* 0/6:00:00' --iterations=4` confirms.

**Remove the cron job** — systemd has no dedup either, so leaving both makes
`dbclean.sh` run twice:

```bash
sudo rm /etc/cron.d/dbclean
```

## Verify both

```bash
systemctl list-timers report.timer dbclean.timer
```

```text
NEXT                        LEFT       LAST  PASSED  UNIT            ACTIVATES
Thu 2026-09-11 11:15:00 UTC  2 days     n/a   n/a     report.timer    report.service
Wed 2026-09-09 06:00:00 UTC  3h left    n/a   n/a     dbclean.timer   dbclean.service
```

Force a test run of either service (not the timer):

```bash
sudo systemctl start report.service
journalctl -u report.service -n 5
cat /var/log/maint/report.log
```
