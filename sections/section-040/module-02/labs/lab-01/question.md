# Question

Solve this question on: `terminal`

Astronaut, a web server on a RHEL-family machine is refused by SELinux. This training ship cannot run SELinux, so this lab grades the **script you write**, not a live SELinux system. The commands are not run.

Write a shell script at `/root/selinux-fix.sh`, with one command per line, that does all of the following on the target machine:

1. Gives `/srv/web` and everything below it the file type `httpd_sys_content_t`, so that the change stays after a full relabel. Then applies it to the files that exist now, recursively.
2. Allows the web server to make outgoing network connections by turning the boolean `httpd_can_network_connect` on, so that it stays after a reboot.
3. Allows the web server to listen on TCP port `8888` by giving the port the type `http_port_t`.

The script must pass `bash -n`. The folder `/srv/web` exists on this ship so you can name real paths.
