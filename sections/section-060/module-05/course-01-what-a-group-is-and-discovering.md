# What a Group Is and Finding One

Astronaut, "load one crate" and "fit this ship out as a build station" are different kinds of order. `dnf` answers the second with a real, first-class idea, the **group**, that Debian's `apt` has no match for. This part explains what a group actually is and how to see the ones a ship's repositories publish.

## A group is repository-published metadata

A **group** is a named set of packages with its own member tiers. The **repository maintainer publishes it** in the repository's catalogue, in a format called "comps" (an XML file that `dnf` took over from its older predecessor, `yum`). Think of it as a ready-made bundle of crates that the supply depot lists in its catalogue.

So a group is not a naming habit you search for with `grep`, and not a list you build from memory. It is data that ships with the repository, and it exists whether or not anything is installed on your system. On Debian, the nearest you get is a hand-picked list of package names; `dnf group` is the real thing.

## Discovering the groups that exist

You find groups the same way you find packages: by asking `dnf` to read the catalogue.

### dnf group list

```bash
# shell: inside the rpmbox container
dnf group list
```

This lists every group that the enabled repositories show by default, split into **Installed Groups** and **Available Groups**. The listing can also show **Environment Groups**: larger bundles built from several groups, which `dnf` handles with the same `group` commands.

### Hidden groups

A repository can mark some groups as **hidden**, usually internal or rarely needed ones, to keep the plain listing short:

```bash
dnf group list --hidden
```

Reach for `--hidden` whenever a group you expect does not appear in the plain listing, before you decide it is not published at all. `dnf group list ids` shows each group's short ID beside its display name, which is useful in scripts.

### Two spellings

Older `dnf` commands such as `dnf grouplist` and `dnf groupinfo` still work and mean the same as `dnf group list` and `dnf group info`. The `dnf group <subcommand>` spelling is the current one.

## Common pitfalls

> [!WARNING]
> - **Assuming a group is "just a package-name prefix".** It is repository-published comps metadata with defined member tiers, not a pattern.
> - **Deciding a group does not exist because `dnf group list` leaves it out.** Try `dnf group list --hidden` first.
> - **Expecting Debian's `apt` to have the same feature.** It does not; a group is a Red Hat family idea.
