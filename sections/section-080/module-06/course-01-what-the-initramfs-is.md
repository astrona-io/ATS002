# What The Initramfs Is

Astronaut, this part answers one question: why does the kernel need a second file to boot? The answer decides when a rebuild is needed and where to look when boot stops early.

## The boot chicken-and-egg

The kernel needs the root filesystem to load its drivers, but it needs a driver to read the disk the root filesystem is on. The way out is the **initramfs** (initial RAM filesystem): a small archive that the boot loader loads into memory next to the kernel. The kernel unpacks it, runs the scripts inside, loads the needed drivers, finds and mounts the real root filesystem, and hands control over to it.

In the ship picture, the kernel is the engine, and the initramfs is a boot crate with the starter motor and the key to the fuel store. Once the main engine runs on real fuel, the crate is thrown away.

## Which files belong to one kernel

Every installed kernel has its own set of files in `/boot`. Look at them on your playground:

<!-- astrona:playground:renew -->

```bash
# shell: repair host, user
uname -r
ls -l /boot
```

`uname -r` prints the running kernel release. In `/boot` you find, for that release:

- `vmlinuz-<release>`: the kernel itself.
- `initrd.img-<release>`: its initramfs image.
- `config-<release>` and `System.map-<release>`: build configuration and symbol table.

`/boot/initrd.img` and `/boot/vmlinuz` are links to the newest installed kernel's files. The boot loader configuration (GRUB) names the image to load.

## Look inside an image

`lsinitramfs` lists the files in an image. The image is readable by root only:

```bash
# shell: repair host, root
sudo lsinitramfs /boot/initrd.img-"$(uname -r)" | head -20
```

You see directories such as `scripts/` with the boot-time scripts, `conf/` and the kernel modules and tools the image carries.

## When an image must be rebuilt

- The image was deleted or is empty, for example after a full `/boot` partition cut a kernel install short.
- You changed something the early boot needs: the root filesystem type, a storage or network driver in the module list, encryption or RAID settings.
- You changed `/etc/initramfs-tools/` configuration.

The symptom of a missing or wrong image is a boot that stops early with a message about not finding the root device, and an `(initramfs)` prompt.

## Common pitfalls

- Looking at `/boot/initrd.img` and assuming it is the running kernel's image. It is a link to the newest one.
- Rebooting to "test" after deleting an image. Check it first.
- Forgetting that images are readable by root only.
