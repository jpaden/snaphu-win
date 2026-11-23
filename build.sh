#!/usr/bin/env bash
#
# build.sh - download and build SNAPHU on Windows with MSYS2
#
# Run this from the "MSYS2 MSYS" terminal (see README.md):
#
#   ./build.sh
#
# What it does, in order:
#   1. Downloads the official SNAPHU source from Stanford with wget.
#   2. Checks the SHA-256 hash of the download against the hash recorded
#      below.
#   3. Extracts the source into build/.
#   4. Compiles it with make. The source files are not modified.
#   5. Copies msys-2.0.dll next to snaphu.exe so that snaphu.exe runs from
#      any Windows program (Command Prompt, PowerShell, MATLAB, Python).
#
# Nothing is installed and nothing outside of this folder is changed.
# Everything this script makes is in build/. Delete build/ to start over.

set -euo pipefail

# SNAPHU release that this script builds
VERSION="2.0.7"
TARBALL="snaphu-v${VERSION}.tar.gz"

# Official download location (Stanford Radar Interferometry Research Group)
URL="https://web.stanford.edu/group/radar/softwareandlinks/sw/snaphu/${TARBALL}"

# SHA-256 hash of the file that this script was tested with (downloaded
# from the URL above on 2026-11-23, 171206 bytes)
SHA256="c03ac126f9a964321bb5d6fb5b4004728368da268d7cb8407bb295a8abe5b262"

# Compiler settings. These are passed to make on the command line, so the
# Makefile that comes with SNAPHU is used as is.
#   -O3          optimize for speed (same as the SNAPHU Makefile)
#   -Wall        show compiler warnings (same as the SNAPHU Makefile)
#   -std=gnu17   compile as C17. GCC 15 and newer default to C23, which
#                rejects four lines of older style C in snaphu_tile.c.
#   -D NO_CS2    leave out the optional CS2 solver, which has a separate
#                license for evaluation use only (see README.md)
CC="gcc"
CFLAGS="-O3 -Wall -std=gnu17 -D NO_CS2"

# -----------------------------------------------------------------------------
# Checks
# -----------------------------------------------------------------------------

if [ "${MSYSTEM:-}" != "MSYS" ]; then
  echo "ERROR: this is not the \"MSYS2 MSYS\" terminal (MSYSTEM=${MSYSTEM:-not set})."
  echo "SNAPHU needs the POSIX functions that only the MSYS environment has."
  echo "Open \"MSYS2 MSYS\" from the Start menu and run ./build.sh again."
  echo "See README.md, step 2."
  exit 1
fi

for tool in "$CC" make wget tar sha256sum; do
  if ! command -v "$tool" > /dev/null; then
    echo "ERROR: \"$tool\" is not installed. Run this command and try again:"
    echo "  pacman -S --needed gcc make wget tar"
    exit 1
  fi
done

# Work in the folder that this script is in
cd "$(dirname "$0")"
mkdir -p build
cd build

# -----------------------------------------------------------------------------
# 1. Download
# -----------------------------------------------------------------------------

if [ -f "$TARBALL" ]; then
  echo "== Using the copy of $TARBALL that is already in build/"
else
  echo "== Downloading $URL"
  wget "$URL"
fi

# -----------------------------------------------------------------------------
# 2. Check the download
# -----------------------------------------------------------------------------

echo "== Checking the SHA-256 hash"
if ! echo "${SHA256} *${TARBALL}" | sha256sum --check -; then
  echo "ERROR: $TARBALL is not the file that this script was tested with."
  echo "The download may be incomplete, or Stanford may have changed the file."
  echo "Delete build/$TARBALL and try again. If it still fails, do not build"
  echo "it; open an issue on the snaphu-win repository."
  exit 1
fi

# -----------------------------------------------------------------------------
# 3. Extract
# -----------------------------------------------------------------------------

echo "== Extracting"
rm -rf "snaphu-v${VERSION}"
tar -xzf "$TARBALL"

# -----------------------------------------------------------------------------
# 4. Compile
# -----------------------------------------------------------------------------

echo "== Compiling with: make CC=\"$CC\" CFLAGS=\"$CFLAGS\""
make -C "snaphu-v${VERSION}/src" CC="$CC" CFLAGS="$CFLAGS"

# -----------------------------------------------------------------------------
# 5. Copy the MSYS2 runtime next to the program
# -----------------------------------------------------------------------------

cp /usr/bin/msys-2.0.dll "snaphu-v${VERSION}/bin/"

BIN_DIR="$(pwd)/snaphu-v${VERSION}/bin"
echo
echo "== Done. SNAPHU is here:"
echo "  $(cygpath -w "${BIN_DIR}/snaphu.exe")"
echo "Keep msys-2.0.dll in the same folder as snaphu.exe."
echo "Run ./test.sh to check that it works."
