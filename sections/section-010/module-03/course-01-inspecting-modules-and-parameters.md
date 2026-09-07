# Part 1 — Inspecting modules and their parameters

> Prerequisite: [module landing page](./course.md). Next: [Part 2 — Loading: modprobe, depmod, and the dependency graph](./course-02-loading-modprobe-and-dependencies.md).

A loadable kernel module is kernel functionality added at runtime instead of at compile time — a driver, a filesystem, a protocol handler. Before you load one you want to know what is already loaded, what parameters a module accepts, and how to read a loaded module's live parameter values. This part is those three read-only skills; nothing here changes the system.

## What is loaded: `lsmod` and `/proc/modules`

```bash
# shell: any host, unprivileged
lsmod | head -4
```

```text
Module                  Size  Used by
dummy                  16384  0
nf_tables             229376  1
xt_conntrack           16384  2 iptable_filter,ip6table_filter
```

`lsmod` is a thin formatter over `/proc/modules` — the kernel's own list, readable directly when `lsmod` is not installed:

```bash
cat /proc/modules
```

Each row: the module **name**; its **size** in bytes of kernel memory; a **reference count** (how many things are using it — a module with a non-zero count cannot be unloaded); and in brackets the **dependent modules** currently holding it. `xt_conntrack` above has refcount 2, held by `iptable_filter` and `ip6table_filter` — unloading it means unloading those first.

## What parameters a module accepts: `modinfo`

Never guess a parameter name. Ask the module:

```bash
modinfo dummy          # full metadata: path, license, deps, description, parm: lines
modinfo -p dummy       # just the parameter declarations
```

```text
numdummies:Number of dummy pseudo devices (int)
```

`man modinfo`: `-p` filters to the module's declared `parm:` lines. Each shows the exact parameter **name**, a description, and the **type** in parentheses (`int`, `bool`, `charp` for a string, `array of int`, …). This is a ten-second check that prevents a whole class of silent failure: `modprobe` passing an unknown `key=value` does **not** reliably error — the bogus key can be ignored, and you discover it only when the behaviour you wanted never happened.

`modinfo` also shows `depends:` (modules that must load first — Part 2) and `filename:` (the `.ko` path, under `/lib/modules/$(uname -r)/`).

## What a loaded module is actually running with: `/sys/module`

```bash
cat /sys/module/dummy/parameters/numdummies
```

`/sys/module/<name>/parameters/` exposes the **live parameter values of a currently loaded module** — one file per parameter, exactly analogous to reading a live sysctl out of `/proc/sys`. It reports what is in effect *right now*, independent of any config file. Not every parameter is world-readable, and some are not represented at all if the module did not expose them (`0644` vs `0000` on the file), but for anything writable-at-load it is the ground truth.

`/sys/module/<name>/` also carries `refcnt` (same number `lsmod` shows), `holders/` (the dependent modules), and `initstate` (`live`).

> [!WARNING]
> - **Guessing a parameter name.** A misspelled `key=` on `modprobe` may be silently dropped, not rejected. `modinfo -p` first, every time.
> - **Assuming a config file reflects the loaded state.** `/sys/module/<name>/parameters/` is what the module is running with now; a `.conf` under `/etc` is only what a *future* load will use (Part 3).

> *`lsmod`/`/proc/modules` shows what's loaded and its refcount and dependents; `modinfo -p` shows the parameter names and types a module accepts; `/sys/module/<name>/parameters/` shows what a loaded module is actually running with.*

## Reference

- `man lsmod` — the `/proc/modules` columns and what refcount / "Used by" mean.
- `man modinfo` — `-p` (parameters), `-F` (one field), `-n` (filename); reading `parm:` types.
- `man 5 sysfs` — `/sys/module/` layout: `parameters/`, `refcnt`, `holders/`, `initstate`.
