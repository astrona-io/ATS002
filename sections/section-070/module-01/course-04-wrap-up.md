# Wrap-Up: Mission Debrief

Well flown, astronaut. You have finished every part and the mission in this module. Before you move on, look back at what you learned, check yourself, and clean up anything still running.

## What you learned

This module was about the everyday `zypper` loop on openSUSE: refresh the catalogue, choose between patches and updates, install and remove, and read the log.

**From [Refresh, Updates and Patches](./course-01-refresh-updates-vs-patches.md):**

- `zypper refresh` downloads fresh repository metadata (package versions and patch definitions) and changes nothing that is installed.
- `zypper list-updates` is a plain version comparison: "a newer version exists".
- `zypper list-patches` shows SUSE's reviewed patch objects, each with a category (`security`, `recommended`, `optional`) and a severity.
- The two lists can differ, and that is normal.

**From [Applying Patches or Updates](./course-02-applying-the-right-one.md):**

- `zypper patch` applies only what a published patch covers. Narrow it with `--category security` or `--severity important`.
- `zypper update` applies every newer version, patch or not.
- Words like "conservative" or "patch window" mean `zypper patch`; "fully up to date" means `zypper update`.

**From [Installing, Removing and Reading History](./course-03-install-remove-history.md):**

- `zypper in` and `zypper rm` install and remove. The RPM layer keeps changed configuration files as `.rpmsave`, and there is no `zypper purge`.
- `zypper history` and the file `/var/log/zypp/history` are an audit log. There is no `zypper history undo`; you reverse changes by hand.

## Your missions

You proved these skills in a graded mission, right after the part that taught the last of them:

| Mission | After the part | What you proved |
| --- | --- | --- |
| [Zypper Basic Package Operations Lab](./labs/lab-01/README.md) | Installing, Removing and Reading History | ran a conservative maintenance pass: refresh, patches only, install `fail2ban`, remove `telnet-server`, and a history log that records it |

If you skipped it, go back to it now. The exam asks for exactly these skills.

## Check yourself

Try to answer each question before you open the answer.

<details>
<summary>1. What does <code>zypper refresh</code> change on the system?</summary>

Only the local copy of the repository metadata: which versions and patches each repository offers. No installed package changes.
</details>

<details>
<summary>2. A package shows up in <code>zypper list-updates</code> but not in <code>zypper list-patches</code>. Is something broken?</summary>

No. A newer version exists, but no patch covers it yet. Patches are a reviewed layer on top of the raw stream of new versions, so the two lists can differ.
</details>

<details>
<summary>3. The policy says "apply security fixes promptly, but do not chase every version bump". Which command fits?</summary>

`zypper patch`, or `zypper patch --category security` if only security patches are wanted. `zypper update` would apply every newer version.
</details>

<details>
<summary>4. After <code>zypper patch</code>, <code>zypper list-updates</code> still shows packages. Why?</summary>

Those packages have a newer version that no patch covers. `zypper patch` leaves them alone on purpose.
</details>

<details>
<summary>5. You remove a package whose configuration file in <code>/etc</code> you had edited. What happens to that file?</summary>

RPM keeps it, renamed with an `.rpmsave` ending. Unchanged configuration files are deleted with the package.
</details>

<details>
<summary>6. You removed a package by mistake. How do you undo it with <code>zypper</code>?</summary>

Reinstall it with `zypper in <pkg>`. There is no `zypper history undo`; the history log only tells you what happened.
</details>

<details>
<summary>7. Where does <code>zypper</code> keep its history log as a plain file?</summary>

In `/var/log/zypp/history`. You can read it with `tail`, `grep` or `awk`.
</details>

## Clean up

Each mission runs a virtual machine on your computer. When you are done with this module, remove any mission that is still running.

First, see what is still running:

```sh
astrona list
```

If the mission is still there, remove it. The command takes its **name**, not its folder path:

```sh
astrona destroy ats-002-lab-071
```
