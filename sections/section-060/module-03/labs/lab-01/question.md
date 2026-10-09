# Question

Solve this question on: `terminal`, inside the `rpmbox` container. Get a shell with:
```bash
docker exec -it rpmbox bash
```

If Docker answers with a permission error on the lab machine, run the same command with `sudo` in front.

Astronaut, this is a routine maintenance window. The EPEL repository is already enabled in `rpmbox`.

1. Check what can be upgraded, without applying anything yet.
2. Apply the available upgrades.
3. A security policy update requires `fail2ban`. Act out a colleague's real-world mistake: install `fail2ban` together with `mtr` in a **single** `dnf install` command, so a package nobody asked for lands in the same transaction.
4. Separately, `telnet` is no longer needed anywhere on this ship. Remove it, and clean up any dependency packages that only `telnet` needed and nothing else still requires.
5. Find the transaction from step 3 in `dnf`'s history, confirm what is in it, and undo the whole thing as a single unit.
6. Install `fail2ban` again cleanly, on its own, with nothing unrelated bundled in.

The grader checks the end state inside `rpmbox`: `fail2ban` is installed, `mtr` is not installed, `telnet` is not installed, and `dnf autoremove` has nothing left to remove. Steps 1 and 2 are part of a good maintenance window; the grader does not check them.
