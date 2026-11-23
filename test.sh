#!/usr/bin/env bash
#
# test.sh - check that the SNAPHU built by build.sh works
#
# Run this from the "MSYS2 MSYS" terminal after ./build.sh:
#
#   ./test.sh
#
# What it does:
#   1. Compiles test/selftest.c, a small program that makes a test
#      interferogram and checks an unwrapped result.
#   2. Makes a 200 by 150 pixel interferogram whose true phase is known and
#      spans several cycles.
#   3. Unwraps it with SNAPHU.
#   4. Compares the SNAPHU output to the true phase and prints PASS or FAIL.
#
# All of the files that this script makes are in build/test/.

set -euo pipefail

VERSION="2.0.7"

cd "$(dirname "$0")"
SNAPHU="$(pwd)/build/snaphu-v${VERSION}/bin/snaphu.exe"

if [ ! -x "$SNAPHU" ]; then
  echo "ERROR: $SNAPHU does not exist. Run ./build.sh first."
  exit 1
fi

mkdir -p build/test
gcc -O2 -Wall -std=gnu17 test/selftest.c -o build/test/selftest.exe -lm
cd build/test

# Number of samples in each line of the test interferogram. SNAPHU needs
# this number on its command line.
LINE_LENGTH=150

echo "== Making the test interferogram"
./selftest.exe make wrapped.bin

echo "== Unwrapping with SNAPHU"
"$SNAPHU" wrapped.bin "$LINE_LENGTH" -o unwrapped.bin

echo "== Checking the result"
./selftest.exe check unwrapped.bin
