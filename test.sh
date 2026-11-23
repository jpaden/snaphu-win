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
#   3. Unwraps it with each of the two copies of SNAPHU that build.sh makes:
#      the copy for the MSYS2 terminal, run here, and the copy for Windows
#      programs, run through the Windows Command Prompt.
#   4. Compares each SNAPHU output to the true phase and prints PASS or FAIL.
#
# All of the files that this script makes are in build/test/.

set -euo pipefail

VERSION="2.0.7"

cd "$(dirname "$0")"

# Copy of SNAPHU for use inside the MSYS2 terminal
SNAPHU_MSYS="$(pwd)/build/snaphu-v${VERSION}/bin/snaphu.exe"

# Copy of SNAPHU for Windows programs (msys-2.0.dll is next to it)
SNAPHU_WINDOWS="$(pwd)/build/windows/snaphu.exe"

for snaphu in "$SNAPHU_MSYS" "$SNAPHU_WINDOWS"; do
  if [ ! -x "$snaphu" ]; then
    echo "ERROR: $snaphu does not exist. Run ./build.sh first."
    exit 1
  fi
done

mkdir -p build/test
gcc -O2 -Wall -std=gnu17 test/selftest.c -o build/test/selftest.exe -lm
cd build/test
rm -f unwrapped_msys.bin unwrapped_windows.bin

# Number of samples in each line of the test interferogram. SNAPHU needs
# this number on its command line.
LINE_LENGTH=150

echo "== Making the test interferogram"
./selftest.exe make wrapped.bin

echo
echo "== Test 1 of 2: the copy for the MSYS2 terminal"
if ! "$SNAPHU_MSYS" wrapped.bin "$LINE_LENGTH" -o unwrapped_msys.bin; then
  echo "FAIL: $SNAPHU_MSYS did not run or stopped with an error."
  echo "If nothing was printed above, check that there is no msys-2.0.dll in"
  echo "the same folder as that snaphu.exe. See Troubleshooting in README.md."
  exit 1
fi
./selftest.exe check unwrapped_msys.bin

echo
echo "== Test 2 of 2: the copy for Windows programs, run by the Command Prompt"
if ! cmd.exe //c "$(cygpath -w "$SNAPHU_WINDOWS")" wrapped.bin "$LINE_LENGTH" -o unwrapped_windows.bin; then
  echo "FAIL: $SNAPHU_WINDOWS did not run or stopped with an error."
  echo "Check that msys-2.0.dll is in the same folder as that snaphu.exe."
  exit 1
fi
./selftest.exe check unwrapped_windows.bin

echo
echo "== Both tests passed"
