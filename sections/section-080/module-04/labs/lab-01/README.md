# section-080 / module-04: GRUB Corruption Recovery

QEMU VM for the LFCS course — reinstalling GRUB's boot-sector/EFI code and regenerating its configuration after a stale, missing `grub.cfg`, directly on the VM's own primary disk.

## How This Lab Stays Safely Gradable

The real-world version of this scenario is a machine dropping straight to a bare `grub>` rescue prompt with no menu at all — an interactive, console-only failure this platform's SSH-driven grading harness cannot script, and cannot recover from if it genuinely happened. So rather than skip the scenario, this lab re-stages it safely, directly on your primary VM: bootstrap removes `/boot/grub/grub.cfg` — the on-disk config GRUB needs to build its menu — but never touches the kernel your **current** boot already loaded into memory, and never touches GRUB's own installed boot-sector/EFI code. Your VM stays fully reachable over SSH the entire time. Only the **next** reboot would be affected, which is exactly the framing this lab uses: fix it now, before that happens, not "you're already down."

## Run

```bash
astrona run --git git@github.com:astrona-io/ATS002.git -c sections/section-080/module-04/labs/lab-01
```
