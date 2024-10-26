# Build

Instructions for building your own copy of Ghouls Revenge.

## Prerequisites

### Windows

- Git on PATH
- Python 3.x

Additional dependencies are provided as EXEs in the repo.

### POSIX-type

- Git
- GNU Make (version 4 or later)
- Python 3.x (`/usr/bin/python3`)
- [64tass](https://sourceforge.net/projects/tass64/) (`64tass`) -
  version 2974 works
- Working C compiler
  ([basictool](https://github.com/ZornsLemma/basictool) and
  [zx02](https://github.com/dmsc/zx02) are compiled automatically as
  part of the build)

## Clone the repo

This repo has submodules. Clone it with `--recursive`:

    git clone --recursive https://github.com/tom-seddon/ghouls-revenge
	
Alternatively, if you already cloned it non-recursively, you can do
the following from inside the working copy:

    git submodule init
	git submodule update

(The source zip files that GitHub makes available are no good. The
only supported way to build this project is to clone it from GitHub as
above.)

## Build

Run `make` in the working copy. (A `make.bat` is supplied for Windows,
which will run the supplied copy of GNU Make.)

The output disk images are in the root of the working copy:

* `ghouls-revenge.ssd` - 80 track DFS disk image
* `ghouls-revenge.40.ssd` - 40 track DFS disk image
* `ghouls-revenge.ads` - ADFS S disk image
* `ghouls-revenge.adm` - ADFS M disk image
* `ghouls-revenge.adl` - ADFS L disk image

(Note that the build process is deliberately not quite deterministic,
and the ADFS disk images have random disk IDs.)

The game files can also be found in .inf format in
`beeb/ghouls-revenge/y/`. If you use
[BeebLink](https://github.com/tom-seddon/beeblink/), configure it so
it can find this folder - the output will be available in drive Y of
the ghouls-revenge volume.

## macOS notes

- You may need to install GNU Make from MacPorts or similar. Xcode
  comes with GNU Make 3.81, which is too old

- If using MacPorts GNU Make, and you get errors from the C compiler
  about `-Wall` not being recognised, run it with `gmake CC=cc` 

----

# Branches

## `main`

Branch used for active development.

## `unmodified`

Latest version that promises to build to something bit identical to
the starting point: a minified version of Ghouls, loaders stripped
out, unmodified machine code parts, BASIC unmodified other than
replacing embedded control codes with appropriate CHR$.
