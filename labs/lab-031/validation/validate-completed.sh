#!/usr/bin/env bash
set -u

BIN=/usr/bin/links

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

which_path=$(which links 2>/dev/null)
if [ "$which_path" != "$BIN" ]; then
  echo "FAIL: 'which links' resolved to '${which_path:-nothing}', expected $BIN"
  exit 1
fi

version_output=$("$BIN" -version 2>&1)
if [[ "$version_output" != *"2.14"* ]]; then
  echo "FAIL: version output does not report links 2.14: '$version_output'"
  exit 1
fi

if [[ "$version_output" == *"ipv6=enabled"* ]]; then
  echo "FAIL: links was built WITH ipv6 support enabled; the scenario requires ipv6 disabled"
  exit 1
fi

if [[ "$version_output" != *"ipv6=disabled"* ]]; then
  echo "FAIL: could not confirm ipv6 is disabled from version output: '$version_output'"
  exit 1
fi

echo "PASS: links installed at /usr/bin/links, built from source with ipv6 support disabled"
exit 0
