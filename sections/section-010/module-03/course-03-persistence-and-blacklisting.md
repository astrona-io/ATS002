# Part 3 — Persistence and blacklisting

> Prerequisite: [Part 2 — Loading: modprobe, depmod, and the dependency graph](./course-02-loading-modprobe-and-dependencies.md). Next: [Section 010 quiz](../quiz.md).

Two questions — "should this module load at boot?" and "with what parameters?" — are answered by two different config file families, and it is easy to get them backwards under pressure. Blacklisting is a third thing again, and it blocks less than people expect. This part is all three, plus the trick to prove persistent config without a reboot.

## Two files, two questions

```
  ┌───────────────────────────────────────────────────────────────┐
  │ "Should it load at boot?"    /etc/modules-load.d/<x>.conf      │
  │   one bare module name per line, nothing else                  │
  │   read by: systemd-modules-load.service, early boot            │
  ├───────────────────────────────────────────────────────────────┤
  │ "With what parameters?"      /etc/modprobe.d/<x>.conf          │
  │   options <module> key=value ...                               │
  │   read by: modprobe, on EVERY load — boot, manual, or auto     │
  │ "Blocked from auto-loading?" same file family                  │
  │   blacklist <module>   /   install <module> /bin/false         │
  └───────────────────────────────────────────────────────────────┘
```

### "Load it at boot" — `/etc/modules-load.d/`

```bash
echo 'dummy' | sudo tee /etc/modules-load.d/dummy.conf
```

`man 5 modules-load.d`: one module name per line, read once by `systemd-modules-load.service` during boot. **No parameters here** — this file only answers yes/no to loading.

### "With these parameters" — `/etc/modprobe.d/`

```bash
echo 'options dummy numdummies=2' | sudo tee /etc/modprobe.d/dummy.conf
```

`man 5 modprobe.d` → `options`: whenever `modprobe` loads `dummy` — triggered by `/etc/modules-load.d/`, a manual command, or automatic hardware detection — it applies these arguments. Without this file, the boot-time load from `modules-load.d` would bring `dummy` up with **zero** interfaces, silently missing the point.

So a module that must load at boot *with* a non-default parameter needs **both** files: `modules-load.d` to load it, `modprobe.d` to parameterise it.

## Prove the persistent config without rebooting

```bash
sudo modprobe -r dummy
sudo modprobe dummy                 # bare — no numdummies= on the line
cat /sys/module/dummy/parameters/numdummies
# 2
```

The bare `modprobe dummy` reads `/etc/modprobe.d/dummy.conf` for its `options`. Seeing `2` come back proves the file — not your earlier command line — is driving the value.

## Blacklisting: blocks the automatic path only

Opposite request: `pcspkr` (the PC-speaker beep driver) beeps on every kernel warning and must never auto-load again, even though its hardware is present.

```bash
echo 'blacklist pcspkr' | sudo tee /etc/modprobe.d/blacklist-pcspkr.conf
```

Read this twice, because every exam question about blacklisting tests it: **`blacklist` only stops the *automatic*, hardware-detection load path.** `man 5 modprobe.d` → `blacklist`: it tells the udev alias-matching machinery to skip this module when a device ID would normally trigger it. It does **not**:

- delete the `.ko`;
- make the module unloadable;
- stop `sudo modprobe pcspkr` — an explicit, by-name request still succeeds.

As an analogy (flagged): a `blacklist` entry removes a name from an automatic door's guest list. Someone who walks up and announces themselves by name is still let in — only the automatic greeter is told not to wave them through unprompted. Where it breaks down: to block the by-name entry too you need a different directive — `install pcspkr /bin/false`, which replaces the load action with a command that does nothing.

## Blacklist does not touch what is already loaded

The module is probably loaded right now (that is why it is beeping). Unload it once, by hand:

```bash
sudo modprobe -r pcspkr
```

Then simulate a fresh hardware-detection pass without rebooting:

```bash
sudo udevadm trigger
lsmod | grep pcspkr        # absent → the blacklist is holding the automatic path
```

`udevadm trigger` re-fires synthetic `add`/`change` uevents for already-present hardware — the closest thing to "reboot and let auto-detection run again" without restarting.

## Early-boot modules and the initramfs

If a module is needed *before* the root filesystem mounts (storage controllers, `crypt`, some filesystems), the `modules-load.d` / `modprobe.d` files must also be baked into the **initramfs**:

```bash
sudo update-initramfs -u      # Debian/Ubuntu
sudo dracut -f                # RHEL/Fedora/SUSE
```

For a `dummy` NIC or `pcspkr` this is not needed — they load well after boot — but a blacklist meant to keep a driver out of early boot is not effective until the initramfs is regenerated.

> [!WARNING]
> - **Putting parameters in `/etc/modules-load.d/`.** That file only takes bare names. Parameters go in a `/etc/modprobe.d/` `options` line.
> - **Expecting `blacklist` to block `modprobe <name>`.** It only blocks automatic loads. Use `install <mod> /bin/false` to block explicit loads too.
> - **Blacklisting a currently-loaded module and expecting it to unload.** It does not — `modprobe -r` it once, now.
> - **Blacklisting an early-boot module without `update-initramfs -u` / `dracut -f`.** The initramfs still carries the old rules until regenerated.

> *`/etc/modules-load.d/` decides whether a module loads at boot (names only); `/etc/modprobe.d/` sets `options` parameters and `blacklist`/`install` suppression; `blacklist` stops only automatic loads, and an already-loaded or early-boot module needs `modprobe -r` / an initramfs rebuild as well.*

## Reference

- `man 5 modules-load.d` — bare-name syntax, `systemd-modules-load.service`.
- `man 5 modprobe.d` — `options`, `blacklist`, `install`, `alias`; precedence and lexical file order.
- `man 8 update-initramfs` / `man 8 dracut` — regenerating the initramfs after changing early-boot module config.
