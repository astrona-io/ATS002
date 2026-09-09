# Question

Solve this question inside the `rpmbox` container. Get a shell with:
```bash
docker exec -it rpmbox bash
```

Routine maintenance window:

1. Check what's upgradable without applying anything yet.
2. Apply the available upgrades.
3. A security policy update requires `fail2ban`. Simulate a colleague's real-world mistake: install `fail2ban` together with `mtr` in a **single** `dnf install` command, accidentally bundling in a package nobody actually asked for into the same transaction.
4. Separately, `telnet` is no longer needed anywhere on this host — remove it, and clean up any dependency packages that only `telnet` needed and nothing else still requires.
5. Find the transaction from step 3 in `dnf`'s history, confirm what's actually in it, and undo the whole thing as a single unit.
6. Redo just the `fail2ban` install cleanly, on its own, with nothing unrelated bundled in.
