# section-080 / capstone: System Disaster Recovery Capstone

QEMU VM for the LFCS course — the Section 080 capstone. A bad night on call: a secondary disk's partition table needs restoring from an existing backup, and this VM's own bootloader needs reinstalling and its configuration regenerated before the next scheduled reboot.

## How This Lab Stays Safely Gradable

This capstone combines two mechanics already used separately elsewhere in this section, each safely re-staged for the same reason: the lab harness grades by SSHing into this VM and running a script, which cannot survive an actually-unbootable machine or script an interactive console.

*   **The secondary disk** (`extraDisks`, serial `lab080-vdc`) is a real, GPT-partitioned disk carrying real filesystems — the Module 3 / lab-083 mechanism. It needs no adaptation of its own: it's a non-root disk, so the VM stays reachable throughout even while its partition table is genuinely gone.
*   **The primary disk's bootloader** uses the Module 4 / lab-084 mechanism: bootstrap removes `/boot/grub/grub.cfg` but never touches the kernel this VM's **current** boot already loaded into memory, and never touches GRUB's own installed boot-sector/EFI code. SSH stays fully reachable throughout — only the **next** reboot would be affected.

Unlike lab-083, this capstone doesn't ask you to create the partition-table backup yourself — bootstrap already took one and the "disaster" already happened before you logged in, exactly like being paged after the incident is already underway rather than while everything is still fine.

## Run

```bash
astrona run --git git@github.com:astrona-io/ATS002.git -c labs/section-080/capstone/lab-01
```
