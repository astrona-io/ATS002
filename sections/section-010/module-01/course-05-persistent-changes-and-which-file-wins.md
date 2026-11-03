# Persistent Changes And Which File Wins

Astronaut, a dial you turn by hand is reset at the next cold start. To make a setting stick, you write it into the ship's start-up checklist. That checklist is the set of files under `/etc/sysctl.d/`. The command `sysctl --system` reads the checklist out loud right now, so the setting also takes effect at once.

This part shows how to write such a file, how to apply it, and which file wins when two of them set the same dial.

## Persistence: a file the boot process reads again

To survive a reboot, a setting must live in a `*.conf` file that the boot process reads. Such a small extra file in a `.d` folder is called a **drop-in**. You add it without editing anyone else's file.

<!-- astrona:playground:renew -->

Save this as `/etc/sysctl.d/99-ip-forward.conf`:

```ini
net.ipv4.ip_forward = 1
```

Apply it:

```sh
sudo sysctl --system
```

Then check the result:

```bash
sysctl --system 2>&1 | grep ip_forward      # shows which file set the final value
sysctl -n net.ipv4.ip_forward               # confirm the live value is what you intended
```

### What `--system` does

`sysctl --system` reads every `*.conf` file from all the sysctl folders, in a fixed order, and applies them to the running kernel in one pass. So the file plus this one command give you **both halves at once**. The value takes effect now, because `--system` applies it. Every future boot applies it again, because the `systemd-sysctl` service reads the same folders early in the boot, before your services start.

`sysctl -p <file>` applies only the one file you name. It is useful to test a single drop-in without running the whole set again.

## Which file wins

Many packages ship their own sysctl files, so two files can set the same dial. The rule for who wins is fixed, and you can see it happen.

### The folders and the order

`--system` reads these locations:

```
  /etc/sysctl.d/*.conf        ← local admin (highest-priority directory)
  /run/sysctl.d/*.conf        ← runtime-generated
  /usr/lib/sysctl.d/*.conf    ← distro/package defaults
  /etc/sysctl.conf            ← legacy single file, still read
```

The tools sort all the `*.conf` files from these folders together by file name, in alphabetical order. They apply them one by one, so **the file that sorts last wins** for any dial it sets. If two folders hold a file with the same name, only the copy in `/etc/sysctl.d/` is used. That is why the administrator's folder has the highest priority.

This is why the files start with a number. `99-ip-forward.conf` sorts after `10-network.conf`, so `99-` wins a conflict. `20-` beats `10-`, and `99-` beats every normal file.

### Try it: make it stick, and see which file won

On your playground, write two files that set the same dial to different values.

Save this as `/etc/sysctl.d/99-swappiness.conf`:

```ini
vm.swappiness = 10
```

Save this as `/etc/sysctl.d/10-swappiness.conf`:

```ini
vm.swappiness = 42
```

Apply them, and show only the lines about swappiness:

```sh
sudo sysctl --system 2>&1 | grep swappiness
```

Then check the live value:

```sh
sysctl -n vm.swappiness
```

Expect something like this (the four lines from `--system`, then the live value):

```text
* Applying /etc/sysctl.d/10-swappiness.conf ...
vm.swappiness = 42
* Applying /etc/sysctl.d/99-swappiness.conf ...
vm.swappiness = 10
10
```

Both files were read, in alphabetical order. `99-` came last, so `10` is the live value, not `42` from the file that sorts earlier. `sysctl --system` also made it survive a reboot. Clean up with `sudo rm /etc/sysctl.d/{10,99}-swappiness.conf`.

## The same pattern for many settings

Many Linux settings have this same two-layer shape. Process limits, kernel module options and device names all work this way: a **live action** that changes the running system now, and a **persistent file** under `/etc` that a service reads again at boot. Learn the pair once, and each new topic becomes "which file, and which command applies it".

> [!TIP]
> After any sysctl change, run `sysctl --system 2>&1 | grep <key>` and `sysctl -n <key>`. The first shows which file set the final value; the second shows what the kernel really uses.

## Common pitfalls

> [!WARNING]
> - **Writing the drop-in but not applying it.** The file alone does nothing until `sysctl --system` or a reboot. Run `--system` so the change is live *and* persistent in one step.
> - **Name collisions across drop-ins.** If two files set the same key, the file whose name sorts last wins, not the one you edited most recently. Check with `sysctl --system 2>&1 | grep <key>`.
> - **Editing `/etc/sysctl.conf` on a system that also has `/etc/sysctl.d/` drop-ins.** A `99-` drop-in can override your `sysctl.conf` line. Prefer a drop-in with a deliberate number in front.
