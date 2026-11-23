# snaphu-win: build SNAPHU on Windows from the official Stanford source

SNAPHU is the Statistical-Cost, Network-Flow Algorithm for Phase Unwrapping.
It was written by Curtis W. Chen and Howard A. Zebker at Stanford University
and is the standard tool for unwrapping the phase of radar interferograms.

**Official SNAPHU page:**
<https://web.stanford.edu/group/radar/softwareandlinks/sw/snaphu/>

SNAPHU is written for Unix and Linux. This repository is a short, tested
recipe for building it on Windows. All credit for SNAPHU belongs to its
authors. This repository is not affiliated with or endorsed by Stanford
University or the SNAPHU authors.

## What is in this repository, and what is not

This repository contains **no SNAPHU source code and no programs to
download and run**. It contains instructions and three small files that you
can read in a few minutes:

| File | What it is |
|---|---|
| `README.md` | These instructions |
| `build.sh` | Downloads the SNAPHU source from Stanford, checks it, and compiles it |
| `test.sh` | Checks that the SNAPHU you built gives the right answer |
| `test/selftest.c` | Small program used by `test.sh` to make a test image and check the result |

You download the SNAPHU source yourself, directly from Stanford's web site,
and compile it on your own computer. **The SNAPHU source files are not
modified.** You do not have to trust a program that somebody else built.

If you would rather type the commands yourself than run `build.sh`, they are
listed in [Building by hand](#building-by-hand). There are five of them.

## What you need

- A 64-bit Windows 10 or Windows 11 computer.
- About 1 GB of free disk space (almost all of it is the compiler).
- An internet connection.
- About 15 minutes.

You do not need to know how to program in C.

## Step 1. Install MSYS2

MSYS2 is a free set of Unix tools for Windows, including the C compiler
(GCC) that builds SNAPHU.

1. Go to <https://www.msys2.org/> and download the installer (about 80 MB).
   Its name looks like `msys2-x86_64-YYYYMMDD.exe`, where `YYYYMMDD` is a
   date. The download link on that page goes to GitHub, which is where the
   MSYS2 project keeps its installers.
2. Run the installer. Click Next on each page and keep the suggested
   choices, including the folder `C:\msys64`. It takes a minute or two.
3. On the last page, clear the "Run MSYS2 now" box and click Finish. The
   next step opens the right terminal.

If MSYS2 is already installed, skip this step.

## Step 2. Open the "MSYS2 MSYS" terminal

MSYS2 puts several terminals in the Start menu. They look alike but use
different compilers. **SNAPHU needs the one named "MSYS2 MSYS".**

1. Open the Start menu, type `MSYS2 MSYS`, and open it.
2. Check the prompt. It ends with the word `MSYS` in purple (magenta), like this:

   ```
   yourname@yourcomputer MSYS ~
   $
   ```

If the prompt says `MINGW64`, `UCRT64`, `CLANG64`, or `CLANGARM64`, close the window and
open "MSYS2 MSYS". [Why this matters](#why-the-msys-terminal) is explained
below.

Everything in steps 3 to 6 is typed into this terminal. Type each command
(or paste it with a right click, or Shift+Insert) and press Enter. The `$`
at the start of the prompt is not part of the command.

## Step 3. Install the build tools

First update MSYS2:

```bash
pacman -Syu
```

It may ask more than one question; answer `Y` each time. The first time, it
usually says that the terminal will be closed to finish the update, and the
window then closes by itself. Open "MSYS2 MSYS" again and run the same
command once more. The update is finished when the command ends and the
window stays open.

Then install the tools that the build needs (about 90 MB to download, about
550 MB on disk):

```bash
pacman -S --needed gcc make wget tar git
```

| Tool | Used for |
|---|---|
| `gcc` | The C compiler |
| `make` | Runs the compile commands listed in SNAPHU's Makefile |
| `wget` | Downloads the SNAPHU source from Stanford |
| `tar` | Unpacks the downloaded file |
| `git` | Downloads this repository |

Lines such as `warning: wget-1.25.0-6 is up to date -- skipping` are normal.
They mean that the tool is already installed.

## Step 4. Get this repository

```bash
cd ~
git clone https://github.com/jpaden/snaphu-win.git
cd snaphu-win
```

`cd ~` goes to your MSYS2 home folder, which in Windows is
`C:\msys64\home\yourname`. You can use a different folder if you like, but
avoid folders with spaces in their names.

## Step 5. Build SNAPHU

```bash
./build.sh
```

This takes less than a minute. It prints each thing that it does:

1. Downloads `snaphu-v2.0.7.tar.gz` (171 kB) from Stanford.
2. Checks that the download is the exact file these instructions were tested
   with (see [Checking the download](#checking-the-download)).
3. Unpacks it into the `build` folder.
4. Compiles it. About 20 compiler warnings are printed, which fill a couple
   of screens. They are harmless. The build worked if the output ends with
   the `== Done` lines shown below.
5. Makes a second copy of `snaphu.exe` in `build\windows`, with
   `msys-2.0.dll` next to it, for use from Windows programs.

The last lines tell you where SNAPHU is, for example:

```
== Done. SNAPHU is in two places:
  For Windows programs (Command Prompt, PowerShell, MATLAB, Python):
    C:\msys64\home\yourname\snaphu-win\build\windows\snaphu.exe
    Keep msys-2.0.dll in the same folder as this snaphu.exe.
  For use inside this MSYS2 terminal:
    /home/yourname/snaphu-win/build/snaphu-v2.0.7/bin/snaphu.exe
```

Write the first path down. It is what you give to MATLAB, Python, or the
Command Prompt to run SNAPHU. [Using SNAPHU](#using-snaphu) explains why
there are two copies.

## Step 6. Test it

```bash
./test.sh
```

This makes a small test interferogram whose true phase is known, unwraps it
with the SNAPHU you just built, and compares the result to the truth. It
does this twice, once for each copy of SNAPHU. Among the SNAPHU messages you
should see these lines twice:

```
Largest difference from the true phase: 1.35e-05 radians (allowed: 1e-03)
PASS
```

and the last line should be:

```
== Both tests passed
```

The number can differ slightly on your computer. If you see
`== Both tests passed`, you are done.

## Using SNAPHU

The build makes two copies of SNAPHU. They are the same program. Which one
you use depends on where you run it:

| Where you run SNAPHU | Use this copy |
|---|---|
| Command Prompt, PowerShell, MATLAB, Python, or any other Windows program | `build\windows\snaphu.exe` |
| Inside the "MSYS2 MSYS" terminal | `build/snaphu-v2.0.7/bin/snaphu.exe` |

Most people only need the first one. Ordinary Windows file names such as
`C:\data\wrapped.bin` work with it.

The reason for two copies is the file `msys-2.0.dll`, which SNAPHU needs in
order to run on Windows:

- **Keep `msys-2.0.dll` in the same folder as the Windows copy of
  `snaphu.exe`.** If you copy SNAPHU somewhere else, copy both files from
  `build\windows`.
- Do not put `msys-2.0.dll` next to the copy that you run inside the MSYS2
  terminal. The terminal already has that file loaded, and with a second
  copy of it `snaphu.exe` does not start: it prints nothing and stops with
  status 127.

The simplest use is:

```
snaphu.exe INPUT_FILE LINE_LENGTH -o OUTPUT_FILE
```

- `INPUT_FILE` is the wrapped interferogram.
- `LINE_LENGTH` is the number of samples in each line of the interferogram.
- `OUTPUT_FILE` is where the unwrapped phase is written.

From the Command Prompt:

```
C:\msys64\home\yourname\snaphu-win\build\windows\snaphu.exe C:\data\wrapped.bin 300 -o C:\data\unwrapped.bin
```

From MATLAB:

```matlab
snaphu_path = 'C:\msys64\home\yourname\snaphu-win\build\windows\snaphu.exe';
cmd_str = sprintf('"%s" "%s" %d -o "%s"', snaphu_path, fn_in, line_length, fn_out);
system(cmd_str);
```

### File formats

SNAPHU reads and writes plain binary files with no header. With no other
options it uses these two formats:

- **Input (`COMPLEX_DATA`):** each sample is two 32-bit floats, the real
  part and then the imaginary part. The lines are written one after another.
  The phase of each complex sample is the wrapped phase.
- **Output (`ALT_LINE_DATA`):** for each line, one line of magnitude and
  then one line of unwrapped phase in radians, all 32-bit floats.

`test/selftest.c` is a short, complete example of writing the input and
reading the output.

SNAPHU has many more options (correlation files, weights, tiling, several
processors). They are described in the manual page, which the build puts in
`build\snaphu-v2.0.7\man\snaphu_man1.txt` and which is also on the
[official page](https://web.stanford.edu/group/radar/softwareandlinks/sw/snaphu/snaphu_man1.html).
Run `snaphu.exe -h` for a summary.

## Building by hand

`build.sh` runs the commands below. If you prefer, type them yourself in the
"MSYS2 MSYS" terminal after step 3. You do not need this repository at all
to do this.

```bash
# 1. Download the source from Stanford
wget https://web.stanford.edu/group/radar/softwareandlinks/sw/snaphu/snaphu-v2.0.7.tar.gz

# 2. Check the download (compare what it prints to the hash under
#    "Checking the download" below)
sha256sum snaphu-v2.0.7.tar.gz

# 3. Unpack it
tar -xzf snaphu-v2.0.7.tar.gz

# 4. Compile it
make -C snaphu-v2.0.7/src CC="gcc" CFLAGS="-O3 -Wall -std=gnu17 -D NO_CS2"

# 5. Make a copy for Windows programs, with the MSYS2 runtime next to it
mkdir windows && cp snaphu-v2.0.7/bin/snaphu.exe /usr/bin/msys-2.0.dll windows/
```

SNAPHU is then `windows\snaphu.exe` for Windows programs and
`snaphu-v2.0.7/bin/snaphu.exe` for use inside the MSYS2 terminal (see
[Using SNAPHU](#using-snaphu)).

## What the build changes

Nothing in the SNAPHU source is changed. The only differences from the
build described in SNAPHU's own README are three settings passed to `make`
on the command line, which take the place of the `CC` and `CFLAGS` lines in
SNAPHU's Makefile:

| Setting | Why |
|---|---|
| `CC="gcc"` | The Makefile asks for a compiler named `cc`. In MSYS2 it is named `gcc`. |
| `-std=gnu17` | GCC 15 and newer compile as the 2023 version of C (C23) unless told otherwise. C23 no longer accepts an older style of function pointer that is used on four lines of `snaphu_tile.c`, so the compile stops with "incompatible pointer type" errors. This setting tells GCC to use the 2017 version of C, which accepts them. It only changes which version of the C language rules the compiler applies. |
| `-D NO_CS2` | Leaves out the optional CS2 solver. This option is described in SNAPHU's README. CS2 has its own license that only allows evaluation use, and SNAPHU does not need it: its default solver (MST) is separate. |

The Makefile's `-arch x86_64` setting is for Apple computers and is left
out because GCC on Windows does not accept it. `-O3 -Wall` are the same as
in the Makefile.

## Checking the download

`build.sh` computes the SHA-256 hash of the file it downloads and stops if
it is not this value:

```
c03ac126f9a964321bb5d6fb5b4004728368da268d7cb8407bb295a8abe5b262  snaphu-v2.0.7.tar.gz
```

`sha256sum` may print an asterisk (`*`) in front of the file name. That is
normal.

A hash is a fingerprint of a file: if even one byte of the file changes,
the hash changes. This value was computed from the file downloaded from the
Stanford address above on 2026-11-23 (171206 bytes, dated 2024-03-12 on the
server).

Be clear about what this check means. Stanford does not publish a hash for
SNAPHU, so the check does not prove who made the file. It proves that the
file you downloaded is byte for byte the file that these instructions were
tested with, and that your download was not cut short or altered on the
way. The download itself comes straight from Stanford over an encrypted
(https) connection.

## Why the MSYS terminal

SNAPHU uses Unix functions (`fork`, `wait`, `kill`, and the header
`sys/resource.h`) that Windows does not have.

- The **MSYS2 MSYS** environment supplies those functions through a library,
  `msys-2.0.dll`. This is why the Windows copy of `snaphu.exe` needs that
  file next to it.
- The **MSYS2 MINGW64, UCRT64, CLANG64, and CLANGARM64** environments make programs that
  call Windows directly. They do not have those functions, so SNAPHU does
  not compile there without rewriting parts of it.
- The **MinGW-w64 compiler that MATLAB uses for MEX files** is the same kind
  of compiler as MINGW64, so it cannot build SNAPHU either. If you already
  have it, or MSYS2 MINGW64, installed, that is fine: the MSYS environment
  is installed alongside them by step 3 and does not disturb them.

## Troubleshooting

| What you see | What to do |
|---|---|
| `ERROR: this is not the "MSYS2 MSYS" terminal` | You opened a different MSYS2 terminal. Open "MSYS2 MSYS" (step 2). |
| `ERROR: "gcc" is not installed` or `command not found` | Run the `pacman -S` command in step 3. |
| `./build.sh: Permission denied` | Run `bash build.sh` instead. |
| `$'\r': command not found` | The file was saved with Windows line endings. Download the repository again with `git clone` as in step 4. |
| `sha256sum: WARNING: 1 computed checksum did NOT match` | The download is damaged or the file at Stanford has changed. Delete `build/snaphu-v2.0.7.tar.gz` and run `./build.sh` again. If it still fails, do not build it; open an issue here. |
| `incompatible pointer type` errors in `snaphu_tile.c` | `-std=gnu17` is missing from the compile command. See [What the build changes](#what-the-build-changes). |
| `unrecognized command-line option '-arch'` | You ran `make` without the `CFLAGS` setting. Use the command in [Building by hand](#building-by-hand). |
| A "snaphu.exe - System Error" window that says "The code execution cannot proceed because msys-2.0.dll was not found. Reinstalling the program may fix this problem." | Reinstalling does not help. `msys-2.0.dll` must be in the same folder as `snaphu.exe`. Use the copy of SNAPHU in `build\windows`, or copy `msys-2.0.dll` from `C:\msys64\usr\bin`. |
| In the MSYS2 terminal `snaphu.exe` prints nothing, and `echo $?` then prints `127` | You ran a copy of SNAPHU that has `msys-2.0.dll` next to it. Inside the MSYS2 terminal use `build/snaphu-v2.0.7/bin/snaphu.exe`. See [Using SNAPHU](#using-snaphu). |
| `snaphu.exe -h` shows the help but reports exit code 1 | That is normal for `-h`. |
| `wget` cannot connect | Check your internet connection. On some networks a proxy or VPN is needed to reach `web.stanford.edu`. |

To start over, delete the `build` folder and run `./build.sh` again.

## Tested with

| Date | Windows | MSYS2 runtime | GCC | SNAPHU | Result |
|---|---|---|---|---|---|
| 2026-11-23 | Windows 11 Enterprise (10.0.26100) | 3.6.4 | 15.2.0 | 2.0.7 | `test.sh` passes; run from MATLAB R2024b with Windows file names; tile mode with 2 processes runs |

## Credit, references, and licenses

**SNAPHU** is by Curtis W. Chen and Howard A. Zebker, Stanford University.
Copyright 2002-2024 Board of Trustees, Leland Stanford Jr. University. Its
license is in the `README` file inside the download
(`build/snaphu-v2.0.7/README` after you build). Read it before you
redistribute SNAPHU. Questions and bug reports about SNAPHU itself go to the
address in that file, not here.

The official page lists these papers:

- C. W. Chen and H. A. Zebker, "Network approaches to two-dimensional phase
  unwrapping: intractability and two new algorithms," *Journal of the
  Optical Society of America A*, vol. 17, pp. 401-414, 2000.
- C. W. Chen and H. A. Zebker, "Two-dimensional phase unwrapping with use of
  statistical models for cost functions in nonlinear optimization," *Journal
  of the Optical Society of America A*, vol. 18, pp. 338-351, 2001.
- C. W. Chen and H. A. Zebker, "Phase unwrapping for large SAR
  interferograms: Statistical segmentation and generalized network models,"
  *IEEE Transactions on Geoscience and Remote Sensing*, vol. 40,
  pp. 1709-1719, 2002.

**CS2**, the optional solver that this build leaves out, is copyright 1995
IG Systems, Inc. and may only be used for evaluation without a commercial
license. Its terms are in the same `README` file.

**msys-2.0.dll** is part of [MSYS2](https://www.msys2.org/) and comes from
your own MSYS2 installation. It has its own license; see the MSYS2 web site
before you redistribute it.

**The files in this repository** (`README.md`, `build.sh`, `test.sh`,
`test/selftest.c`) are released under the MIT License (see `LICENSE`). That
license covers only these files, not SNAPHU.

## Related work

- [marsfan/SNAPHU-win](https://github.com/marsfan/SNAPHU-win) publishes
  ready-built Windows copies of SNAPHU, also made with MSYS2. Use that if
  you want a download and not a build.
- This repository is for people who want to build from the official source
  themselves and see every step.

Problems with these instructions: please open an issue on this repository.
