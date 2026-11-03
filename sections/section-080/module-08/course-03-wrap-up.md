# Summary

Well flown, astronaut. You have finished every part and the mission in this module. Before you move on, look back at what you learned, check yourself, and clean up anything still running.

## What you learned

This module was about software RAID with `mdadm`: a mirror that keeps the same cargo in two bays, and replacing a bay that failed.

**From [Reading A RAID Array](./course-01-reading-a-raid-array.md):**

- RAID 1 writes every block to both members, so the array survives the loss of one disk.
- `/proc/mdstat` is the quick check. `[UU]` is healthy and `[U_]` or `[_U]` is degraded.
- `mdadm --detail <array>` gives the state, the counts of active and failed devices and the table of members. `mdadm --examine <disk>` reads the md label on one member.
- `mdadm <array> --fail <disk>` marks a member as faulty. The array keeps running.

**From [Replace A Failed Member](./course-02-replace-a-failed-member.md):**

- A failed member leaves with `--remove`. A new disk joins with `--add`, and the array rebuilds on its own.
- `mdadm --wait <array>` blocks until the rebuild ends. Only then is the array safe again.
- `mdadm --detail --scan` prints the `ARRAY` line for `/etc/mdadm/mdadm.conf`, and `update-initramfs -u` makes the early boot system know the array.
- Mount the array and read the files to prove the repair.

## Your missions

You proved these skills in a graded mission, right after the part that taught the last of them:

| Mission | After the part | What you proved |
| --- | --- | --- |
| [Software RAID Recovery Lab](./labs/lab-01/README.md) | Replace A Failed Member | Replaced a failed mirror member with a spare, waited for the rebuild and saved the array in `mdadm.conf` |

If you skipped it, go back to it now. The exam asks for exactly these skills.

## Check yourself

Try to answer each question before you open the answer.

<details>
<summary>1. <code>/proc/mdstat</code> shows <code>[U_]</code> for a mirror. What does it mean?</summary>

The array is degraded. One member is up and one is missing or failed, so there is no redundancy.
</details>

<details>
<summary>2. Which command lists the state and the members of one array?</summary>

`sudo mdadm --detail /dev/md/cargo` (or the array's own device name).
</details>

<details>
<summary>3. In which order do you swap a dead member for a new disk?</summary>

Remove the failed member with `--remove`, add the new disk with `--add`, then wait for the rebuild to finish.
</details>

<details>
<summary>4. How do you make the system assemble the array under the same name after a reboot?</summary>

Add the line from `mdadm --detail --scan` to `/etc/mdadm/mdadm.conf` and run `sudo update-initramfs -u`.
</details>

<details>
<summary>5. A replacement disk was in another array before. What do you run before you add it?</summary>

`sudo mdadm --zero-superblock <disk>`, so the old md label does not confuse the new array.
</details>

## Clean up the playground

When you are done with this module, remove the playground and any mission that is still running.

First, see what is still running:

```sh
astrona list
```

Remove the playground. The command takes its **name**, not its folder path:

```sh
astrona destroy raid-recovery-bench
```

If `astrona list` also showed a mission, remove it the same way, for example:

```sh
astrona destroy ats-002-lab-089
```

Run `astrona list` again to check that everything is gone. You can start the playground again at any time with the `astrona run` command from the module's landing page. It always starts clean, so nothing you broke carries over.

<!-- astrona:playground:destroy -->
