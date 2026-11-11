# Question

Solve this question on: `terminal`

Astronaut, `webreport.service` serves an internal report page over HTTP on TCP port `8080`. It is enabled for boot, but right now it is in the `failed` state: it cannot start.

Find out why with `systemctl status webreport` and `journalctl -xeu webreport`, and find what stops it from listening on the port. Then repair the situation so that:

- `systemctl is-active webreport` reports `active`
- `systemctl is-enabled webreport` reports `enabled`
- `webreport` is the process listening on TCP `8080`
- `curl http://127.0.0.1:8080/` returns the report page (it contains `report service OK`)

Whatever holds port `8080` right now is a leftover and is not needed. Stop it, so it is no longer active and no longer holds the port. A careful administrator also disables it, so it cannot take the port again after a reboot.
<!-- curriculum-links -->

## Related lessons and assessment

Read [module-06](../../course.md).

The grader checks:

- Confirms webreport.service is active and enabled, is the process listening on TCP 8080, answers an HTTP request there, and that the conflicting portsquatter service is no longer holding the port.

Use the inspection commands in the solution to check your work. Submit when you have finished; submission ends this environment.
