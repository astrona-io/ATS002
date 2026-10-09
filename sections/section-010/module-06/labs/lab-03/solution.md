# Solution Walkthrough

The journal names the symptom, and `ss` names the program to blame. Then you clear the port for good and prove that the right service holds it.

## 1. Read the verdict and the evidence

Read the summary and the journal of the unit:

```bash
systemctl status webreport
journalctl -xeu webreport
```

```text
webreport[...]: OSError: [Errno 98] Address already in use
webreport.service: Main process exited, code=exited, status=1/FAILURE
```

`Errno 98` with `Address already in use` means another program already listens on TCP port 8080. The kernel refused to give the port to `webreport`.

## 2. Find what holds the port

List the listening TCP sockets on port 8080 with their processes:

```bash
sudo ss -ltnp 'sport = :8080'
```

```text
LISTEN 0 5 0.0.0.0:8080 0.0.0.0:* users:(("python3",pid=744,fd=3))
```

A `python3` process with process ID 744 holds the port. Your process ID will be different. Trace that process back to its unit:

```bash
ps -o unit= -p 744
# or:
systemctl status 744
```

```text
portsquatter.service
```

`portsquatter.service` is the leftover that holds the port.

## 3. Stop it, for good

Stop the leftover and remove it from the boot list in one step:

```bash
sudo systemctl disable --now portsquatter.service
```

`disable --now` stops it *and* removes its link for boot, so it will not grab the port again after a reboot. `stop` alone would let it come back at the next boot. Confirm that the port is now free:

```bash
sudo ss -ltnp 'sport = :8080'      # no output
```

## 4. Start webreport and verify

Start the real service, then prove each requirement:

```bash
sudo systemctl start webreport
systemctl is-active webreport      # active
systemctl is-enabled webreport     # enabled
sudo ss -ltnp 'sport = :8080'      # now shows webreport's process
curl -s http://127.0.0.1:8080/     # -> report service OK
```

The grader checks that `webreport` is active and enabled, that its process is the one listening on 8080, that `portsquatter.service` is no longer active, and that the page on port 8080 contains `report service OK`. When all of that holds, send it for grading:

```sh
astrona submit -c sections/section-010/module-06/labs/lab-03
```
