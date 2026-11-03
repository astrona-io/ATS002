#!/usr/bin/env bash
# Starting state for the initramfs playground. The machine stays healthy:
# this only saves a listing of /boot so you can compare it with the state
# after your own experiments. Nothing is deleted or rebuilt.

set -eu

sudo sh -c 'ls -l /boot > /root/boot-listing.original.txt'
