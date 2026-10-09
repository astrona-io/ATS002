# Wrap-Up: Mission Debrief

Well flown, astronaut. You can now fit a ship out with a whole bundle of crates in one order, and retire it again knowing exactly what leaves. Look back at what you learned, check yourself, and clean up anything still running.

## What you learned

This module was about `dnf` package groups, from finding one to removing it.

**From [What a Group Is and Finding One](./course-01-what-a-group-is-and-discovering.md):**

- A group is a named, tiered set of packages that the repository maintainer publishes in the catalogue (comps metadata).
- `dnf group list` shows the visible groups; `dnf group list --hidden` shows the rest.
- `dnf group <subcommand>` is the current spelling of the older `grouplist` and `groupinfo` commands.

**From [Inspecting and Installing a Group](./course-02-inspecting-and-installing.md):**

- `dnf group info "<group>"` reads the Mandatory, Default and Optional tiers without installing anything.
- `dnf group install "<group>"` installs the Mandatory and Default members in one transaction.
- Optional members come only with `--with-optional` or when you name them. Quote group names that contain spaces.

**From [Confirming and Removing a Group](./course-03-confirming-and-removing.md):**

- After an install, `dnf group info` marks installed members, and `dnf group list installed` lists the group.
- `dnf group remove` removes what `dnf` recorded as installed by the group: a package that was there before (`automake`) stays, a package the group brought in (`gcc`) goes.
- Check the result again with `dnf group list installed`.

## Your missions

You proved these skills in a graded mission, right after the part that taught the last of them:

| Mission | After the part | What you proved |
| --- | --- | --- |
| [DNF Package Groups Lab](./labs/lab-01/README.md) | Confirming and Removing a Group | found, inspected, installed and removed `"Development Tools"`, and showed which packages the removal left |

## Check yourself

Try to answer each question before you open the answer.

<details>
<summary>1. A group you expect is missing from <code>dnf group list</code>. What do you try before deciding it does not exist?</summary>

`dnf group list --hidden`. Repositories can hide some groups from the plain listing.
</details>

<details>
<summary>2. Where does a group's member list come from?</summary>

From the repository's own catalogue (comps metadata), published by the repository maintainer. It is not a naming pattern.
</details>

<details>
<summary>3. A package is listed under Optional Packages. Does <code>dnf group install</code> install it?</summary>

No. Only Mandatory and Default members install by default. Use `--with-optional` or name the package.
</details>

<details>
<summary>4. Why must you quote <code>"Development Tools"</code>?</summary>

The name has a space. Without quotes the shell passes `Development` and `Tools` as two separate arguments.
</details>

<details>
<summary>5. <code>automake</code> was installed before the group install. Is it removed by <code>dnf group remove "Development Tools"</code>?</summary>

No. `dnf` only removes what it recorded as installed by that group. `automake` was already there, so it stays.
</details>

<details>
<summary>6. <code>gcc</code> was installed by the group install. Does it survive the group removal?</summary>

No. `dnf` recorded it as part of the group, so the removal takes it. Install it again yourself if something still needs it.
</details>

## Clean up

Each mission runs a virtual machine on your computer. When you are done with this module, remove any mission that is still running.

First, see what is still running:

```sh
astrona list
```

If the mission is still there, remove it. The command takes its **name**, not its folder path:

```sh
astrona destroy ats-002-lab-065
```
