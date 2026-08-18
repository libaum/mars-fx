#!/bin/bash
set -e

# Runs the app on the Linux desktop instead of a device — handy for working on
# layout and conversion logic without reaching for a phone.
#
# Needs the Linux desktop toolchain once:
#   sudo apt install clang cmake ninja-build pkg-config libgtk-3-dev
#
# Note: this is a development target only. Mars Currency ships on Android;
# the Linux build exists so the app can be run and looked at on this machine.

flutter run --debug -d linux
