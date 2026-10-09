# Wrap-Up: Mission Debrief

Well flown, astronaut. You can now run the quartermaster's whole routine supply run, and reverse it when it goes wrong. Look back at what you learned, check yourself, and clean up anything still running.

## What you learned

This module was about the everyday `dnf` loop and the transaction log behind it.

**From [The Everyday dnf Loop](./course-01-the-dnf-loop.md):**

- `dnf check-update` lists available updates and exits with `100` when there are any, `0` when there are none.
- `dnf` refreshes its catalogue by itself, so there is no separate `apt update`-style step. `dnf makecache` or `--refresh` forces a refresh.
- `dnf upgrade` applies one solver-computed plan; there is no `full-upgrade` split.
- `dnf install` takes one or more names. If a package seems missing, check whether it needs EPEL.

**From [Removing and Transaction History](./course-02-removing-and-history.md):**

- `dnf remove` has no purge choice. An edited `%config` file becomes `.rpmsave`; an unchanged one is deleted. `.rpmnew` appears on upgrade.
- `dnf autoremove` removes leftover dependencies as a separate step.
- `dnf history` and `dnf history info <id>` show the log. `dnf history undo <id>` reverses a whole transaction in one step, and `dnf history redo <id>` applies it again.

## Your missions

You proved these skills in a graded mission, right after the part that taught the last of them:

| Mission | After the part | What you proved |
| --- | --- | --- |
| [DNF Basic Package Operations Lab](./labs/lab-01/README.md) | Removing and Transaction History | ran a maintenance window, removed a package and its leftovers, and undid a mixed install from the log |

## Check yourself

Try to answer each question before you open the answer.

<details>
<summary>1. A script runs <code>dnf check-update</code> and gets exit code <code>100</code>. Did it fail?</summary>

No. `100` means updates are available. `0` means there are none.
</details>

<details>
<summary>2. Do you need to refresh the catalogue before <code>dnf upgrade</code>, like <code>apt update</code> on Debian?</summary>

No. `dnf` refreshes its catalogue by itself when the local copy is too old. `dnf makecache` or `--refresh` forces a refresh if you want one.
</details>

<details>
<summary>3. You edited <code>/etc/app.conf</code>, a <code>%config</code> file, and then removed the package. What happens to your edit?</summary>

RPM renames the file to `/etc/app.conf.rpmsave` instead of deleting it. An unchanged `%config` file would have been deleted.
</details>

<details>
<summary>4. You removed a package, but the libraries it pulled in are still installed. Which command cleans them up?</summary>

`dnf autoremove`. `dnf remove` never removes leftover dependencies by itself.
</details>

<details>
<summary>5. A colleague installed two packages in one command, and one was a mistake. How do you reverse the whole transaction?</summary>

Find its ID with `dnf history`, check it with `dnf history info <id>`, then run `dnf history undo <id>`. Then install the wanted package again on its own.
</details>

<details>
<summary>6. You undid a transaction by mistake. How do you apply it again?</summary>

`dnf history redo <id>`.
</details>

## Clean up

Each mission runs a virtual machine on your computer. When you are done with this module, remove any mission that is still running.

First, see what is still running:

```sh
astrona list
```

If the mission is still there, remove it. The command takes its **name**, not its folder path:

```sh
astrona destroy ats-002-lab-063
```
