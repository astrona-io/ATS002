#!/usr/bin/env bash
# Confirms curl is pinned to the noble release pocket:
#   - a file under /etc/apt/preferences.d/ targets curl, pins on the
#     release pocket (a=noble / o=Ubuntu with the release archive), and
#     sets Pin-Priority above the default 500
#   - `apt-cache policy curl` now shows the release-pocket version as the
#     Candidate (NOT the higher noble-updates version)
set -u

fail() { echo "FAIL: $1"; exit 1; }

# 1. A preferences file that mentions curl.
pf="$(grep -rls -iE '^\s*Package:\s*(curl|\*)\s*$' /etc/apt/preferences /etc/apt/preferences.d/ 2>/dev/null || true)"
[ -n "$pf" ] || fail "no /etc/apt/preferences.d/ file with 'Package: curl' (or 'Package: *')"

blk="$(cat $pf 2>/dev/null)"

# 2. Pin targets the release pocket, priority > 500.
echo "$blk" | grep -qiE '^\s*Pin:\s*release .*(a=noble([, ]|$)|a=noble/|n=noble([, ]|$))' \
  || echo "$blk" | grep -qiE '^\s*Pin:\s*release .*a=noble\b' \
  || fail "Pin line does not target the noble *release* pocket (expected 'Pin: release a=noble'). Got: $(echo "$blk" | grep -i '^Pin:')"

prio="$(echo "$blk" | grep -iE '^\s*Pin-Priority:' | grep -oE '[0-9]+' | tail -1)"
[ -n "$prio" ] && [ "$prio" -gt 500 ] 2>/dev/null \
  || fail "Pin-Priority is '$prio', must be greater than 500 to beat the updates pocket"

# 3. apt-cache policy: Candidate must come from noble/main, not noble-updates.
sudo apt-get update -qq >/dev/null 2>&1 || true
pol="$(apt-cache policy curl 2>/dev/null)"
cand="$(echo "$pol" | awk -F': ' '/Candidate:/{print $2}')"
[ -n "$cand" ] || fail "apt-cache policy curl produced no Candidate"

# The Candidate version's source line must be the plain 'noble/main', not '-updates' / '-security'.
src="$(echo "$pol" | awk -v c="$cand" '
  $0 ~ "\\*\\*\\* "c" |^ *"c" " {found=1; next}
  found && /http/ {print; exit}
')"
echo "$src" | grep -q 'noble/main' || fail "Candidate '$cand' does not come from the noble release pocket. Source: $src"
echo "$src" | grep -qE 'noble-updates|noble-security' && fail "Candidate still comes from an updates/security pocket: $src"

echo "PASS: curl is pinned to the noble release pocket (priority $prio); Candidate '$cand' from $src"
exit 0
