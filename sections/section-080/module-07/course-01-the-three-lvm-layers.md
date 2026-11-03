# The Three LVM Layers

Astronaut, before you repair a hold you need to know how it is built. This part shows the three layers of LVM, how to read each one with a single command, and the most common small failure: a deck that exists but is switched off.

## Pooling bays into decks

LVM stacks three layers. Think of cargo bays, a great hold, and decks:

| Layer | Ship picture | Command to read it |
| --- | --- | --- |
| Physical volume (PV) | One cargo bay (a disk or partition given to LVM) | `pvs` |
| Volume group (VG) | The great hold made by pooling bays | `vgs` |
| Logical volume (LV) | A deck carved out of the hold, where the filesystem lives | `lvs` |

You put the filesystem on the logical volume, not on the disk. That is why you can grow a deck later without caring which bay the space comes from. The kernel part that does the work is the **device mapper**, and it shows each logical volume as `/dev/<vg>/<lv>` and as `/dev/mapper/<vg>-<lv>`.

## See it in your playground

The playground has one bay, one hold (`cargo_vg`) and one deck (`deck`). Read all three layers:

<!-- astrona:playground:renew -->

```bash
# shell: playground, root rights through sudo
sudo pvs
sudo vgs
sudo lvs
```

`pvs` shows the disk and the group it belongs to. `vgs` shows the group with its size and free space. `lvs` shows the deck and an attribute string. The fifth character of that string is `a` when the logical volume is **active**, which means the kernel has built its device. `lsblk -f` shows the same stack as a tree:

```bash
lsblk -f
```

## A deck that is switched off

A logical volume can exist and still be unusable, because it is inactive. Switch it off to see the symptom:

```bash
sudo vgchange -an cargo_vg
sudo lvs
sudo mount /dev/cargo_vg/deck /mnt
```

The attribute string no longer has an `a` in the fifth place, and the mount fails because the device does not exist. Nothing is lost: the data is still on the disk. Switch the group back on:

```bash
sudo vgchange -ay cargo_vg
sudo mount /dev/cargo_vg/deck /mnt
ls /mnt
sudo umount /mnt
```

`vgchange -ay` activates every logical volume of the group. `lvchange -ay cargo_vg/deck` does the same for one volume.

## Which part does the work

`pvs`, `vgs` and `lvs` only read the LVM metadata that is stored on the disk itself, in a small area at the start of each physical volume. They do not read your files. `vgchange` asks the kernel's device mapper to build or remove the logical volume's device. The filesystem on top is a separate layer that `mount` handles.

## Common pitfalls

- Reading `lvs` and missing that the fifth attribute character is not `a`. The volume exists but is inactive.
- Running `mkfs` on a logical volume that only looks empty. Mount it first.
- Mounting `/dev/mapper/...` before the group is active and then reading the error as a filesystem problem.
