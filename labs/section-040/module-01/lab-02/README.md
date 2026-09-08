# section-040 / module-01 / lab-02: AppArmor — a read denial

QEMU VM for the LFCS course. Companion to lab-01's write denial: the
`credsync` daemon cannot **read** its relocated API key at
`/etc/credsync/api.key` because the enforce-mode profile only permits the
old path. DAC is already correct. Read the `denied_mask="r"` audit line, add
a read rule to the local override, reload with `apparmor_parser -r`, and
keep the profile in `enforce`.

## Run

```bash
astrona run --git git@github.com:astrona-io/ATS002.git -c labs/section-040/module-01/lab-02
```
