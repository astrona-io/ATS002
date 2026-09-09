# Question

Solve this question on: `terminal`

`webreport.service` serves an internal report page over HTTP on TCP port
`8080`. It is enabled for boot but currently failed — it cannot start.

Diagnose why with `systemctl status webreport` and `journalctl -xeu
webreport`, identify what is preventing it from binding the port, and repair
the situation so that:

- `systemctl is-active webreport` reports `active`
- `systemctl is-enabled webreport` reports `enabled`
- `webreport` is the process listening on TCP `8080`
- `curl http://127.0.0.1:8080/` returns the report page

Whatever is currently holding port `8080` is a leftover and is not needed —
stop it and make sure it will not come back on the next boot.
