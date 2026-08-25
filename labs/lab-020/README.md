# lab-020: Scheduled Container Recovery

QEMU VM for the LFCS course — the Section 020 capstone. Retire a decommissioned container squatting on a needed port, launch its constrained replacement, and schedule a per-user cron job that automatically restarts it if it ever stops.

## Run

```bash
astrona run --git git@github.com:astrona-io/ATS002.git -c labs/lab-020
```
