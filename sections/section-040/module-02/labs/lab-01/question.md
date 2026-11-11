# Restore Apache with SELinux enforcing

The Rocky Linux VM has a page at `/srv/web/index.html` and a working backend at `127.0.0.1:19090`. Apache is configured to listen on TCP 8888 and proxy `/probe` to that backend. SELinux policy prevents the service from working.

Allow 10–15 minutes for the tasks. The first image download and package installation are separate startup time. This image uses x86_64; ARM hosts emulate it and start more slowly.

1. Read `sudo journalctl -u httpd` and `sudo ausearch -m AVC -ts recent`. Identify the denied operation before changing policy.
2. Make `/srv/web` and its children use `httpd_sys_content_t` persistently, then apply the labels.
3. Assign TCP 8888 to `http_port_t` and persistently enable `httpd_can_network_connect`. Keep SELinux enforcing, including for the `httpd_t` domain.
4. Restart Apache. Verify that `/` returns `SELinux page ready` and `/probe` returns `SELinux backend ready` through `http://127.0.0.1:8888`. Reboot with `sudo reboot`, reconnect, and repeat both requests.

The grader checks policy and real requests. CI also checks the result after a reboot. Disabling SELinux or making Apache permissive does not satisfy the task.
