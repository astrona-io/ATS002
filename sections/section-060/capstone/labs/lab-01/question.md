# Question

Solve this question inside the `rpmbox` container. Get a shell with:
```bash
docker exec -it rpmbox bash
```

This host was mid-provisioning overnight when a maintenance process got killed partway through. A colleague had already staged `/home/candidate/downloads/metrics-shipper-1.4.0-1.x86_64.rpm` — an internal monitoring agent, not available in any configured repository — before the incident. The team also still needs this host fully set up as a local build server.

1. **Diagnose before you touch anything.** Confirm whether `rpm`'s database is genuinely healthy right now — don't assume either way. If it's not, rule out a real dependency conflict or a disk-space problem first, then check what backend `/var/lib/rpm` actually uses on this system before following any backend-specific instructions.
2. **Repair if needed.** If the database is corrupted, back up the existing database before touching anything, then rebuild it. Confirm the system is back to a clean, queryable state — both `rpm -qa` and `dnf`'s own transaction-check logic.
3. **Handle the staged package.** Before installing `metrics-shipper`, inspect its metadata and file list from the standalone `.rpm` file. Then install it directly with `rpm`, and confirm what it actually placed on the system.
4. **Set up the build toolchain.** Discover what package groups this host's repositories publish, inspect the `"Development Tools"` group's real membership before committing to it, then install the group.
5. **Confirm everything landed.** Show that `metrics-shipper` is installed and its files verify clean against what was recorded at install time, that `"Development Tools"` shows as an installed group with real build tools (like `gcc` and `make`) present, and that `dnf check` reports the whole system consistent.
