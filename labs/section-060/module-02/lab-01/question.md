# Question

Solve this question inside the `rpmbox` container. Get a shell with:
```bash
docker exec -it rpmbox bash
```

Something happened to this box overnight — assume a terminal session was killed mid-transaction during a late-night maintenance window, leaving the RPM database in `/var/lib/rpm` inconsistent, even though every already-installed package's actual files on disk are untouched and fine.

1. Confirm this is genuinely database corruption, not a real dependency conflict or a disk-space problem.
2. Check what backend `/var/lib/rpm` is actually using on this system before following any backend-specific instructions.
3. Back up the existing database before touching anything.
4. Rebuild it.
5. Verify the system is back to a clean, queryable state — both `rpm -qa` and `dnf`'s own transaction-check logic.
