# Blacklisting Modules

Astronaut, sometimes the job is the opposite of loading: a part must never be fitted again. A **blacklist** entry is a "never fit this part" note on the start-up checklist. It blocks less than most people expect, and every exam question about blacklisting tests exactly that gap.

This part shows what a `blacklist` line blocks, what it does not block, and when the early-boot copy of the checklist must be rebuilt too.

## A real case: the beeping `pcspkr`

Here is the kind of request you will meet. The `pcspkr` module (the PC speaker beep driver) beeps on every kernel warning. It must never load automatically again, even though its hardware is present. It may not be present on every virtual machine kernel, so the hands-on step later uses `dummy` instead.

### Write the blacklist line

<!-- astrona:playground:renew -->

Save this as `/etc/modprobe.d/blacklist-pcspkr.conf`:

```ini
blacklist pcspkr
```

Like `options` lines, `blacklist` lines live in the `/etc/modprobe.d/` family, and `modprobe` reads them on every load. There is no reload command to apply it. Instead, the steps below unload the running module and replay hardware detection to check that the line holds.

## What `blacklist` blocks, and what it does not

Read this twice: **`blacklist` only stops the *automatic* load path**, the one driven by hardware detection. When new hardware appears, the kernel sends a signal called a **uevent** ("a device was added"). udev, the dock master who handles every arriving device, then asks `modprobe` to load the module that matches the device's ID. A `blacklist` line tells `modprobe` to skip the module in exactly this case.

### What it does not do

A `blacklist` line does **not**:

- delete the `.ko` file;
- make the module impossible to unload;
- stop `sudo modprobe pcspkr`. An explicit request by name still succeeds.

In space terms: the "never fit this part" note stops the automatic fitting when the part arrives. But an engineer who is told to fit the part by name still fits it.

### Blocking the by-name load too

To block the explicit load as well, use a different directive: `install pcspkr /bin/false`. It replaces the load action with a command that does nothing, so even `modprobe pcspkr` fails to fit the part.

## A blacklist does not touch what is already loaded

The note only acts on *future* loads. The module is probably loaded right now, which is why it beeps.

### Unload it once, by hand

```bash
sudo modprobe -r pcspkr
```

### Re-run hardware detection without a reboot

Now ask udev to replay hardware detection, and check that the module stays away:

```bash
sudo udevadm trigger
lsmod | grep pcspkr        # absent → the blacklist is holding the automatic path
```

`udevadm trigger` makes the kernel send `add` and `change` uevents again for hardware that is already present. It is the closest thing to "reboot and let automatic detection run again", without restarting the machine.

## Try it: blacklist blocks automatic loads, not explicit ones

`pcspkr` may not exist for this virtual machine kernel, so use `dummy` to see the mechanism.

Save this as `/etc/modprobe.d/bl-dummy.conf`:

```ini
blacklist dummy
```

Apply it by unloading `dummy`, so the next load is a fresh one:

```bash
sudo modprobe -r dummy 2>/dev/null
```

Then check the result. Confirm that `modprobe` sees the blacklist, then load the module by name anyway:

```bash
modprobe --showconfig | grep -i 'blacklist dummy'
sudo modprobe dummy && echo "explicit load STILL WORKS"
lsmod | grep '^dummy'
```

Expect something like:

```text
blacklist dummy
explicit load STILL WORKS
dummy                  16384  0
```

The blacklist is registered, yet `modprobe dummy` by name loads the module without trouble. A `blacklist` line only stops the *automatic*, uevent-driven load path. To block the explicit path too, you would write `install dummy /bin/false`.

Clean up afterwards with `sudo rm /etc/modprobe.d/bl-dummy.conf /etc/modprobe.d/dummy.conf /etc/modules-load.d/dummy.conf`.

## Early-boot modules and the initramfs

Some modules are needed *before* the main root filesystem is mounted, for example storage controllers, disk encryption (`crypt`) and some filesystems. Those load from the **initramfs** (initial RAM filesystem): a small starter filesystem that the boot loader hands to the kernel, like a small kit of parts the launch sequence carries before any cargo deck is attached.

### Rebuild it after changing early-boot rules

The initramfs holds its own copy of the `modules-load.d` and `modprobe.d` files. After you change the rules for an early-boot module, rebuild it:

```bash
sudo update-initramfs -u      # Debian/Ubuntu
sudo dracut -f                # RHEL/Fedora/SUSE
```

On Ubuntu 24.04, `update-initramfs` is the tool. A `dummy` network interface or `pcspkr` does not need this, because they load well after boot. But a blacklist meant to keep a driver out of early boot does not work until the initramfs is rebuilt. The manual pages `man 5 modprobe.d`, `man 8 update-initramfs` and `man 8 dracut` describe this in full.

> *`blacklist` stops only automatic loads. `install <module> /bin/false` stops explicit loads too. An already-loaded module needs one `modprobe -r`, and an early-boot module needs an initramfs rebuild as well.*

## Common pitfalls

> [!WARNING]
> - **Expecting `blacklist` to block `modprobe <name>`.** It only blocks automatic loads. Use `install <module> /bin/false` to block explicit loads too.
> - **Blacklisting a loaded module and expecting it to unload.** It does not. Run `modprobe -r` on it once, now.
> - **Blacklisting an early-boot module without `update-initramfs -u` or `dracut -f`.** The initramfs still carries the old rules until you rebuild it.

## Your mission: Kernel Module Loading & Blacklisting Lab

You can now load a module with a parameter, keep both the load and the parameter for future boots, and blacklist a module so automatic detection cannot load it. The mission asks you to do both jobs on one ship: keep one module loaded with a parameter, and block another one.

The mission runs on its own training ship. Your playground cannot be paused, so remove it first. It always starts clean, so you lose nothing you need:

```sh
astrona destroy kernel-modules-lab
```

Then start the mission and open a terminal on it:

```sh
astrona run --git git@github.com:astrona-io/ATS002.git -c sections/section-010/module-03/labs/lab-01
astrona ssh ats-002-lab-013
```

Read the task in [`question.md`](./labs/lab-01/question.md) and solve it on your own first. When you think you are done, send it for grading:

```sh
astrona submit -c sections/section-010/module-03/labs/lab-01
```

When the mission is done, remove it and start your playground again:

```sh
astrona destroy ats-002-lab-013
astrona run --git git@github.com:astrona-io/ATS002.git -c sections/section-010/module-03/playground
```
