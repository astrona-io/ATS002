# Solution Walkthrough

You write one script with four commands, and check it after each step. This lab does not run SELinux, so the commands in the script are not run on this ship. Run these steps as root, or add `sudo` in front.

---

## Step 1: Write the lasting file label rule

Save this as `/root/selinux-fix.sh`:

```bash
semanage fcontext -a -t httpd_sys_content_t "/srv/web(/.*)?"
```

`semanage fcontext` writes a rule into the lasting rule database, so a relabel keeps the type. `-a` adds the rule and `-t` names the type. The pattern covers the folder and everything below it. Keep the quotes.

Check the syntax and send it for grading:

```sh
bash -n /root/selinux-fix.sh
astrona submit -c sections/section-040/module-02/labs/lab-01
```

The label rule check should pass. The other checks still fail, which is expected.

## Step 2: Apply the rule to existing files

Add this line to the end of `/root/selinux-fix.sh`:

```bash
restorecon -Rv /srv/web
```

The rule only decides what the label should be. `restorecon` stamps the files that exist now. `-R` goes through the folder and `-v` prints each change. The line must come after the rule.

Check and submit again:

```sh
bash -n /root/selinux-fix.sh
astrona submit -c sections/section-040/module-02/labs/lab-01
```

## Step 3: Turn the boolean on for good

Add this line:

```bash
setsebool -P httpd_can_network_connect on
```

`-P` writes the change to disk, so it stays after a reboot. Without it the value is lost.

Check and submit again:

```sh
bash -n /root/selinux-fix.sh
astrona submit -c sections/section-040/module-02/labs/lab-01
```

## Step 4: Allow the port

Add this line:

```bash
semanage port -a -t http_port_t -p tcp 8888
```

This gives TCP port 8888 the type that web servers may listen on. Check and send the lab for the last time:

```sh
bash -n /root/selinux-fix.sh
astrona submit -c sections/section-040/module-02/labs/lab-01
```

---

## Command Summary

Content of `/root/selinux-fix.sh`:

```bash
semanage fcontext -a -t httpd_sys_content_t "/srv/web(/.*)?"
restorecon -Rv /srv/web
setsebool -P httpd_can_network_connect on
semanage port -a -t http_port_t -p tcp 8888
```
