# Question

Solve this question on: `terminal`, inside the `rpmbox` container. Get a shell with:
```bash
docker exec -it rpmbox bash
```

If Docker answers with a permission error on the lab machine, run the same command with `sudo` in front.

Astronaut, a development team needs a full local build toolchain in one go. `automake` is already installed on this ship, on its own, for an unrelated reason from before this task. Keep that in mind for the last step.

1. **Discover what is offered.** Without relying on memory, list the package groups this ship's configured repositories publish. If a group you expect does not show up in the plain listing, check the complete listing before you decide it does not exist.
2. **Inspect before installing.** Before you install anything, inspect the real members of the `"Development Tools"` group: which packages are mandatory, which are default and which are only optional.
3. **Install the group.** Install `"Development Tools"` as one group operation (mandatory and default members; you do not need `--with-optional` for this task).
4. **Confirm what landed.** Show that the group is now installed, and confirm that at least one core build tool that was *not* there before (for example `gcc`) is now on the system.
5. **Remove the group cleanly as a unit.** The team no longer needs the toolchain on this ship. Remove `"Development Tools"` as a group.
6. **Check the aftermath.** After the removal, find out (do not assume) whether `automake` and `gcc` are still installed. Be ready to explain the two different outcomes in terms of what `dnf` recorded at group install time, not in terms of group membership.

The grader checks the end state inside `rpmbox`: `"Development Tools"` no longer shows as an installed group, `gcc` is not installed, `automake` is still installed, and `dnf check` reports no problems. Do not remove `automake` yourself.
