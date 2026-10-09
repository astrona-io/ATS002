# Wrap-Up: Mission Debrief

Well flown, astronaut. You have fitted, tuned and blocked plug-in reactor parts on a live ship. Before you move on, look back at what you learned, check yourself, and clean up anything still running.

## What you learned

This module was about kernel modules: how to see them, load them, keep them for every boot, and block them.

**From [Inspecting Modules And Their Parameters](./course-01-inspecting-modules-and-parameters.md):**

- `lsmod` formats `/proc/modules`: name, size, reference count and the dependent modules holding each one.
- The kernel will not unload a module whose reference count is above zero.
- `modinfo -p <name>` lists the exact parameter names and types a module accepts. Check it before you load.
- `/sys/module/<name>/parameters/` shows the values a loaded module is running with now.

**From [Loading Modules With Modprobe](./course-02-loading-modprobe-and-dependencies.md):**

- `modprobe` reads `modules.dep` (built by `depmod`), loads the dependencies first, then the module.
- `insmod` loads one `.ko` file and fails with `Unknown symbol` when a dependency is missing.
- `modprobe -r` unloads a module and its unused dependencies. `rmmod` removes only the one module.
- A `key=value` on the `modprobe` command line applies to that one load only.

**From [Loading Modules At Boot With Options](./course-03-loading-at-boot-with-options.md):**

- `/etc/modules-load.d/<x>.conf` holds bare module names. `systemd-modules-load.service` loads them at boot.
- `/etc/modprobe.d/<x>.conf` holds `options` lines that `modprobe` applies on every load.
- A module that must load at boot with a parameter needs both files.
- Unload, then load with a bare `modprobe`, then read `/sys/module/<name>/parameters/`: that proves the file works without a reboot.

**From [Blacklisting Modules](./course-04-blacklisting-modules.md):**

- A `blacklist` line in `/etc/modprobe.d/` stops only the automatic, uevent-driven load. `modprobe <name>` still works.
- `install <module> /bin/false` blocks explicit loads too.
- A blacklist does not unload a module that is already loaded. Run `modprobe -r` once.
- `udevadm trigger` replays hardware detection without a reboot.
- A rule for an early-boot module needs an initramfs rebuild (`update-initramfs -u` on Ubuntu).

## Your missions

You proved these skills in a graded mission, right after the part that taught the last of them:

| Mission | After the part | What you proved |
| --- | --- | --- |
| [Kernel Module Loading & Blacklisting Lab](./labs/lab-01/README.md) | Blacklisting Modules | loaded `dummy` with a parameter that survives a reboot, and blacklisted and unloaded `pcspkr` |

## Check yourself

Try to answer each question before you open the answer.

<details>
<summary>1. What does the third column of <code>lsmod</code> tell you, and why does it matter?</summary>

It is the reference count: how many things use the module right now. The kernel will not unload a module while that count is above zero.
</details>

<details>
<summary>2. How do you find the exact name of a module's parameter before you load it?</summary>

Run `modinfo -p <module>`. It lists each parameter's name, description and type. A misspelled `key=` on `modprobe` may be ignored without any error.
</details>

<details>
<summary>3. Why does <code>insmod</code> fail where <code>modprobe</code> works?</summary>

`insmod` loads only the one file you name and does not load its dependencies. `modprobe` reads `modules.dep`, loads every dependency first, and then loads the module.
</details>

<details>
<summary>4. A module must load at every boot with <code>numdummies=2</code>. Which files do you need?</summary>

Two: a file under `/etc/modules-load.d/` with the bare module name, so it loads at boot, and a file under `/etc/modprobe.d/` with an `options` line, so every load gets the parameter.
</details>

<details>
<summary>5. How do you prove an <code>options</code> line works without rebooting?</summary>

Unload the module with `modprobe -r`, load it again with a bare `modprobe <name>` and no parameter, then read `/sys/module/<name>/parameters/<parameter>`. If the value matches the file, the file is doing the work.
</details>

<details>
<summary>6. You blacklisted a module, but <code>sudo modprobe</code> with its name still loads it. Is the blacklist broken?</summary>

No. `blacklist` only blocks the automatic load that hardware detection starts. To block explicit loads too, use `install <module> /bin/false`.
</details>

<details>
<summary>7. You added a blacklist line and the module is still in <code>lsmod</code>. Why?</summary>

A blacklist only affects future loads. It does not unload a module that is already loaded. Run `sudo modprobe -r <module>` once.
</details>

<details>
<summary>8. When do you need to rebuild the initramfs after changing module rules?</summary>

When the module loads before the root filesystem is mounted, for example a storage controller or disk encryption. The initramfs carries its own copy of the rules. On Ubuntu, rebuild it with `sudo update-initramfs -u`.
</details>

## Clean up the playground

Your playground and any mission each run a virtual machine on your computer. When you are done with this module, remove what is still running.

First, see what is still running:

```sh
astrona list
```

Remove the playground. The command takes its **name**, not its folder path:

```sh
astrona destroy kernel-modules-lab
```

If the mission is still running, remove it too:

```sh
astrona destroy ats-002-lab-013
```

> *Load it now, keep it for every boot, and remember that a blacklist only stops the automatic path.*
