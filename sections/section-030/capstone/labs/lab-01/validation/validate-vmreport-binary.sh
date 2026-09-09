#!/usr/bin/env bash
# Confirms vmreport is installed at /usr/local/bin/vmreport, is a real
# compiled ELF binary, and was built with color output disabled.

set -u

BIN=/usr/local/bin/vmreport

if [ ! -e "$BIN" ]; then
  echo "FAIL: $BIN does not exist"
  exit 1
fi

if [ ! -x "$BIN" ]; then
  echo "FAIL: $BIN exists but is not executable"
  exit 1
fi

filetype=$(file -b "$BIN" 2>/dev/null)
if [[ "$filetype" != *"ELF"* ]]; then
  echo "FAIL: $BIN is not a compiled ELF binary (got: '$filetype')"
  exit 1
fi

version_output=$("$BIN" -version 2>&1)
if [[ "$version_output" != *"1.0"* ]]; then
  echo "FAIL: version output does not report vmreport 1.0: '$version_output'"
  exit 1
fi

if [[ "$version_output" == *"color=enabled"* ]]; then
  echo "FAIL: vmreport was built WITH color output enabled; the scenario requires color disabled"
  exit 1
fi

if [[ "$version_output" != *"color=disabled"* ]]; then
  echo "FAIL: could not confirm color output is disabled from version output: '$version_output'"
  exit 1
fi

echo "PASS: vmreport installed at /usr/local/bin/vmreport, built from source with color output disabled"
exit 0
