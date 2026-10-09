# Inspecting Modules And Their Parameters

Astronaut, a **kernel module** is a plug-in reactor part: a piece of kernel code, such as a device driver, a filesystem or a network protocol, that the kernel can fit or remove while the ship is flying. It is added at runtime instead of being built into the kernel image. Before you fit one, you want to know three things: which parts are already fitted, which settings a part accepts, and which settings a fitted part is running with right now.

This part teaches those three read-only skills. Nothing here changes the system.

## What is loaded: `lsmod` and `/proc/modules`

The kernel keeps its own list of every module it has loaded. Two tools read that list, and they show the same data.

### Read the list

<!-- astrona:playground:renew -->

Ask for the first few loaded modules:

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

This output came from a machine where `dummy` was already loaded, so your list will look different. `lsmod` only formats a file that the kernel writes: `/proc/modules`. You can read that file directly when `lsmod` is not installed:

```bash
cat /proc/modules
```

### What each column means

Each row has four pieces of information:

- The module **name**.
- Its **size**: how many bytes of kernel memory it uses.
- Its **reference count** (refcount): how many things are using it right now. The kernel will not unload a module whose count is above zero.
- In the last column, the **dependent modules** that are holding it.

In the output above, `xt_conntrack` has a reference count of 2. The modules `iptable_filter` and `ip6table_filter` hold it. To unload `xt_conntrack`, you must unload those two first.

## What parameters a module accepts: `modinfo`

A **module parameter** is a setting chosen when the part is fitted, for example "how many interfaces to create". Never guess a parameter name. Ask the module itself.

### Ask the module

```bash
modinfo dummy          # full metadata: path, license, deps, description, parm: lines
modinfo -p dummy       # just the parameter declarations
```

```text
numdummies:Number of dummy pseudo devices (int)
```

The `-p` option shows only the module's declared `parm:` lines. Each line gives the exact parameter **name**, a description, and the **type** in brackets. Common types are `int` (a whole number), `bool` (yes or no), `charp` (a piece of text) and `array of int` (a list of numbers).

### Why this ten-second check matters

`modprobe` does not always reject an unknown `key=value`. It may ignore a misspelled key without any error. You only find out later, when the behaviour you wanted never happens. Checking the name with `modinfo -p` first stops that whole class of silent failure.

`modinfo` also shows two other useful fields. `depends:` lists the modules that must load first. `filename:` gives the path of the `.ko` file (the module file on disk), under `/lib/modules/$(uname -r)/`.

## What a loaded module is running with: `/sys/module`

A configuration file says what a *future* load will use. To see what a loaded module uses *right now*, read its live values from `/sys`.

### Read a live value

```bash
cat /sys/module/dummy/parameters/numdummies
```

This folder exists only while `dummy` is loaded. On a fresh playground nothing is loaded yet, so the command fails until you load the module.

The kernel publishes the folder `/sys/module/<name>/parameters/` for each loaded module. It holds one file per parameter, and each file holds the value in effect right now. This works just like reading a live kernel setting from `/proc/sys`: the kernel answers directly, whatever any configuration file says.

Some parameters are not readable by everyone, and a module may choose not to publish a parameter at all (the file mode is `0644` or `0000`). But for any parameter you can set at load time, this folder shows the real value.

### Other files in the same folder

`/sys/module/<name>/` holds a few more useful files:

- `refcnt`: the same reference count that `lsmod` shows.
- `holders/`: the dependent modules.
- `initstate`: `live` when the module is loaded and running.

The manual pages on the machine explain all of this in more detail: `man lsmod`, `man modinfo` (the `-p`, `-F` and `-n` options) and `man 5 sysfs`.

## Try it: inspect before you load

Run these three read-only commands in your playground:

```bash
lsmod | head -3
modinfo -p dummy
modinfo -F depends dummy
```

Expect something like:

```text
Module                  Size  Used by
nf_tables             229376  1
...
numdummies:Number of dummy pseudo devices (int)

```

`modinfo -p` shows that `dummy` accepts exactly one parameter, `numdummies`, which is an `int`. The `depends` line is empty, so nothing has to load first. Now you know the real name to pass, instead of guessing.

> *`lsmod` and `/proc/modules` show what is loaded, with its reference count and dependents. `modinfo -p` shows the parameter names and types a module accepts. `/sys/module/<name>/parameters/` shows what a loaded module is running with now.*

## Common pitfalls

> [!WARNING]
> - **Guessing a parameter name.** `modprobe` may drop a misspelled `key=` without an error. Run `modinfo -p` first, every time.
> - **Thinking a configuration file shows the loaded state.** `/sys/module/<name>/parameters/` shows what the module is running with now. A `.conf` file under `/etc` only says what a *future* load will use.
