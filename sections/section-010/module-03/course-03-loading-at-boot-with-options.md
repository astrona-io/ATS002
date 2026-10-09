# Loading Modules At Boot With Options

Astronaut, a module you load by hand is gone after the next reboot, and so is any parameter you typed. To keep a module, you write it into the ship's start-up checklist. Two questions need answers there: "should this module load at boot?" and "with which parameters?". Two different families of configuration files answer them, and under exam pressure it is easy to mix them up.

This part shows both files, and a trick to prove that they work without rebooting.

## Two files, two questions

Each question has its own folder under `/etc`, its own format and its own reader. This table is the one to remember:

| Question | File | What goes in it | Who reads it |
| --- | --- | --- | --- |
| "Should it load at boot?" | `/etc/modules-load.d/<x>.conf` | One bare module name per line, nothing else | `systemd-modules-load.service`, early in boot |
| "With which parameters?" | `/etc/modprobe.d/<x>.conf` | `options <module> key=value ...` | `modprobe`, on every load: at boot, by hand, or automatic |
| "Blocked from loading automatically?" | `/etc/modprobe.d/<x>.conf` (same family) | `blacklist <module>` or `install <module> /bin/false` | `modprobe` |

The last row, blocking a module, has its own rules and is explained separately. Here you use the first two rows.

### "Load it at boot": `/etc/modules-load.d/`

A file in `/etc/modules-load.d/` holds one module name per line. During boot, systemd's `systemd-modules-load.service` reads it once and loads each name it finds. **No parameters go here.** This file only answers yes or no to loading.

### "With these parameters": `/etc/modprobe.d/`

A file in `/etc/modprobe.d/` can hold an `options` line. Whenever `modprobe` loads that module, it adds those parameters. It does not matter what started the load: a `modules-load.d` file at boot, a command you typed, or automatic hardware detection.

Without this file, the boot-time load would bring `dummy` up with **zero** interfaces, and miss the whole point. So a module that must load at boot *with* a non-default parameter needs **both** files: `modules-load.d` to load it, and `modprobe.d` to set its parameter.

## Try it: the two files, and the reboot-free proof

Now write both files for the `dummy` module and prove they work.

### Write the "load at boot" file

<!-- astrona:playground:renew -->

Save this as `/etc/modules-load.d/dummy.conf`:

```ini
dummy
```

Apply it: there is nothing to run now. `systemd-modules-load.service` reads this file at every boot.

### Write the "parameters" file

Save this as `/etc/modprobe.d/dummy.conf`:

```ini
options dummy numdummies=2
```

Apply it by unloading the module and loading it again with a bare `modprobe`, with no parameter typed:

```bash
sudo modprobe -r dummy
sudo modprobe dummy                 # bare — no numdummies= on the line
```

Then check the result:

```bash
cat /sys/module/dummy/parameters/numdummies
```

```text
2
```

### What the `2` proves

The bare `modprobe dummy` read `/etc/modprobe.d/dummy.conf` and found the `options` line there. You never typed `numdummies=2` on this load, so the `2` proves that the file, and not an earlier command line, sets the value.

At boot, `modules-load.d` will load the module, and `modprobe.d` will supply the parameter. You proved both halves without waiting for a reboot. The manual pages `man 5 modules-load.d` and `man 5 modprobe.d` describe both formats in full.

> *`/etc/modules-load.d/` decides whether a module loads at boot (names only). `/etc/modprobe.d/` sets its `options` parameters for every load.*

## Common pitfalls

> [!WARNING]
> - **Putting parameters in `/etc/modules-load.d/`.** That file only takes bare module names. Parameters go in an `options` line in a file under `/etc/modprobe.d/`.
> - **Writing only one of the two files.** A `modules-load.d` file alone loads the module with default parameters. A `modprobe.d` file alone sets the parameters but never loads the module at boot.
> - **Rebooting to test.** Unload the module and load it again with a bare `modprobe`, then read `/sys/module/<name>/parameters/`. It is faster and proves the same thing.
