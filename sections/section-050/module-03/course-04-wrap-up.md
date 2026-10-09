# Wrap-Up: Mission Debrief

Well flown, astronaut. You have finished every part and the mission in this module. Before you move on, look back at what you learned, check yourself, and clean up anything still running.

## What you learned

This module was about the everyday `apt` loop: refresh the catalogue, upgrade, install, and retire packages cleanly.

**From [Update Is Not Upgrade](./course-01-update-is-not-upgrade.md):**

- `sudo apt update` only downloads each repository's package index again. It installs, upgrades and removes nothing.
- Without a fresh `apt update`, later commands work from an old catalogue and can miss packages or fixes.
- `apt list --upgradable` is a read-only preview of what an upgrade would change.

**From [Applying Upgrades And Installing](./course-02-applying-upgrades-and-installing.md):**

- `apt upgrade` changes versions but never adds or removes a package.
- Packages that need an add or remove are "kept back"; `apt full-upgrade` (the same as `apt-get dist-upgrade`) does that work, once you have reviewed the list.
- `apt install <name>` resolves dependencies and installs everything in one transaction.

**From [Removing Cleanly](./course-03-removing-cleanly.md):**

- `apt remove` keeps the package's conffiles under `/etc` (state `rc`); `apt purge` deletes them.
- `apt autoremove` is a separate step that removes orphaned dependencies.
- Use `apt` at the keyboard and the stable `apt-get` and `apt-cache` in scripts.

## Your missions

You proved these skills in a graded mission, right after the part that taught the last of them:

| Mission | After the part | What you proved |
| --- | --- | --- |
| [APT Basic Package Operations Lab](./labs/lab-01/README.md) | Removing Cleanly | ran a maintenance loop, installed `fail2ban`, purged `ftp` with its configuration, and left no orphans behind |

If you skipped it, go back to it now. The exam asks for exactly these skills.

## Check yourself

Try to answer each question before you open the answer.

<details>
<summary>1. What does <code>sudo apt update</code> change about the installed packages?</summary>

Nothing. It only downloads each repository's package index again, so later commands see current versions.
</details>

<details>
<summary>2. How do you see what an upgrade would change without changing anything?</summary>

Run `apt list --upgradable` after `sudo apt update`.
</details>

<details>
<summary>3. Why does <code>apt upgrade</code> keep some packages back?</summary>

Upgrading them would mean adding or removing another package, and plain `upgrade` never changes the package set. Review the list, then run `sudo apt full-upgrade` if the change is expected.
</details>

<details>
<summary>4. A task says "remove the package completely, including its configuration". Which command do you use?</summary>

`sudo apt purge <package>`. `remove` would leave the conffiles under `/etc`.
</details>

<details>
<summary>5. After <code>apt purge</code>, some dependency packages are still installed although nothing needs them. What do you run?</summary>

`sudo apt autoremove`. Neither `remove` nor `purge` cleans up orphans on its own.
</details>

<details>
<summary>6. What does <code>rc</code> mean in <code>dpkg -l</code>?</summary>

The package was removed, but its configuration files remain. `apt purge` clears it.
</details>

<details>
<summary>7. Should a script call <code>apt</code> or <code>apt-get</code>?</summary>

`apt-get` (and `apt-cache` for queries). `apt`'s output is not guaranteed to stay the same between releases.
</details>

## Clean up

Each mission runs a virtual machine on your computer. When you are done with this module, remove any mission that is still running.

First, see what is still running:

```sh
astrona list
```

If the mission is still there, remove it. The command takes its **name**, not its folder path:

```sh
astrona destroy ats-002-lab-053
```

Then check that everything is gone:

```sh
astrona list
```
