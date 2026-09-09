# Solution Walkthrough

## 1. Read the verdict and the evidence

```bash
systemctl status webreport
journalctl -xeu webreport
```

```text
webreport[...]: OSError: [Errno 98] Address already in use
webreport.service: Main process exited, code=exited, status=1/FAILURE
```

`Errno 98` / `Address already in use` — something already holds TCP 8080.

## 2. Find what holds the port

```bash
sudo ss -ltnp 'sport = :8080'
```

```text
LISTEN 0 5 0.0.0.0:8080 0.0.0.0:* users:(("python3",pid=744,fd=3))
```

Trace that PID back to its unit:

```bash
ps -o unit= -p 744
# or:
systemctl status 744
```

```text
portsquatter.service
```

`portsquatter.service` is the squatter.

## 3. Stop it, permanently

```bash
sudo systemctl disable --now portsquatter.service
```

`disable --now` stops it *and* removes its boot wiring, so it will not grab
the port again after a reboot. (`stop` alone would let it return on boot.)
Confirm the port is now free:

```bash
sudo ss -ltnp 'sport = :8080'      # no output
```

## 4. Start webreport and verify

```bash
sudo systemctl start webreport
systemctl is-active webreport      # active
systemctl is-enabled webreport     # enabled
sudo ss -ltnp 'sport = :8080'      # now shows webreport's process
curl -s http://127.0.0.1:8080/     # -> report service OK
```

The journal-names-the-symptom / `ss` names-the-culprit pair is the standard
move for an `Address already in use` failure.
