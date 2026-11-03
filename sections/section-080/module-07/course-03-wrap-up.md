# Summary

Well flown, astronaut. You have finished every part and the mission in this module. Before you move on, look back at what you learned, check yourself, and clean up anything still running.

## What you learned

This module was about LVM, the system that pools disks into a hold and carves decks out of it, and about repairing a hold whose label was wiped.

**From [The Three LVM Layers](./course-01-the-three-lvm-layers.md):**

- A physical volume is a disk given to LVM, a volume group pools them, and a logical volume is the device that holds the filesystem. `pvs`, `vgs` and `lvs` read the three layers.
- The fifth character of the `lvs` attribute string is `a` when the logical volume is active.
- An inactive logical volume has no device. `vgchange -ay` switches the group on, and nothing is lost.

**From [Restore Lost LVM Metadata](./course-02-restore-lost-lvm-metadata.md):**

- LVM keeps a text backup of every layout in `/etc/lvm/backup` and `/etc/lvm/archive`. `vgcfgrestore --list` shows them.
- A wiped label makes `pvs`, `vgs` and `lvs` show nothing, but the data area is untouched.
- `pvcreate --uuid <UUID> --restorefile <backup> <disk>` writes the old label back. `vgcfgrestore <vg>` restores the layout, and `vgchange -ay <vg>` switches it on.
- Never run `mkfs` to repair. Mount the logical volume and read the files to prove the repair.

## Your missions

You proved these skills in a graded mission, right after the part that taught the last of them:

| Mission | After the part | What you proved |
| --- | --- | --- |
| [LVM Recovery Lab](./labs/lab-01/README.md) | Restore Lost LVM Metadata | Rebuilt a wiped physical volume and its group, and mounted the deck with its files intact |

If you skipped it, go back to it now. The exam asks for exactly these skills.

## Check yourself

Try to answer each question before you open the answer.

<details>
<summary>1. Which command reads the logical volumes, and what does an <code>a</code> in the fifth attribute place mean?</summary>

`lvs`. The `a` means the logical volume is active, so the kernel has built its device.
</details>

<details>
<summary>2. <code>lvs</code> lists the volume but <code>mount</code> says the device does not exist. What do you run?</summary>

`sudo vgchange -ay <vg>`. The volume is inactive, so the group must be switched on.
</details>

<details>
<summary>3. Where does LVM keep the text backup of a volume group's layout?</summary>

In `/etc/lvm/backup/<vg>` for the latest layout, and in `/etc/lvm/archive/` for older ones.
</details>

<details>
<summary>4. Why must you pass <code>--uuid</code> and <code>--restorefile</code> to <code>pvcreate</code> in a recovery?</summary>

Without them LVM writes a new, unrelated label. With them it writes the old label, so `vgcfgrestore` can match the disk to the saved layout.
</details>

<details>
<summary>5. Why must you not run <code>mkfs</code> on the logical volume after the restore?</summary>

The filesystem is still intact. `mkfs` would create a new empty one and destroy the files.
</details>

## Clean up the playground

When you are done with this module, remove the playground and any mission that is still running.

First, see what is still running:

```sh
astrona list
```

Remove the playground. The command takes its **name**, not its folder path:

```sh
astrona destroy lvm-recovery-bench
```

If `astrona list` also showed a mission, remove it the same way, for example:

```sh
astrona destroy ats-002-lab-088
```

Run `astrona list` again to check that everything is gone. You can start the playground again at any time with the `astrona run` command from the module's landing page. It always starts clean, so nothing you broke carries over.

<!-- astrona:playground:destroy -->
