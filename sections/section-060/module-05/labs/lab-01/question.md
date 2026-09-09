# Question

Solve this question inside the `rpmbox` container. Get a shell with:
```bash
docker exec -it rpmbox bash
```

A development team needs a full local build toolchain in one shot. `automake` is already installed on this host — independently, for an unrelated reason that predates this task. Keep that fact in mind for the last step.

1. **Discover what's actually offered.** Without assuming anything from memory, list what package groups this host's configured repositories currently publish. If a group you'd expect doesn't show up in the plain listing, check the more complete listing before concluding it doesn't exist.
2. **Inspect before installing.** Before installing anything, inspect the `"Development Tools"` group's real membership — which packages are mandatory, which are default, and which are merely optional.
3. **Install the group.** Install `"Development Tools"` as a single group operation (mandatory + default members; you do not need `--with-optional` for this task).
4. **Confirm what landed.** Show that the group is now installed, and confirm at least one core build tool that was *not* present before (e.g. `gcc`) is now on the system.
5. **Remove the group cleanly as a unit.** The team no longer needs the toolchain on this host — remove `"Development Tools"` as a group.
6. **Explain the aftermath.** After the removal, determine — don't just assume — whether `automake` is still installed, and whether `gcc` is still installed. Be prepared to explain, in terms of `dnf`'s own group-removal tracking (not raw group-membership overlap), why those two outcomes are different.
