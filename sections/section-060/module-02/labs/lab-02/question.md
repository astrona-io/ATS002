# Question

Solve this question on: `terminal`, inside the `rpmbox` container. Get a shell with:
```bash
docker exec -it rpmbox bash
```

If Docker answers with a permission error on the lab machine, run the same command with `sudo` in front.

Astronaut, a colleague ran some package operations late last night. Now `dnf` commands on this ship throw a wall of alarming errors. The colleague has already decided that "the RPM database is corrupted" and is about to run `rpm --rebuilddb`.

**Check that conclusion before you act.**

1. Reproduce the symptom with `dnf check`, and read what the errors actually say. Do they complain about *the database*, or about a *package*?
2. Rule out the two things that look like corruption but are not: a real dependency problem, and a disk-space problem (`df -h /`).
3. If it is **not** database corruption, do **not** run `rpm --rebuilddb` or `rpm --initdb`; that would fix nothing here. Instead, fix the actual problem so that `dnf check` passes cleanly again.
4. Confirm the end state: `dnf check` exits `0`, and `rpm -qa` still returns a full, clean package list (it was never broken).

The grader checks that `dnf check` succeeds inside `rpmbox`, that `rpm -qa` succeeds with no error text and at least 20 packages, and that the broken dependency is really closed: either the missing package is installed again, or the package that needed it was removed.
