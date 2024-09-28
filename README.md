# Ghouls - The Next Generation

Play the original in your browser: http://bbcmicro.co.uk/game.php?id=2506

----

# Run

Get .ssd file (or .zip file containing .ssd file) for the latest build
here: https://github.com/tom-seddon/ghouls-tng/releases/latest

Shift+Break to boot.

## Adventurer

Select 1 to play the game. Enter name of levels file created using
editor (see below), or leave blank for the default.

## Architect

Select 2 to create levels.

From the editor menu, press `1`/`2`/`3`/`4` to edit that level.

Press `N` to set a level's name. Select level number then type in its
new name. There's a limit of 16 chars.

Press `U` to set the level set-specific instruction text, printed as
part of the instructions. See the text editing section below.

Press `C` to set the level set-specific completion text, printed as part of the ending screen. See the text editing section below.

Press `R` to reset a level's data. The level will be emptied, leaving
just a row of blocks along the bottom and a few blocks underneath the
treasure in the top right.

Press `L` to load levels. Enter file name.

Press `S` to save levels. Enter file name.

Press `I` to import a level from another level set. Enter file name,
then level from that set to import, then level in the current set to
replace. Press ESCAPE at any point to get back to the main menu.

Press `E` to export screen grabs of all the levels. Enter the name
prefix, and 4 files will be saved with using the prefix you supply and
suffixes `0`...`3`. These are simply MODE 5 screen grabs, and you can
*LOAD them in MODE 5 to see them. (Set colour 0 to black, 1 to red, 2
to yellow, and 3 to `?&7FFF`.) Or get them onto your PC and use them
with `bin/screenshots.py` to create a PNG showing all 4 screens.
(`screenshots.py --help` will give some indication of how to use it.)

Press `*` to get a prompt for entering OS commands. Change drive and
dir and so on. Press ESCAPE to get back to the editor menu.

When editing:

- `Z`/`X`/`*`/`?` move the cursor. CUR shows the item under the
  cursor, and its creation value (see below)
- `DELETE` deletes the thing under the cursor
- `←`/`→` select the NEW thing's type
- `↑`/`↓` select the NEW thing's creation value (see below)
- `RETURN` adds an instance of the NEW thing to the level
- `C` changes the level-specific colour
- `G` sets one corner of the ghost start position area (the position
  is automatically clamped if necessary)
- `SHIFT+G` sets the other corner of the ghost start position area
- `CTRL+G` unsets the ghost start position area
- `R` redraws the level (since the editor isn't particularly careful
  about tidily redrawing everything while editing)
- `S` sets the player's test start position
- `SHIFT+S` sets the player's start position
- `T` toggles presence of standard treasure or not (see below)
- `TAB` lets you test the level. If the test start position is set,
  the player starts there. Testing ends with `ESCAPE` or when you die
  or complete the level
- `SHIFT+TAB` tests the level, always using the level start position
- `ESCAPE` takes you back to the main menu

The test start position is shown in red. It isn't saved. It's there to
make it quicker to iterate on sections of the level.

The creation value is a number associated with some types of object:

- For moving platforms: the platform's speed
- For spiders: the spider's speed

There are two types of spider: a solid one (always present), and a
masked/dimmed one (appears only when playing with 2+ ghosts).

The bottom row contains some indicators:

- `VI` ("victorious") - `Y` or `N` depending on whether you completed the
  level in the last test run, or something else happened. (You
  probably died! But you might just have pressed ESCAPE)
- `ST` ("standard treasure") - `Y` or `N` depending no whether there's
  a standard goal in the top right (as per the original levels - the
  game will automatically arrange for this to appear), or whether you
  have free choice of were they go (see below)
  
## Ghost start area

The ghost start area, if set, is indicated by a dotted red rectangle.
Ghosts will start from some position in this area.

If not set, ghosts will start at some random point in the level.

When testing in the editor, you will only ever get 1 ghost.

## Level goals

One of the objects looks like a yellow horizontal line. That's the
goal. If you step on it, you win the level.

The two vertical red lines are the rope type of thing next to the
standard goal, if you want to reproduce its appearance.

There are two types of treasure: the one that is just the bottom half
is just positioned by its bottom row rather than its top row, so you
can put it in the top row of the level. They both look the same in
game. (Configurable goals were a late addition...)

## Text editing

There's an extremely basic (if we're being polite) text editor kind of
thing (for a very loose definition of "kind of thing") for editing
completion text and instruction text. Navigate using the cursor keys,
DELETE to delete backwards, COPY to delete forwards, and press keys to
insert chars.

The whole text is treated as one big string, rather than separate
lines, so inserting text at the start will affect subsequent lines and
you'll have to fix it all up by hand.

There's an invisible runoff area after the end of the editor text, so
anything that goes off the end is not lost! If you delete chars,
you'll see it come back. What's visible is all that gets saved to the
level data though.

### Instructions text

Press `SHIFT+F1` ... `SHIFT+F7` to insert teletext colour control
codes.

Press `CTRL+F1` ... `CTRL+F4` to set the control code used at the
start of each line. These codes are treated separately, in an attempt
to make things marginally less annoying.

### Completion text

Press `CTRL+P` to see the text in an approximation of the Mode 5
screen it's shown as in game.


----

# Build

## Prerequisites

### Windows

- Python 3.x

Additional dependencies are provided as EXEs in the repo.

### POSIX-type

- GNU Make (`make`)
- Python 3.x (`/usr/bin/python3`)
- [64tass](https://sourceforge.net/projects/tass64/) (`64tass`) -
  version 2974 works
- Working C compiler
  ([basictool](https://github.com/ZornsLemma/basictool) is compiled
  automatically as part of the build)

## Clone the repo

This repo has submodules. Clone it with `--recursive`:

    git clone --recursive https://github.com/tom-seddon/ghouls-tng
	
Alternatively, if you already cloned it non-recursively, you can do
the following from inside the working copy:

    git submodule init
	git submodule update

## Build

Run `make` in the working copy. (A `make.bat` is supplied for Windows,
which will run the supplied copy of GNU Make.)

The output is a .ssd file, `ghouls-tng.ssd`, suitable for use with an
emulator.

The output files can also be found in `beeb/ghouls-tng/y/`. If you use
[BeebLink](https://github.com/tom-seddon/beeblink/), configure it so
it can find this folder - the output will be available in drive Y of
the ghouls-tng volume.

----

# Branches

## `main`

Branch used for active development.

## `unmodified`

Latest version that promises to build to something bit identical to
the starting point: a minified version of Ghouls, loaders stripped
out, unmodified machine code parts, BASIC unmodified other than
replacing embedded control codes with appropriate CHR$.
