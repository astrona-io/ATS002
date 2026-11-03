# Restore Lost LVM Metadata

Astronaut, now the worse case. The label that tells LVM "this disk is a bay of a hold" has been wiped. `pvs`, `vgs` and `lvs` show nothing, as if the hold never existed. The decks and their crates are still on the disk. This part rebuilds the label and the layout from LVM's own backup.

## Where the backup lives

Every time you change a volume group, LVM writes the new layout as a plain text file:

- `/etc/lvm/backup/<vg>` is the latest layout.
- `/etc/lvm/archive/` keeps older ones.

List them for the group in the playground:

<!-- astrona:playground:renew -->

```bash
# shell: playground, root rights through sudo
sudo ls -l /etc/lvm/backup /etc/lvm/archive
sudo vgcfgrestore --list cargo_vg
```

The backup file names the group, its logical volumes and every physical volume with its **UUID**, the unique id that LVM wrote into the disk's label. That UUID is what you need.

## Make the damage

In the playground you cause the damage yourself. Switch the group off, then overwrite the first megabyte of the spare disk with zeros. Only ever do this on the spare disk:

```bash
DISK=$(readlink -f /dev/disk/by-id/virtio-lab088-pv001)
sudo vgchange -an cargo_vg
sudo dd if=/dev/zero of="$DISK" bs=1M count=1 conv=notrunc
sudo pvs
```

`pvs` shows nothing now. The label and the metadata area both lived in that first megabyte. The deck data starts after it and is untouched.

## Rebuild the bay, then the hold

Read the old UUID from the backup:

```bash
sudo grep -A3 'pv0 {' /etc/lvm/backup/cargo_vg
```

Copy the value of `id`. Give it to `pvcreate` together with the backup file, so the new label is the old one:

```bash
sudo pvcreate --uuid "<UUID>" --restorefile /etc/lvm/backup/cargo_vg "$DISK"
```

Replace `<UUID>` with the value you copied. This writes only a label, not a filesystem, and it keeps the data area. Now restore the layout of the group, then switch it on:

```bash
sudo vgcfgrestore cargo_vg
sudo vgchange -ay cargo_vg
```

## Prove the files survived

A restored layout is not the finish line. Mount the deck and read the files:

```bash
sudo mount /dev/cargo_vg/deck /mnt
ls -R /mnt
sudo umount /mnt
```

Both known files must be there with their text. If they are, the repair worked, and the group is ready to be mounted at its normal place again.

## When a disk of the group is gone

If a group has two bays and one disk dies, `vgs` warns about a missing device. You can still switch the group on with `sudo vgchange -ay --activationmode partial <vg>` to rescue what lives on the surviving bay. After the rescue, `sudo vgreduce --removemissing <vg>` drops the dead bay from the group. This is a last resort, because any deck that used the dead bay loses data.

## Common pitfalls

- Running `pvcreate` without `--uuid` and `--restorefile`. LVM then makes a brand new, unrelated label and `vgcfgrestore` refuses to match it.
- Running `mkfs` on the logical volume after the restore. The filesystem is fine. `mkfs` destroys it.
- Restoring onto the wrong disk. Check the disk with `lsblk` and the by-id path first.

## Your mission: LVM Recovery Lab

You can now read the LVM layers, find the metadata backup, rebuild a wiped physical volume and restore its group. The mission gives you a spare disk whose label was wiped, with a deck of files that must survive.

The mission runs on its own training ship. Your playground cannot be paused, so remove it first. It always starts clean, so you lose nothing you need:

```sh
astrona destroy lvm-recovery-bench
```

Then start the mission and open a terminal on it:

```sh
astrona run --git git@github.com:astrona-io/ATS002.git -c sections/section-080/module-07/labs/lab-01
astrona ssh ats-002-lab-088
```

Read the task in [`question.md`](./labs/lab-01/question.md) and solve it on your own first. When you think you are done, send it for grading:

```sh
astrona submit -c sections/section-080/module-07/labs/lab-01
```

When the mission is done, remove it and start your playground again:

```sh
astrona destroy ats-002-lab-088
astrona run --git git@github.com:astrona-io/ATS002.git -c sections/section-080/module-07/playground
```
