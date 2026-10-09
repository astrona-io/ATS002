# Building, Installing And Verifying

Astronaut, once `configure` has written the fitting plan, building the part and bolting it into place is the easy bit. But "I passed the right flags" does not prove the job is done. This part covers the build and install, a few install options worth knowing, and how to check **both** halves of a requirement, the path *and* the feature, on the built program itself.

## Build and install

Two commands do the work here. `make` reads the `Makefile` and calls the compiler. `make install` copies the result into place.

### Run the build

```bash
# shell: inside the source dir
make
sudo make install
```

On many projects, `configure` prints a **summary** near the end of its run, with the features it found and the install paths it chose. Read it before you start a slow `make`. It is a free check that your flags landed.

### Three ways to install

You will meet these install options in real work:

- **`sudo make install`** copies straight into the live system folders that `configure` chose.
- **`make install DESTDIR=/tmp/stage`** copies into `/tmp/stage/usr/bin/...` instead. This is a *staging* tree, a practice copy of the folders. People who build packages use it to collect the files without touching the real system. `make` puts `DESTDIR` in front of every path, so `--bindir` and the other folders land inside it.
- **`make install prefix=/opt/links`** works on some Makefiles. It changes the prefix at install time without running `configure` again.

Removing a source build is not always possible. `make uninstall` exists only if the project wrote that target. That is why `--prefix=/usr/local` (or `/opt/<name>`) is the safe default: everything sits under one folder that you can remove.

## Verify both halves, on the built program

Passing `--bindir=/usr/bin --disable-ipv6` is not proof. After `make install`, check each requirement on its own.

### Three checks

```bash
# 1. exact path — does it resolve from $PATH at the path asked for?
command -v links
# /usr/bin/links

# 2. real compiled binary — not a script, not a dangling symlink
file /usr/bin/links
# /usr/bin/links: ELF 64-bit LSB executable, dynamically linked, ...

# 3. the feature toggle actually took — trust the binary's own report
links -version
# links 2.14
# Features: ...   (ipv6 must NOT appear as enabled)
```

The output lines in the comments are shortened.

### What each check proves

Each command answers one question, and each one asks a different part of the system:

- **`command -v`** (or `which`) asks bash which file it would run for that name. It confirms the path. Use the exact path the task gave.
- **`file`** reads the first bytes of the file and confirms it is a real ELF binary (ELF is the format of compiled Linux programs). A source build gone wrong can leave a wrapper script or a broken link instead.
- **The program's own `--version`, `-version` or `--help`** is the most direct proof that a built-in switch worked. Trust what the built program says about itself over what you think the flags did. Some programs do not report their features. Then `ldd` can help: it lists the shared libraries a binary uses (`ldd /usr/bin/links | grep -i inet6` would show whether an IPv6 library is even linked).

## Closing the filename gap

`--bindir` fixed the **folder**, but the `Makefile` chooses the **file name**. Say the build installed `/usr/bin/links2`, but the task wants `/usr/bin/links`:

```bash
ls -l /usr/bin/links /usr/bin/links2 2>&1     # check FIRST
sudo mv /usr/bin/links2 /usr/bin/links        # only if it is not already correct
```

Many source trees already build the exact name. Moving a file that is already right is a wasted step that can only cause trouble, so always run `ls` first.

> [!TIP]
> Make "check the result on the system itself" an exam habit. After any install, ask the built program and the file system, not your memory of the flags you typed.

## Common pitfalls

> [!WARNING]
> - **Treating "I passed the flags" as done.** Verify the path with `command -v` and `file`, and the feature with the program's own version output, each on its own.
> - **`mv`-ing the binary without checking.** `--bindir` controls the folder, not the file name; the project may already use the right name. `ls` first.
> - **Assuming `make uninstall` exists.** It only does if the project wrote it. Prefer a single install folder (`/usr/local`, `/opt/<name>`) so removal is `rm -rf` of one tree.
> - **Reading `configure`'s summary as the final proof.** It reports what you asked for; the installed binary reports what you got. Check the binary.

> *After `make && sudo make install`, verify the path with `command -v` and `file`, and the feature switch with the program's own version output, each on its own. Only rename the binary after `ls` shows the build did not already use the required name.*

## Your mission: Compile & Install From Source Lab

You can now unpack a source tarball, find the flags you need, build and install a program, and prove the result on the program itself. The mission asks you to build a terminal web browser from source so it lands at an exact path with one feature switched off.

Start the mission and open a terminal on it:

```sh
astrona run --git git@github.com:astrona-io/ATS002.git -c sections/section-030/module-01/labs/lab-01
astrona ssh ats-002-lab-031
```

Read the task in [`question.md`](./labs/lab-01/question.md) and solve it on your own first. When you think you are done, send it for grading:

```sh
astrona submit -c sections/section-030/module-01/labs/lab-01
```

When the mission is done, remove it:

```sh
astrona destroy ats-002-lab-031
```
