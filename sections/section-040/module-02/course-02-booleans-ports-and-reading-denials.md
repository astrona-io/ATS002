# Allow a service port and backend connection

Apache is configured for TCP 8888. SELinux also controls which ports its process may bind. A boolean is a named policy switch; `httpd_can_network_connect` controls outgoing connections from the web service.

<!-- astrona:playground:renew -->

## Find the denied operation

Use the service log and audit records in the playground:

```sh
sudo journalctl -u httpd -n 30 --no-pager
sudo ausearch -m AVC -ts recent
sudo semanage port -l | grep http_port_t
getsebool httpd_can_network_connect
```

An AVC record describes a denied access. Read the source context, target context and operation. A bind denial points to the listening port; a read denial points to content; a connection denial points to backend access. More than one fault may appear as you repair the service.

## Make the policy changes

Keep SELinux enforcing while assigning the port and enabling the boolean:

```sh
sudo semanage port -a -t http_port_t -p tcp 8888
sudo setsebool -P httpd_can_network_connect on
sudo systemctl restart httpd
curl --fail http://127.0.0.1:8888/
curl --fail http://127.0.0.1:8888/probe
```

The page needs the persistent content rule shown in the label exercise. The `/probe` request passes through Apache to the backend, so it tests access from the confined process. A direct backend request cannot prove that permission. `-P` saves a boolean across reboot.

## Verify persistence

Run `sudo reboot`, reconnect after startup, and repeat `getenforce` and both requests. Enforcing mode blocks disallowed access; permissive mode only logs it. `setenforce 0` therefore hides this fault and does not repair the policy. Keep `SELINUX=enforcing` in `/etc/selinux/config`.

## Common pitfalls

> [!WARNING]
> Do not turn every denial into a new allow rule. Check the intended label, port and boolean first. Verify requests through the service, and check again after reboot.

## Your mission: restore the service

Complete the [independent lab](labs/lab-01/question.md). It starts from a fresh VM. Destroy the playground before starting the lab if your machine has limited memory.
