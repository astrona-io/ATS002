#!/usr/bin/env bash
# Match the account used by astrona ssh, including its home and permissions.
sudo -H -u student bash <<'ASTRONA_STUDENT_SCRIPT'
# Inspect protected state; user access checks select their target account explicitly.
sudo -n bash <<'GRADER_ROOT'
# Confirms the logical volume cargo_vg/deck is active.

set -u

ATTR=$(sudo lvs --noheadings -o lv_attr cargo_vg/deck 2>/dev/null | tr -d ' ')

if [[ -z "$ATTR" ]]; then
  echo "FAIL: active - logical volume cargo_vg/deck not found"
  exit 1
fi

if [[ "${ATTR:4:1}" != "a" ]]; then
  echo "FAIL: active - cargo_vg/deck is not active"
  exit 1
fi

echo "PASS: cargo_vg/deck is active"
exit 0
GRADER_ROOT
ASTRONA_STUDENT_SCRIPT
