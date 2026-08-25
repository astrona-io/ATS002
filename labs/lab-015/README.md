# lab-015: Process Troubleshooting with strace

QEMU VM for the LFCS course — attaching `strace` to running processes to catch one calling a forbidden syscall, then resolving its real executable via `/proc/PID/exe` before terminating it and removing the binary.

## Run

```bash
astrona run --git git@github.com:astrona-io/ATS002.git -c labs/lab-015
```
