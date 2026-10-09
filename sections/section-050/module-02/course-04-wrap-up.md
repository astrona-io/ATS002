# Wrap-Up: Mission Debrief

Well flown, astronaut. You have finished every part and the mission in this module. Before you move on, look back at what you learned, check yourself, and clean up anything still running.

## What you learned

This module was about `dpkg`, the loading crew that unpacks one crate at a time and keeps the ship's package ledger.

**From [What dpkg Knows And Inspecting A .deb](./course-01-dpkg-scope-and-inspecting-a-deb.md):**

- `dpkg` works on one `.deb` file or one installed package name at a time. It has no repositories and fetches nothing.
- `dpkg -I` reads a `.deb` file's control metadata, and `dpkg -c` lists the files it would install. Both are read-only.
- Capital `-I` reads; lower-case `-i` installs.

**From [Installing Directly And Asking Who Owns What](./course-02-installing-and-ownership-queries.md):**

- `sudo dpkg -i <file>.deb` installs a standalone package. On a missing dependency it stops half-way, and `sudo apt --fix-broken install` finishes the job.
- `dpkg -S <path>` tells you which package owns a file; `dpkg -L <name>` lists a package's files.
- `dpkg -s <name>` shows `Status: install ok installed` for a clean install.

**From [Status Codes And Recovering An Interrupted Package](./course-03-status-codes-and-recovery.md):**

- In `dpkg -l`, `ii` is clean, `iU`, `iF` and `iH` mean an interrupted install, and `rc` means removed with configuration files left.
- `sudo dpkg --configure -a` finishes every waiting package; `sudo apt --fix-broken install` right after fetches anything missing.
- `sudo dpkg --audit` prints nothing when no package is left half-done.

## Your missions

You proved these skills in a graded mission, right after the part that taught the last of them:

| Mission | After the part | What you proved |
| --- | --- | --- |
| [dpkg Low-Level Package Management Lab](./labs/lab-01/README.md) | Status Codes And Recovering An Interrupted Package | inspected and installed `logtail-utils` from a `.deb`, checked ownership both ways, and recovered a half-configured `cowsay` |

If you skipped it, go back to it now. The exam asks for exactly these skills.

## Check yourself

Try to answer each question before you open the answer.

<details>
<summary>1. Why can <code>dpkg -i</code> not install a missing dependency?</summary>

`dpkg` knows nothing about repositories. It can only unpack the file you hand it. Fetching another package is `apt`'s job, so you follow up with `sudo apt --fix-broken install`.
</details>

<details>
<summary>2. Which command shows the files inside a <code>.deb</code> before you install it?</summary>

`dpkg -c <file>.deb`. It lists every path with its mode and owner, and changes nothing.
</details>

<details>
<summary>3. You found <code>/usr/bin/logtail</code> and want to know which package put it there. Which command do you run?</summary>

`dpkg -S /usr/bin/logtail`. `-S` takes a file path and prints the owning package.
</details>

<details>
<summary>4. What is the difference between <code>dpkg -S</code> and <code>dpkg -L</code>?</summary>

`-S` takes a file path and returns the owning package. `-L` takes a package name and returns every file it installed.
</details>

<details>
<summary>5. <code>dpkg -l</code> shows <code>iF</code> for a package. What does it mean, and what do you run?</summary>

The package is half-configured: its configure step was interrupted. Run `sudo dpkg --configure -a`, then `sudo apt --fix-broken install`.
</details>

<details>
<summary>6. What does <code>rc</code> mean in <code>dpkg -l</code>?</summary>

The package was removed, but its configuration files are still on disk. `apt purge` clears them.
</details>

<details>
<summary>7. How do you check that no package on the system is left half-done?</summary>

Run `sudo dpkg --audit`. It prints nothing when everything is clean.
</details>

## Clean up

Each mission runs a virtual machine on your computer. When you are done with this module, remove any mission that is still running.

First, see what is still running:

```sh
astrona list
```

If the mission is still there, remove it. The command takes its **name**, not its folder path:

```sh
astrona destroy ats-002-lab-052
```

Then check that everything is gone:

```sh
astrona list
```
