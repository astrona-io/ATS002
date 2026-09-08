# Part 1 — Refresh, and the two questions: updates vs. patches

> Prerequisite: [module landing page](./course.md). Next: [Part 2 — Applying the right one](./course-02-applying-the-right-one.md).

Every package manager so far refreshes its metadata and then asks "is there a newer version?" SUSE distributions ask a *second*, separate question: "has the vendor published a **patch** that covers this system?" Those are not the same question, and confusing them is how a SUSE admin drifts out of policy or ships more change than intended. This part is `zypper refresh` and the two lists it feeds.

## `zypper refresh` — update the local cache

```bash
# shell: inside the zypperbox container
zypper refresh          # shorthand: zypper ref
```

```text
Repository 'Main Update Repository' is up to date.
All repositories have been refreshed.
```

Like `apt update` or `dnf`'s automatic refresh: it updates zypper's local knowledge of what each configured repository currently offers — **package versions and, on SUSE, patch definitions** — and changes nothing installed. Skip it and every question you ask afterward is answered against stale data.

## `list-updates` — raw version arithmetic

```bash
zypper list-updates      # shorthand: zypper lu
```

For every installed package: is a newer version available in a configured repo? No curation, no categorisation — just version comparison. This is the same "newer exists" list every other package manager shows.

## `list-patches` — curated patch objects

```bash
zypper list-patches      # shorthand: zypper lp
```

Lists SUSE's **patch objects** — named, tracked bundles a repository maintainer deliberately assembled and published, each **classified** by category (`security`, `recommended`, `optional`/feature) and severity, often addressing a specific CVE or bug. One patch can bundle several packages' updates as a single trackable unit.

## The two lists do not have to match

Coming from Debian or Fedora this is the surprise: a package can appear in `zypper list-updates` with a newer version sitting in the repo and have **no patch covering it yet** — so `zypper list-patches` never mentions it. That is not a bug. Patches are a deliberate, reviewed layer *on top of* the raw version stream, not a different display of the same data.

As an analogy (flagged): think of a hospital pharmacy. Shelves quietly restock with newer formulations — that is `zypper list-updates`. A **recall notice** is different: a curated, tracked, often urgent bulletin naming exactly which batches are affected and why, issued by an authority who reviewed the situation — that is `zypper list-patches`. Where it breaks down: a pharmacy recall is always urgent, whereas SUSE patch categories include non-urgent `recommended` and `optional` alongside `security`.

> [!WARNING]
> - **Treating `list-updates` and `list-patches` as the same list in two formats** → they are different layers; a package with a newer version may have no patch, and vice versa.
> - **Skipping `zypper refresh`** → both lists, and any patch/update you then apply, are computed from stale metadata.
> - **Assuming every `list-patches` entry is security** → check the Category column; `recommended` and `optional` also appear.

> *`zypper refresh` updates the local metadata (versions **and** patch definitions); `zypper list-updates` is raw "newer version exists" and `zypper list-patches` is SUSE's curated, categorised patch objects — the two lists legitimately differ.*

## Reference

- `man zypper` — `refresh`, `list-updates` / `lu`, `list-patches` / `lp`, `patches`, `patch-info`.
- `zypper lp --category security` / `--severity important` — filtering the patch list.
- openSUSE docs, "Patch vs. Update" — why SUSE maintains the patch layer separately.
