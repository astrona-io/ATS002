# Replace A Failed Member

Astronaut, a degraded mirror runs on one bay. This part replaces the dead bay with a fresh one, watches the copy being rebuilt, and makes sure the array comes back by itself after a reboot.

## Remove the dead member

A member that has failed must leave the array before a new one joins. In the playground, disk `b` is already marked faulty if you followed the last part. If not, mark it first:

<!-- astrona:playground:renew -->

```bash
# shell: playground, root rights through sudo
DISK_B=$(readlink -f /dev/disk/by-id/virtio-lab089-raid-b)
sudo mdadm /dev/md/cargo --fail "$DISK_B"
sudo mdadm /dev/md/cargo --remove "$DISK_B"
```

`--remove` works only on a failed or spare member. If you try to remove a healthy active member, `mdadm` refuses.

## Add the replacement

The spare disk `c` is blank. Add it, and the array starts copying disk `a` onto it:

```bash
DISK_C=$(readlink -f /dev/disk/by-id/virtio-lab089-raid-c)
sudo mdadm /dev/md/cargo --add "$DISK_C"
cat /proc/mdstat
```

While it copies, `/proc/mdstat` shows a `recovery` line with a percentage. `mdadm --detail` shows the state `clean, degraded, recovering`. Wait until it finishes:

```bash
sudo mdadm --wait /dev/md/cargo
sudo mdadm --detail /dev/md/cargo
```

When the rebuild is done, `State` is `clean`, and both `Active Devices` and `Working Devices` are 2.

## Make the array survive a reboot

The kernel can find an array without help, but the standard way is to list it in the configuration file. Save the line `mdadm` builds for you:

```bash
sudo mdadm --detail --scan
```

Add this line to the end of `/etc/mdadm/mdadm.conf`. The file already has other lines, so keep them:

```ini
ARRAY /dev/md/cargo metadata=1.2 name=<NAME> UUID=<UUID>
```

Replace `<NAME>` and `<UUID>` with the values from the scan output, which is the same line. Then apply it by rebuilding the initramfs so the early boot system knows the array too:

```sh
sudo update-initramfs -u
```

Then check the result:

```bash
grep ARRAY /etc/mdadm/mdadm.conf
```

## Prove the files survived

The rebuild only copies bytes. Mount the array and read the files:

```bash
sudo mount /dev/md/cargo /mnt
ls -R /mnt
sudo umount /mnt
```

## Common pitfalls

- Adding a disk that still holds an old md label from another array. Clear it first with `sudo mdadm --zero-superblock <disk>`.
- Stopping at "State: clean, degraded, recovering" and calling the job done. The array is only safe after the rebuild ends.
- Forgetting `mdadm.conf` and `update-initramfs -u`, so the array comes up under a different name after the reboot.

## Your mission: Software RAID Recovery Lab

You can now read an array, remove a failed member, add a spare and save the array in `mdadm.conf`. The mission gives you a degraded mirror with a blank spare disk, and files that must survive.

The mission runs on its own training ship. Your playground cannot be paused, so remove it first. It always starts clean, so you lose nothing you need:

```sh
astrona destroy raid-recovery-bench
```

Then start the mission and open a terminal on it:

```sh
astrona run --git git@github.com:astrona-io/ATS002.git -c sections/section-080/module-08/labs/lab-01
astrona ssh ats-002-lab-089
```

Read the task in [`question.md`](./labs/lab-01/question.md) and solve it on your own first. When you think you are done, send it for grading:

```sh
astrona submit -c sections/section-080/module-08/labs/lab-01
```

When the mission is done, remove it and start your playground again:

```sh
astrona destroy ats-002-lab-089
astrona run --git git@github.com:astrona-io/ATS002.git -c sections/section-080/module-08/playground
```
