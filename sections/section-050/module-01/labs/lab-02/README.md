# section-050 / module-01 / lab-02: APT pinning (not a hold)

QEMU VM for the LFCS course. `curl` has a higher version in `noble-updates`
than in the `noble` release pocket. Use APT **pinning**
(`/etc/apt/preferences.d/` with `Pin: release a=noble` and a `Pin-Priority`
above 500) — not `apt-mark hold` — so the release-pocket version becomes the
Candidate. Verify with `apt-cache policy curl`.

## Run

```bash
astrona run --git git@github.com:astrona-io/ATS002.git -c sections/section-050/module-01/labs/lab-02
```
