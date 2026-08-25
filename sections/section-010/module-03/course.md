# Chapter 3: Kernel Modules — Loading, Parameters, and Blacklisting

Most of what a running Linux kernel is capable of doing was never baked into the kernel image at compile time. It's loaded on demand, piece by piece, as **modules** — drivers for specific hardware, filesystem implementations, network protocol handlers — much the way a video game might load a level's assets only once you actually walk into that level, rather than holding the entire game world in memory from the moment you press start.

A loadable kernel module is, in a very real sense, kernel configuration you apply at runtime instead of at compile time. And just like the sysctl parameters from Chapter 1, a module's behavior can be tuned with parameters, made to load automatically and consistently at boot, or explicitly suppressed so it never loads even though the hardware that would normally trigger it is sitting right there.

---

## Part I: Seeing What's Already Loaded

Start with `lsmod`:

```bash
lsmod | head -5
```

```text
Module                  Size  Used by
dummy                  16384  0
nf_tables             229376  1
```

`man lsmod` confirms this is a thin, human-friendly formatter over a raw kernel data source: `/proc/modules`. If `lsmod` itself isn't installed in a stripped-down environment, the identical information is still available directly:

```bash
cat /proc/modules
```

Each row tells you the module's name, its memory footprint, how many other things are currently using it, and — in brackets — which other loaded modules depend on it.

---

## Part II: Look Before You Load

Suppose a request comes in to load the `dummy` network interface module — a virtual network device useful for testing — configured with two virtual interfaces instead of the default of none. The temptation is to guess the parameter name and just try it. Resist that temptation; check first:

```bash
modinfo dummy
modinfo -p dummy
```

`man modinfo` documents the `-p` flag specifically: it filters the output down to only the module's declared `parm:` lines — each one showing a parameter's exact name and accepted type, e.g. `numdummies:Number of dummy devices to create (int)`. This is a ten-second check that eliminates an entire category of frustration. A misspelled or nonexistent parameter passed to `modprobe` doesn't always throw a helpful error — sometimes it's silently ignored — and discovering that after the fact, under time pressure, costs far more than the ten seconds `modinfo -p` would have taken up front.

---

## Part III: Loading With a Parameter, Live

```bash
sudo modprobe dummy numdummies=2
```

Notice this uses `modprobe`, not the lower-level `insmod`. `man modprobe` and `man insmod` together make the distinction clear: `insmod` loads exactly the one `.ko` file you hand it, and fails outright if a dependency isn't already loaded. `modprobe` consults a dependency database (built ahead of time by `depmod`) and automatically loads any prerequisite modules first. It's the same "friendlier interface over the same underlying mechanism" pattern you saw with `sysctl` sitting on top of raw `/proc/sys` — `modprobe` is almost always the right default, with `insmod`/`rmmod` reserved for very low-level, single-file scenarios.

Verify the load took, and that the parameter actually applied:

```bash
lsmod | grep dummy
cat /sys/module/dummy/parameters/numdummies
```

That second command opens a door worth remembering: `/sys/module/<name>/parameters/` exposes a *currently loaded* module's live parameter values directly — the module-level equivalent of reading a live value out of `/proc/sys`. It tells you what's actually in effect right now, independent of whatever any config file claims should be in effect.

---

## Part IV: Two Separate Files for Two Separate Questions

This is the single most important structural fact in this chapter, and it's easy to get backwards under pressure: **whether a module loads at boot** and **what parameters it loads with** are governed by two completely separate config file families.

**"Should this load at all?"** — `/etc/modules-load.d/*.conf`:

```bash
echo "dummy" | sudo tee /etc/modules-load.d/dummy.conf
```

`man 5 modules-load.d` describes this file family as deliberately minimal: one bare module name per line, read by `systemd-modules-load.service` at boot. There is no room in this file for parameters — it only ever answers the yes/no question of whether to load the module.

**"With what arguments?"** (and, separately, **"should it be blocked from auto-loading?"**) — `/etc/modprobe.d/*.conf`:

```bash
echo "options dummy numdummies=2" | sudo tee /etc/modprobe.d/dummy.conf
```

`man 5 modprobe.d`, searching for `options`, documents this directive as exactly what `modprobe` — and the boot-time module loader — consults to know what arguments to pass, no matter what actually *triggered* the load, whether that was `/etc/modules-load.d/`, an explicit `modprobe` command, or automatic hardware detection. Without this file, the boot-time load from the previous step would load `dummy` with zero interfaces created, silently missing the entire point of the request.

A clean way to prove the persistent config — not just your earlier interactive command — is what's actually driving the value, without waiting for a real reboot:

```bash
sudo modprobe -r dummy
sudo modprobe dummy
cat /sys/module/dummy/parameters/numdummies
# 2
```

Reloading with a bare `modprobe dummy` — no `numdummies=` typed on the command line this time — and watching the parameter still come out as `2` is solid proof the config file is doing the work.

---

## Part V: Blacklisting — What It Does, and What It Very Deliberately Does Not Do

Now suppose the opposite request: the `pcspkr` module (the PC speaker beep driver) has started triggering an annoying hardware beep on every kernel warning, and it must never load automatically again — even though the hardware that would normally trigger its auto-detection is still physically present.

```bash
echo "blacklist pcspkr" | sudo tee /etc/modprobe.d/blacklist-pcspkr.conf
```

Here is the sharp edge every exam-style question about blacklisting is testing for, so read this twice: **a blacklist entry only blocks the *automatic*, hardware-detection-driven load path.** `man 5 modprobe.d`, searching for `blacklist`, documents exactly this — it tells udev's alias-matching machinery to skip this module even when a device's ID would normally trigger it. It does not delete the module file. It does not make the module unloadable. And critically, it does **not** stop someone from explicitly typing `sudo modprobe pcspkr` — that command will still succeed, blacklist or no blacklist, because it's a direct, explicit request rather than an automatic one.

Think of a blacklist entry as removing a name from the guest list at an automatic door — anyone who walks up and explicitly announces themselves by name still gets let in. The blacklist only stops the automatic greeter from waving them through without being asked.

If the module is already loaded — which it likely is, since that's *why* it's currently beeping — the blacklist won't touch that already-running instance. It has to be unloaded once, separately, right now:

```bash
sudo modprobe -r pcspkr
```

Then simulate what a fresh hardware re-detection pass would do, without needing an actual reboot:

```bash
sudo udevadm trigger
lsmod | grep pcspkr
```

`udevadm trigger` re-fires synthetic device-detection events for hardware that's already present, which is the closest simulation of "reboot and let auto-detection run again" available without physically restarting the machine. If `pcspkr` stays absent from `lsmod` afterward, the blacklist is holding against the automatic path exactly as designed.

---

## Self-Check and Verification

1. **Two files, two questions**: Which file answers "should this module load at boot," and which one answers "with what parameters"? *(Answer: `/etc/modules-load.d/*.conf` for whether to load; `/etc/modprobe.d/*.conf` (`options` directive) for parameters.)*
2. **The blacklist trap**: Does blacklisting a module prevent `sudo modprobe modulename` from working afterward? *(Answer: No — a blacklist only blocks the automatic hardware-detection load path, never an explicit request.)*
3. **Already loaded**: If a module is blacklisted while it's currently loaded, does the blacklist unload it? *(Answer: No — blacklisting only affects future automatic loads; an already-loaded module must be unloaded separately with `modprobe -r`.)*
4. **Simulating a reboot**: What command re-triggers hardware detection against already-connected devices without an actual reboot? *(Answer: `sudo udevadm trigger`.)*

You've now seen the module-management analog of everything from Chapter 1: a live, in-memory action (`modprobe`) and its persistent counterpart (a config file under `/etc/`), plus a new wrinkle — the automatic-versus-explicit distinction that blacklisting depends on. The lab ahead asks you to apply both halves of this chapter in one sitting.
