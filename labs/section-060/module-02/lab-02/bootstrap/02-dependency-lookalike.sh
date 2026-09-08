#!/usr/bin/env bash
# Creates a corruption LOOK-ALIKE inside rpmbox.
#
# The section-060/module-02 course teaches: before assuming rpmdb
# corruption, rule out (a) a genuine dependency conflict and (b) a
# disk-space problem, because both throw scary errors that mention rpm/dnf
# but are NOT database corruption.
#
# Here we manufacture (a): install a package, then `rpm -e --nodeps` one of
# its required packages. The database stays perfectly consistent and
# `rpm -qa` works fine throughout - but `dnf check` now fails loudly with a
# "requires ... but none of the providers can be installed" style message
# that a panicking admin might mistake for a broken database.
#
# The CORRECT fix is to resolve the dependency (reinstall the missing
# requirement, or remove the now-unsatisfiable package) - NOT rpm
# --rebuilddb, which would do nothing here.
set -eu

D() { sudo docker exec rpmbox "$@"; }

echo "Installing a package with a clear runtime dependency..."
# python3-pip requires python3-setuptools on Rocky 9. Fall back to a
# different well-known pair if that changes.
if D dnf -y install python3-pip; then
  VICTIM=python3-pip
  DEP="$(D rpm -q --requires python3-pip 2>/dev/null | grep -oE 'python3-setuptools' | head -1 || true)"
  [ -n "$DEP" ] || DEP=python3-setuptools
else
  D dnf -y install httpd
  VICTIM=httpd
  DEP=httpd-core
fi

echo "Victim package: $VICTIM   removed requirement: $DEP"

# Remove the dependency from the database WITHOUT removing its files or
# touching the victim - leaving an unmet Requires:.
D rpm -e --nodeps "$DEP"

echo "--- rpm -qa still works fine (database is NOT corrupt): ---"
D bash -c 'rpm -qa | wc -l'

echo "--- but dnf check now fails (this is the student's symptom): ---"
D dnf check 2>&1 | tail -8 || true

# Leave a breadcrumb the validator can use to know what was broken.
D bash -c "printf '%s\n%s\n' '$VICTIM' '$DEP' > /root/.lab066-broken"
echo "lab-066 look-alike ready."
