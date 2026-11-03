# Question

Solve this question on: `terminal`, inside the `rpmbox` container. Get a shell with:
```bash
docker exec -it rpmbox bash
```

If Docker answers with a permission error on the lab machine, run the same command with `sudo` in front.

Astronaut, something happened to this ship overnight. Assume a terminal session was killed in the middle of a transaction during a late maintenance window. It left the RPM database in `/var/lib/rpm` inconsistent. The files of every installed package are untouched and fine.

1. Confirm that this really is database corruption, and not a dependency problem or a disk-space problem.
2. Check which backend `/var/lib/rpm` uses on this system before you follow any backend-specific advice.
3. Back up the existing database before you change anything.
4. Rebuild it.
5. Prove the system is back to a clean, queryable state, with both `rpm -qa` and `dnf`'s own consistency check.

The grader checks that `rpm -qa` inside `rpmbox` succeeds, prints no error text and lists at least 20 packages, and that `dnf check` succeeds.
