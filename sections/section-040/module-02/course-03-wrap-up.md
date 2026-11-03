# Summary

Well flown, astronaut. You have finished every part and the mission in this module. Look back at what you learned, check yourself, and clean up anything still running.

## What you learned

This module was about the three usual fixes for an SELinux refusal: a label, a boolean and a port.

**From [Contexts And restorecon](./course-01-contexts-and-restorecon.md):**

- A context is `user:role:type:level`. The type is what the rules use. `ls -Z`, `ps -Z` and `id -Z` show it.
- A moved file keeps its old label. A copied file gets the label of its new place.
- `chcon` changes a label for now. `semanage fcontext -a -t <type> "<regex>"` followed by `restorecon -Rv <path>` makes it last.

**From [Booleans, Ports And Reading Denials](./course-02-booleans-ports-and-reading-denials.md):**

- `setsebool -P <name> on` keeps a boolean after a reboot. Without `-P` it is lost.
- `semanage port -a -t http_port_t -p tcp 8888` allows a new port for good.
- `ausearch -m avc -ts recent` finds denials. `setenforce 0` is permissive until a reboot. `SELINUX=` in `/etc/selinux/config` sets the boot mode.

## Your missions

| Mission | After the part | What you proved |
| --- | --- | --- |
| [SELinux Fix Script Lab](./labs/lab-01/README.md) | Booleans, Ports And Reading Denials | wrote the lasting label, boolean and port commands for a scenario into one script |

If you skipped it, go back to it now.

## Check yourself

Try to answer each question before you open the answer.

<details>
<summary>1. You move a page into <code>/srv/web</code> and the web server is refused. Why?</summary>

`mv` keeps the old label. Fix it with `restorecon -Rv /srv/web`, after a `semanage fcontext` rule if the folder has no rule yet.
</details>

<details>
<summary>2. Why is <code>chcon</code> alone not enough?</summary>

It changes the label but writes no rule. A relabel puts the old label back.
</details>

<details>
<summary>3. Which two commands give a lasting label to <code>/srv/web</code>?</summary>

`semanage fcontext -a -t httpd_sys_content_t "/srv/web(/.*)?"` and then `restorecon -Rv /srv/web`.
</details>

<details>
<summary>4. A boolean is back to its old value after a reboot. What was missing?</summary>

The `-P` option of `setsebool`.
</details>

<details>
<summary>5. Which command lists recent SELinux denials?</summary>

`ausearch -m avc -ts recent`.
</details>

## Clean up

Each mission runs a virtual machine on your computer. When you are done with this module, remove the playground and any mission that is still running.

First, see what is still running:

```sh
astrona list
```

Remove the playground. The command takes its **name**, not its folder path:

```sh
astrona destroy selinux-commands-bay
```

If `astrona list` also showed the mission, remove it the same way:

```sh
astrona destroy ats-002-lab-043
```

*Label with `semanage fcontext` and `restorecon`, switch with `setsebool -P`, channel with `semanage port`.*

<!-- astrona:playground:destroy -->
