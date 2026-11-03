# Question

Solve this question on: `terminal`, inside the `rpmbox` container. Get a shell with:
```bash
docker exec -it rpmbox bash
```

If Docker answers with a permission error on the lab machine, run the same command with `sudo` in front.

Astronaut, this ship was halfway through being set up overnight when a maintenance process was killed partway through. Before the incident, a colleague had already placed `/home/candidate/downloads/metrics-shipper-1.4.0-1.x86_64.rpm` on the ship. It is an internal monitoring agent, and no configured repository has it. The team also still needs this ship fully set up as a local build server.

1. **Diagnose before you touch anything.** Find out whether `rpm`'s database is really healthy right now; do not assume either way. If it is not, first rule out a real dependency problem and a disk-space problem, then check which backend `/var/lib/rpm` uses on this system before you follow any backend-specific advice.
2. **Repair if needed.** If the database is corrupted, back up the existing database before you change anything, then rebuild it. Confirm the system is back to a clean, queryable state, with both `rpm -qa` and `dnf`'s own consistency check.
3. **Handle the waiting package.** Before you install `metrics-shipper`, inspect its details and file list from the `.rpm` file. Then install it directly with `rpm`, and confirm what it placed on the system.
4. **Set up the build toolchain.** Find out which package groups this ship's repositories publish, inspect the real members of the `"Development Tools"` group before you commit to it, then install the group.
5. **Confirm everything landed.** Show that `metrics-shipper` is installed and its files verify clean against the install-time record, that `"Development Tools"` shows as an installed group with real build tools (such as `gcc` and `make`) present, and that `dnf check` reports the whole system consistent.

The grader checks the end state inside `rpmbox`: `rpm -qa` succeeds with no error text and at least 20 packages; `metrics-shipper-1.4.0-1.x86_64` is installed and `rpm -V metrics-shipper` prints nothing; `"Development Tools"` shows as an installed group and `gcc` and `make` are installed; and `dnf check` succeeds.
