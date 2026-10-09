# Refresh, Updates and Patches

Every package manager refreshes its catalogue and then asks one question: "is there a newer version?" SUSE systems ask a second, separate question: "has the vendor published a **patch** that covers this system?" These are not the same question. Mixing them up is how a SUSE administrator drifts out of policy.

This part covers `zypper refresh` and the two lists it feeds. Run every command inside the `zypperbox` container (`docker exec -it zypperbox bash`), because the Ubuntu host has no `zypper`.

## `zypper refresh`: update the local catalogue

Start by downloading a fresh copy of each depot's catalogue:

```bash
# shell: inside the zypperbox container
zypper refresh          # shorthand: zypper ref
```

```text
Repository 'Main Update Repository' is up to date.
All repositories have been refreshed.
```

`zypper` fetched the **metadata** of every configured repository. Metadata is the depot's catalogue: which package versions each depot offers and, on SUSE, which patches it has published. It works like `apt update` on Ubuntu. It changes nothing that is installed.

If you skip this step, every question you ask afterwards is answered from an old catalogue.

## `list-updates`: plain version comparison

Now ask the first question:

```bash
zypper list-updates      # shorthand: zypper lu
```

For every installed package, `zypper` checks whether a configured repository offers a newer version. There is no review and no sorting into categories, only a comparison of version numbers. Every other package manager shows the same kind of "a newer version exists" list.

## `list-patches`: reviewed patch objects

Then ask the second question:

```bash
zypper list-patches      # shorthand: zypper lp
```

This lists SUSE's **patch objects**. Think of a patch as a safety notice from the depot that names exactly which crates to replace. A repository maintainer put it together on purpose, reviewed it and published it under a name, so it can be tracked.

Each patch has a **category** (`security`, `recommended`, or `optional`, which is for new features) and a **severity** (how serious it is). Many patches fix one known security hole, often named by its CVE number (Common Vulnerabilities and Exposures, a public ID for one security flaw). One patch can bundle the updates of several packages into one unit you can track.

To narrow the list, add a filter: `zypper lp --category security` shows only security patches, and `zypper lp --severity important` shows only important ones. `zypper patch-check` gives a quick count of pending patches by category, which helps you decide whether a maintenance window is needed. `zypper patch-info <patch name>` prints the full notice for one patch.

## The two lists do not have to match

This is the surprise for anyone coming from Debian or Fedora. A package can show up in `zypper list-updates` with a newer version waiting in the repository, yet have **no patch covering it yet**. Then `zypper list-patches` never mentions it. That is not a bug.

Picture the ship's supply line. The depot's shelves quietly fill with newer crates all the time: that is `zypper list-updates`. A safety notice is different: someone at the depot reviewed a problem and sent a notice naming exactly which crates to swap and why: that is `zypper list-patches`. Not every notice is urgent, though. Besides `security`, patch categories include the calmer `recommended` and `optional`.

So patches are a reviewed layer on top of the raw stream of new versions, not a second view of the same data. In short: `zypper refresh` updates the local metadata (versions and patch definitions), `zypper list-updates` shows "a newer version exists", and `zypper list-patches` shows SUSE's reviewed, categorised patches.

## Common pitfalls

> [!WARNING]
> - **Treating `list-updates` and `list-patches` as the same list in two formats.** They are different layers. A package with a newer version may have no patch, and the other way round.
> - **Skipping `zypper refresh`.** Both lists, and any patch or update you then apply, come from old metadata.
> - **Assuming every `list-patches` entry is about security.** Check the Category column. `recommended` and `optional` patches appear too.
