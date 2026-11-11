# Give web content a persistent label

Apache must read `/srv/web/index.html`, but that file has the label of a home directory. The ordinary file permissions allow reads; SELinux still refuses the confined web process.

<!-- astrona:playground:renew -->

## Inspect the current and expected labels

Run these commands in the Rocky Linux playground:

```sh
getenforce
ls -Zd /srv/web /srv/web/index.html
sudo matchpathcon /srv/web/index.html
```

A context has `user:role:type:level` fields. The type controls the access relevant here. `ls -Z` reads the current label; `matchpathcon` asks the policy what label belongs at that path. They can disagree after a file is moved or relabeled manually.

## Write the rule, then apply it

A persistent file-context rule maps a path pattern to a type. Add the mapping and apply it:

```sh
sudo semanage fcontext -a -t httpd_sys_content_t '/srv/web(/.*)?'
sudo restorecon -Rv /srv/web
sudo matchpathcon -V /srv/web/index.html
```

The quoted pattern covers the directory and its children. `semanage` writes the rule; `restorecon` updates existing files. If you repeat the exercise after adding the rule, use `semanage fcontext -m` to modify it.

`chcon` changes a live label without writing a path rule. A later relabel can undo that change. Files moved on the same filesystem generally keep their labels; copying can create new labels according to the destination and command options.

## Common pitfalls

> [!WARNING]
> A successful `ls -l` permission check does not establish SELinux access. Compare the actual context with the policy, and apply the rule to existing files with `restorecon`.
