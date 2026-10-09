# Service Won't Start: Port Already In Use Lab

Astronaut, `webreport.service` on this training ship is a small web server that must listen on TCP port 8080. A port is a radio channel, and only one station can listen on one channel. A leftover unit already holds 8080, so `webreport` fails with `Address already in use`.

Your job: find the program that holds the port with `ss -ltnp`, stop it for good, start `webreport`, and prove that it is running, enabled for boot and serving on port 8080.

## Launching the lab

Start the virtual machine:

```sh
astrona run --git git@github.com:astrona-io/ATS002.git -c sections/section-010/module-06/labs/lab-03
```

Open a terminal on it:

```sh
astrona ssh ats-002-lab-018
```

When you think you have finished, send it for grading:

```sh
astrona submit -c sections/section-010/module-06/labs/lab-03
```

When you are done, remove the lab:

```sh
astrona destroy ats-002-lab-018
```
