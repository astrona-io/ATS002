#!/usr/bin/env bash
# Confirms the student recognised this was NOT database corruption and
# resolved the actual dependency gap:
#   - `dnf check` inside rpmbox now passes cleanly
#   - the specific unmet dependency is satisfied (dep reinstalled) OR the
#     unsatisfiable package removed
#   - `rpm -qa` works (it always did - a rebuild was never needed, but this
#     just confirms nothing was made worse)
set -u

D() { sudo docker exec rpmbox "$@"; }
fail() { echo "FAIL: $1"; exit 1; }

# dnf check must pass now.
out="$(D dnf check 2>&1)"; rc=$?
[ $rc -eq 0 ] || { echo "FAIL: dnf check still fails inside rpmbox:"; echo "$out" | tail -10; exit 1; }

# rpm -qa clean and plausible.
qa="$(D bash -c 'rpm -qa' 2>&1)"; qrc=$?
[ $qrc -eq 0 ] || fail "rpm -qa exits non-zero inside rpmbox"
echo "$qa" | grep -qi 'error' && fail "rpm -qa output contains error text"
[ "$(echo "$qa" | wc -l)" -ge 20 ] || fail "rpm -qa returned an implausibly small package count"

# The dependency gap must actually be closed.
read -r VICTIM DEP < <(D cat /root/.lab066-broken 2>/dev/null)
if [ -n "$DEP" ]; then
  if D rpm -q "$DEP" >/dev/null 2>&1; then
    :   # dependency reinstalled - good
  elif ! D rpm -q "$VICTIM" >/dev/null 2>&1; then
    :   # unsatisfiable package removed instead - also acceptable
  else
    fail "'$VICTIM' still installed but its requirement '$DEP' is not - dependency gap not resolved"
  fi
fi

echo "PASS: dnf check is clean and the dependency gap is resolved (this was a look-alike, not rpmdb corruption)"
exit 0
