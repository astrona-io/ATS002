# Wrap-Up: Mission Debrief

Well flown, astronaut. You have opened a kit of parts, read its fitting plan, built the part and bolted it into place. Before you move on, look back at what you learned, check yourself, and clean up any mission that is still running.

## What you learned

This module was about installing software from a source tarball, and proving that the result is exactly what the task asked for.

**From [Unpacking The Tarball And The Build Pipeline](./course-01-unpacking-and-the-build-pipeline.md):**

- The extension tells you the compression: `j` for `.tar.bz2`, `z` for `.tar.gz`, `J` for `.tar.xz`. GNU `tar` can also guess it with plain `tar xf`.
- A wrong compression flag fails at once with a decompression error. It never unpacks half a tree.
- `./configure` checks the machine and writes a `Makefile`, `make` builds from it, and `sudo make install` copies the result into system folders.
- Running `make` before `./configure` fails with "No targets specified and no makefile found".
- `configure` is a script of the project, not a system command. There is no `man configure`.

**From [Discovering And Choosing Configure Flags](./course-02-discovering-and-choosing-flags.md):**

- `./configure --help` lists every flag the project accepts. Filter it with `grep -i` for each requirement.
- Path flags (`--prefix`, `--bindir`, `--mandir` and others) decide where files go. Feature switches (`--enable-X`, `--disable-X`, `--with-X`, `--without-X`) decide what code is built in.
- `--prefix` sets the root of the whole install tree, and the binary lands in `$prefix/bin` under the project's own name.
- For an exact binary path, use `--bindir`, which sets the folder directly.

**From [Building, Installing And Verifying](./course-03-building-installing-verifying.md):**

- Read the `configure` summary before a slow `make`: it is a free check.
- `DESTDIR` installs into a staging tree; `make uninstall` exists only if the project wrote it.
- Check the path with `command -v` and `file`, and the feature with the program's own version output.
- `--bindir` sets the folder, not the file name. Run `ls` before you rename anything.

## Your missions

You proved the skill in a graded mission, right after the part that taught it:

| Mission | After the part | What you proved |
| --- | --- | --- |
| [Compile & Install From Source Lab](./labs/lab-01/README.md) | Building, Installing And Verifying | build a program from source to an exact path with one feature switched off |

If you skipped it, go back to it now. It is short, and the exam asks for exactly this skill.

## Check yourself

Try to answer each question before you open the answer.

<details>
<summary>1. You run <code>tar xzf tool-1.0.tar.bz2</code> and get "not in gzip format". What went wrong?</summary>

The archive is bzip2-compressed, but `-z` asks for gzip. Use `tar xjf tool-1.0.tar.bz2`, or plain `tar xf` and let GNU `tar` detect the compression.
</details>

<details>
<summary>2. <code>make</code> says "No targets specified and no makefile found". What did you forget?</summary>

`./configure`. It writes the `Makefile` that `make` reads. Until it has run, there is nothing for `make` to build from.
</details>

<details>
<summary>3. Where do you find the flags a project's <code>configure</code> script accepts?</summary>

In `./configure --help`, inside the unpacked source folder. Every project has its own script, so there is no manual page for it.
</details>

<details>
<summary>4. A task says the binary must be at <code>/usr/bin/tool</code>. Why is <code>--bindir=/usr/bin</code> better than <code>--prefix=/usr</code>?</summary>

`--bindir` sets the program folder directly. `--prefix` only sets the root and works out `$prefix/bin` from it. Neither flag sets the file name, so you still check it with `ls` after the install.
</details>

<details>
<summary>5. What is the difference between <code>--bindir=/usr/bin</code> and <code>--disable-ipv6</code>?</summary>

`--bindir` is a path flag: it changes where the binary is copied, not what is inside it. `--disable-ipv6` is a feature switch: it removes the IPv6 code from the binary.
</details>

<details>
<summary>6. You passed <code>--disable-ipv6</code>. How do you prove it worked?</summary>

Ask the built program, for example with `links -version`, and check that IPv6 is not reported as enabled. The flags you typed and the `configure` summary only show what you asked for.
</details>

<details>
<summary>7. What does <code>make install DESTDIR=/tmp/stage</code> do?</summary>

It copies the files into a staging tree under `/tmp/stage` (for example `/tmp/stage/usr/bin/...`) instead of the live system folders. People who build packages use it.
</details>

## Clean up

This module has no playground. If a mission is still running, remove it.

First, see what is still running:

```sh
astrona list
```

Remove the mission. The command takes its **name**, not its folder path:

```sh
astrona destroy ats-002-lab-031
```

> *Open the crate with the right flag, ask the script for its flags, build and install, then prove the path and the feature on the built program.*
