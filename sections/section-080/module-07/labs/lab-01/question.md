# Question

Solve this question on: `terminal`

This machine has a spare disk with the serial `lab088-pv001`. It was used as an LVM physical volume for a volume group `cargo_vg` with one logical volume `deck`. The deck holds an ext4 filesystem with the files `marker.txt` and `logs/flight.log`, which must not be lost. The first megabyte of the disk, which held the LVM label and metadata, was overwritten with zeros, so `pvs`, `vgs` and `lvs` show nothing.

1. Find the spare disk. It is **not** the disk mounted as `/`. Do not assume a device letter such as `/dev/vdb`.
2. Find the LVM metadata backup for `cargo_vg` on this machine and read the UUID of its physical volume.
3. Recreate the physical volume on the spare disk with that same UUID, using the backup file. Do not create a new filesystem.
4. Restore the volume group `cargo_vg` from the backup and activate it.
5. Mount the logical volume `cargo_vg/deck` at `/srv/deck` and confirm that both files are there.

Leave the deck mounted at `/srv/deck` when you finish.

The grader checks that:

- the volume group `cargo_vg` exists on the spare disk, and its physical volume has the original UUID
- the logical volume `cargo_vg/deck` is active
- the deck is mounted at `/srv/deck`, and `marker.txt` and `logs/flight.log` still have their original content
