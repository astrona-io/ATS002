# Wrap-Up: Mission Debrief

Well flown, astronaut. You can now tell a damaged ledger from its look-alikes, and repair it safely when it really is damaged. Look back at what you learned, check yourself, and clean up anything still running.

## What you learned

This module was about the RPM database under `/var/lib/rpm`: how it breaks, how to recognise that, and how to rebuild it.

**From [Recognising a Broken RPM Database](./course-01-recognising-the-symptom.md):**

- Database corruption shows as errors about *the database* (`rpmdbNextIterator`, `damaged header`, "disk image is malformed"), not about a named package.
- An error that names a package is a dependency problem. "No space left on device" or a full `df -h /var` is a disk problem. Neither one is fixed by a rebuild.
- If `rpm -qa` lists every package cleanly, the database is not corrupt.
- `ls -la /var/lib/rpm` shows the backend: `rpmdb.sqlite` on RHEL 9 and Rocky Linux 9, `Packages` and `__db.*` on older Berkeley DB systems.

**From [Back Up, Rebuild, Verify](./course-02-backup-rebuild-verify.md):**

- Always back up first: `cp -a /var/lib/rpm /var/lib/rpm.bak-$(date +%s)`.
- `rpm --rebuilddb` (or `rpmdb --rebuilddb`) rebuilds the indexes from the stored headers. It does not bring back deleted package files; `dnf reinstall` does that.
- Prove the repair with `rpm -qa`, `dnf check` and `dnf check-update`, not with `rpm -qa` alone.

## Your missions

You proved these skills in graded missions, each right after the part that taught it:

| Mission | After the part | What you proved |
| --- | --- | --- |
| [RPM Database: Corruption Look-Alike Lab](./labs/lab-02/README.md) | Recognising a Broken RPM Database | saw that a loud `dnf check` failure was a missing dependency, and fixed it without a rebuild |
| [Rebuilding a Corrupted RPM Database Lab](./labs/lab-01/README.md) | Back Up, Rebuild, Verify | backed up and rebuilt a really damaged `sqlite` database, and left `rpm -qa` and `dnf check` clean |

## Check yourself

Try to answer each question before you open the answer.

<details>
<summary>1. <code>dnf check</code> says "python3-pip requires python3-setuptools, but none of the providers can be installed". Is the database corrupt?</summary>

No. The error names a package and a missing requirement. That is a dependency problem. Install the missing package, or remove the package that needs it.
</details>

<details>
<summary>2. Which single command rules out the disk-space look-alike?</summary>

`df -h /var`. If the filesystem is full, free space first; a rebuild will not help.
</details>

<details>
<summary>3. How do you find out whether a system uses the <code>sqlite</code> or the Berkeley DB backend?</summary>

Run `ls -la /var/lib/rpm`. `rpmdb.sqlite` means `sqlite`; `Packages` and `__db.*` mean Berkeley DB.
</details>

<details>
<summary>4. Why <code>cp -a</code> and not plain <code>cp -r</code> for the backup?</summary>

`-a` keeps permissions, owners, timestamps and links exactly, so the copy can be restored as it is.
</details>

<details>
<summary>5. A package's files were deleted by mistake. Will <code>rpm --rebuilddb</code> bring them back?</summary>

No. The rebuild only rebuilds the database's indexes from the stored headers. Use `dnf reinstall <package>` to put the files back.
</details>

<details>
<summary>6. After the rebuild, <code>rpm -qa</code> works. Why run <code>dnf check</code> as well?</summary>

`dnf`'s own checks were what failed in the first place. `dnf check` proves they work against the rebuilt database, and `dnf check-update` proves a full pass completes.
</details>

## Clean up

Each mission runs a virtual machine on your computer. When you are done with this module, remove any mission that is still running.

First, see what is still running:

```sh
astrona list
```

If a mission is still there, remove it. The command takes its **name**, not its folder path:

```sh
astrona destroy ats-002-lab-066
astrona destroy ats-002-lab-062
```
