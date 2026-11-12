# LVM Recovery

Astronaut, the biggest ships do not bolt cargo decks to single bays. They pool several bays into one great hold, then carve decks out of the hold as needed. On Linux that pooling system is LVM, the Logical Volume Manager. It is flexible, but it adds a layer that can fail in its own way.

In this module you learn to read the three LVM layers, bring a deck back online when it is switched off, and rebuild the layout of a hold whose label was wiped from the disk.

## Learning objectives

After this module you can:

- Name the three LVM layers (physical volume, volume group, logical volume) and read each with `pvs`, `vgs` and `lvs`.
- Tell an inactive logical volume from a missing one, and activate it with `vgchange -ay`.
- Find the LVM metadata backups in `/etc/lvm/backup` and `/etc/lvm/archive`.
- Rebuild a wiped physical volume with `pvcreate --uuid --restorefile`, and restore the volume group with `vgcfgrestore`.
- Prove the data survived by mounting the logical volume and reading the files.

## Before you start

Check that you have the knowledge and the tools this module expects before you begin.

### What you should already know

- **How to use a Linux shell and `sudo`.**
- **How to mount a filesystem** and list its files.
- **That a disk can hold a filesystem directly**, or something that sits between the disk and the filesystem.

### What is in your playground

Your playground is a training ship: one Ubuntu 24.04 virtual machine with a spare disk already pooled by LVM.

- A second, 1 GB disk with the serial `lab088-pv001`. Find it at `/dev/disk/by-id/virtio-lab088-pv001`.
- On that disk, a volume group called `cargo_vg` with one logical volume `deck`, holding an ext4 filesystem and two known files.
- The LVM tools (`pvs`, `vgs`, `lvs`, `vgcfgrestore`) and `lsblk`.
- Your own machine stays healthy and reachable; the damaged system lives on the spare disk.

Start the playground, then open a terminal on it with `astrona ssh astro-lvm-recovery-bench`. The hands-on steps in the parts build on each other on this one running ship. Every command block says which shell and which rights it expects.

<!-- astrona:playground -->

## How this module is laid out

1. [The Three LVM Layers](./course-01-the-three-lvm-layers.md): physical volumes, volume groups and logical volumes, how to read them, and how to switch a logical volume on.
2. [Restore Lost LVM Metadata](./course-02-restore-lost-lvm-metadata.md): the metadata backups, rebuilding a wiped physical volume, restoring the volume group, and proving the files survived.
   - Mission: LVM Recovery Lab
3. [Summary](./course-03-wrap-up.md)

## Why this matters

When a volume group seems to have vanished, the reflex is to run `pvcreate` and `mkfs`. That destroys the data. LVM keeps a text backup of every layout it has had. If you know where it lives, the repair takes a minute and loses nothing.

<!-- curriculum-practice -->
## Practice and assessment

- [LVM Recovery Lab](labs/lab-01/question.md): Rebuild a wiped physical volume with its old UUID and restore the volume group from its metadata backup; Activate the logical volume and mount it with its files intact.
- [System Disaster Recovery Integration Capstone Lab](../capstone/labs/lab-01/question.md): Restore a wiped GPT table from a backup and prove the filesystems are intact; Reinstall GRUB and regenerate grub.cfg on the running machine.
