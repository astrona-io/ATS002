# Question

Solve this question inside the `rpmbox` container. Get a shell with:
```bash
docker exec -it rpmbox bash
```

A colleague ran some package operations late last night and now `dnf`
commands on this host throw a wall of alarming errors. They have already
concluded "the RPM database is corrupted" and are about to run
`rpm --rebuilddb`.

**Check that conclusion before acting.**

1. Reproduce the symptom (`dnf check`) and read what the errors actually
   say — do they complain about *the database*, or about a *package*?
2. Rule out the two things that look like corruption but are not:
   a genuine dependency conflict, and a disk-space problem (`df -h /`).
3. If it is **not** database corruption, do **not** run `rpm --rebuilddb`
   or `rpm --initdb` — that would fix nothing here. Instead, resolve the
   actual problem so `dnf check` passes cleanly again.
4. Confirm the end state: `dnf check` exits `0`, and `rpm -qa` still
   returns a full, clean package list (it was never broken).
