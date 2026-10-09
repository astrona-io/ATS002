# Chroot In And Fix The Line

Astronaut, the cables are run and the tools are aboard. Now you step onto the damaged ship's bridge, find the one wrong entry on its list of cargo decks, and correct it against what the disks really say. This part covers `chroot` itself and how to read every field of an fstab line.

The commands below assume the target root is mounted at `/mnt/repair`, with `/usr`, `/bin`, `/sbin`, `/lib` (and `/lib64` if it exists), `/dev`, `/proc` and `/sys` bind-mounted into it.

## Step inside with `chroot`

`chroot` is short for "change root". Run it as root on the repair host:

```bash
# shell: the repair host, root
sudo chroot /mnt/repair /bin/bash
```

The kernel now treats `/mnt/repair` as `/` for this shell and every program it starts. Every path resolves inside the target's tree: `/etc/fstab` now means the target's `/etc/fstab`, not the repair host's. This is stepping into the damaged ship's bridge from the rescue ship, so its own controls work again.

Always confirm where you are before you change anything:

```bash
cat /etc/hostname
# data-001        ← the target's hostname, not the repair host's — you are inside
```

If you see the repair host's own name, you are not inside the target. Stop and check the `chroot` command.

## Read the bad line against reality

Every fstab line has six fields, separated by spaces. Here is the target's line:

```bash
cat /etc/fstab
```

```text
UUID=aabbccdd-5555-6666-7777-8888dead  /data  ext4  defaults  0  2
```

| Field | Value here | Meaning |
| --- | --- | --- |
| 1 | `UUID=aabbccdd-...-8888dead` | Which device to mount |
| 2 | `/data` | Where to mount it (the mount point) |
| 3 | `ext4` | The filesystem type |
| 4 | `defaults` | Mount options, such as `nofail` |
| 5 | `0` | Old backup flag for the `dump` tool; almost always `0` |
| 6 | `2` | The order `fsck` checks it at boot (`0` = never) |

Now ask the disks themselves, from inside the chroot:

```bash
blkid
```

`blkid` prints each partition with its `UUID=` and `TYPE=`. It is the source of truth. Compare it against fields 1 and 3 of the fstab line:

- **Field 1:** does a partition with this exact UUID exist? A UUID can look perfectly valid and still be wrong.
- **Field 3:** does that partition's `TYPE=` match the type in the line? If the line says one type and `blkid` shows another, `mount` loads the wrong filesystem driver and fails.

In this example, say `blkid` shows the real UUID ends in `888899990000`, not `8888dead`. That one mistyped UUID is the whole outage, and it is the most common real cause of this failure.

## Fix it, and create the mount point

Change only the wrong part of the line. Here `sed` swaps the bad UUID for the real one:

```bash
sed -i 's/aabbccdd-5555-6666-7777-8888dead/aabbccdd-5555-6666-7777-888899990000/' /etc/fstab
```

You can also open the file in an editor such as `nano` or `vi` and change it by hand. Either way, keep the other fields as they are unless `blkid` proves one of them wrong too.

A bad entry sometimes comes with a missing mount point. The folder named in field 2 must exist, so create it if needed:

```bash
mkdir -p /data
```

Run `cat /etc/fstab` again and read the line once more. Every field that names something real (the device and the type) should now match the `blkid` output.

## Common pitfalls

> [!WARNING]
> - **Skipping the hostname check.** If you are not really inside the chroot, you edit the repair host's own `/etc/fstab` instead of the target's.
> - **Trusting a UUID because it looks right.** Well-formed is not the same as correct. Compare it with `blkid` every time.
> - **Checking only the device.** Field 3, the filesystem type, must also match `TYPE=` in `blkid`. A wrong type gives `wrong fs type, bad superblock`.
> - **Forgetting the mount point.** If the folder in field 2 does not exist, the mount fails even with a perfect device and type.
