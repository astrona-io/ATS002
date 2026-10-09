# The chroot Equivalent And Editing /etc/shadow

Astronaut, the GRUB keystrokes are only a way onto the bridge. What really resets the password is the next step: root access to the target's files, and a new entry in its locked roster of crew passwords, `/etc/shadow`. This part shows that a chroot reaches the same place, and how to write the new password hash yourself when the `passwd` command will not run.

## The skill is bigger than the keystrokes

`rd.break` and `init=/bin/bash` are two ways to reach one place: **root access to the target's filesystem, so you can run `passwd` or edit the password file directly.** A chroot gets you to that same place from outside. Mount the target root, bind-mount a set of tools plus `/dev`, `/proc` and `/sys` into it, step in with `chroot`, then reset the password:

```bash
# shell: repair host, root — target root already mounted at /mnt/repair with /dev,/proc,/sys bound
sudo chroot /mnt/repair /bin/bash
passwd root
```

These two commands assume the mounts are already in place: the target root on `/mnt/repair`, with the tools and `/dev`, `/proc` and `/sys` bind-mounted into it.

The real exam skill sits before the commands. You must recognise that a healthy but locked-out system needs neither rescue media nor a repair, only root access to its files for one operation. Only the GRUB menu keystrokes are out of reach for a grader that works over SSH, so the mission uses the chroot route.

## When `passwd` will not run

A real installed system has a full `/etc`: `pam.d/`, `nsswitch.conf`, `login.defs`. PAM (Pluggable Authentication Modules) is the set of rules `passwd` follows to check and store passwords. A small stand-in disk may carry only the files needed to show the technique, and then `passwd root` can fail with errors about PAM configuration it never had.

The reliable alternative is just as valid on the exam: make the hash yourself and put it into `/etc/shadow`.

### Make the hash

```bash
openssl passwd -6 'NewSecurePass123!'
```

```text
$6$abcd1234efgh5678$Xy9k...long-hash...
```

This output is shortened; a real hash is much longer, and it is different each time because of the random salt. The salt is the short random part between the second and third `$`.

`openssl passwd -6` makes a **SHA-512-crypt** hash, a one-way scrambled form of the password in exactly the format `/etc/shadow` accepts. The prefix says which method was used: `$6$` is SHA-512, `$5$` (option `-5`) is SHA-256 and `$1$` (option `-1`) is the old MD5. Ubuntu 24.04's own `passwd` writes `$y$` (yescrypt) hashes by default, but login still accepts a `$6$` hash. The `mkpasswd -m sha-512` command, from the `whois` package, makes the same kind of hash.

### Put it into the right field

Edit `/etc/shadow` and replace **only the second field**, the hash, on the `root` line. Leave every other field as it is:

```text
root:$6$abcd1234efgh5678$Xy9k...long-hash...:19700:0:99999:7:::
```

```
   root : <hash> : lastchg : min : max : warn : inactive : expire :
    │      │        │
    │      │        └─ field 3+ — do not touch
    │      └─ field 2 — the ONLY field you replace
    └─ field 1 — username
```

A `!` or `*` in the second field means the account is locked or has no usable password. Fields 3 onward hold dates and ageing rules; changing them by mistake can expire or lock the account.

This is the same change `passwd` makes. You simply do the hashing and the file edit yourself. Both ways prove the same skill: getting a new password into the target's `/etc/shadow` through root access, without the target's login prompt.

When you are done, leave the chroot with `exit` and unmount in reverse order, or with `sudo umount -R /mnt/repair`. If the target enforces SELinux, run `touch /mnt/repair/.autorelabel` from the repair host before you unmount.

## Common pitfalls

> [!WARNING]
> - **Replacing a field other than the second in `/etc/shadow`.** You can lock or expire the account. Only the hash field changes.
> - **Pasting plain text as the hash.** Login fails. It must be a real crypt hash such as `$6$...`. Use `openssl passwd -6` or `mkpasswd`.
> - **Giving up when `passwd` fails on a small target.** Switch to `openssl passwd -6` and a direct edit; it needs no PAM.
> - **Forgetting the SELinux relabel** when the target enforces SELinux. Create `/mnt/repair/.autorelabel` before unmounting.

## Your mission: Password Reset & Single-User Recovery Lab

You can now reach a locked-out system's files through a chroot and put a new password hash into its `/etc/shadow`. The mission asks you to unlock the root account on a stand-in system whose `/etc/shadow` has root locked.

Start the mission and open a terminal on it:

```sh
astrona run --git git@github.com:astrona-io/ATS002.git -c sections/section-080/module-02/labs/lab-01
astrona ssh ats-002-lab-082
```

Read the task in [`question.md`](./labs/lab-01/question.md) and solve it on your own first. When you think you are done, send it for grading:

```sh
astrona submit -c sections/section-080/module-02/labs/lab-01
```

When the mission is done, remove it:

```sh
astrona destroy ats-002-lab-082
```
