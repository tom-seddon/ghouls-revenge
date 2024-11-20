# Ghouls: Revenge

It's been 40 years since the deadly haunted mansion. What horrors has
the ghost been cooking up? Now, revisit the mansion - and 15 exciting
new 4-level situations.

But beware! Wherever your adventures take you, the ghost is never far
behind! And... don't expect it to be easy. These levels have been
constructed deliberately to test you.

Once the ghost is defeated - or if you admit defeat yourself - use the
level editor to devise fresh torments.

Then, for a completely fresh take on the Ghouls experience, try the
all-new Ghouls Party!

# Running the game

Download the zip file from the Ghouls: Revenge page:
https://bitshifters.github.io/posts/prods/bs-ghouls-revenge.html

The game comes as a zip file containing disk images suitable for use
with an emulator, Gotek, or for writing to floppy disk.

For Ghouls: Revenge, there are 2 DFS disk images, for BBC B/B+/Master,
where `X.YY` is the version number:

- `ghouls-revenge-vX.YY.ssd` - 80 track, single sided
- `ghouls-revenge-vX.YY.40.ssd` - 40 track, single sided

There are 3 ADFS disk images, similarly named, for BBC Master/Compact:
(apologies, but BBC B/B+ ADFS is not supported)

- `ghouls-revenge-vX.YY.ads` - ADFS S
- `ghouls-revenge-vX.YY.adm` - ADFS M
- `ghouls-revenge-vX.YY.adl` - ADFS L

And for Ghouls Party, there are 5 similar disk images, all named
`ghouls-party-vX.YY`, file extensions as above.

# Ghouls: Revenge instructions

The Ghouls: Revenge disk images are auto-booting. Just press
SHIFT+BREAK. The title screen will appear. Press any key for the menu,
then select the option of interest: (these are discussed below)

- `1` - play the game
- `2` - run the level editor
- `3` - run a debug version of the game with some additional cheats
  for testing your levels.
  
(If you know which entry you want, you can press it at the title
screen and save a keypress. Also: press `V` at the menu to report the
build version number.)

## Game

Select the level set you want from the menu. Jump to a specific set
quickly by pressing its shortcut key, shown in the bottom right as you
scroll through.

Select the game mode on startup:

- `1` - Classic: 4 lives, game ends if you run out
- `2` - Infinite Lives: as many deaths as you want, but the game ends
  if the bonus timer falls to 0. The bonus timer is reset on each new
  level
- `3` - Time Attack: get through each level as quickly as you can! The
  fastest time is recorded

There are in-game instructions giving a brief overview of how to play,
and the keys to use. (There is also a game object list - for advisory
purposes only. There may be the odd surprise in store.)

## Level editor

The level editor has its own page: [level editor instructions](./ghouls-revenge-level-editor.md)

## Debug game

Mostly as the ordinary game, with a few differences for use when
testing your own levels or when modifying the code:

- The `ON ERROR` routine prints the error encountered, and ESCAPE
  isn't trapped
- In Classic or Infinite Lives mode, when asking if you want to see
  game objects, you can press one of the following keys:
  
  - `1`, `2`, `3`, `4` - start on that level
  - `G` - change number of ghosts
  - `C` - see the completion sequence

# Ghouls Party instructions

Ghouls Party is a version of Ghouls: Revenge designed for kiosk/arcade
cabinet type play at events or shows. The only game mode is Time
Attack, all level sets are permanently resident, and scores are saved
to disk so they are persistent between runs.

Ghouls Party requires 1 unoccupied 16 KB sideways RAM bank.

The Ghouls Party disk images are auto-booting. Just press SHIFT+BREAK.
There's no title screen - the main menu will appear shortly, listing
all the level sets available, and the shortcut letter to access each
one. Press that letter to see the current best times for the 4 levels
in that set, then press the level number to play that level.

Play repeats until you press ESCAPE (taking you back to the main menu)
or complete the level. If you beat the previous time, enter your name
(6 chars - any of letters, numbers, space, `-`, `?` and `!`), press
RETURN, and your score will be immortalized on disk. Until it's beaten
again, at least...

## Score files

Ghouls Party score files are mergeable with a PC-based command line
tool, if you want to collate the best times from multiple events. See
`bin/ghouls_party_tool.py` in the repo. Use the tool to merge the
score files, then overwrite the existing score file on the BBC disk
with the new data.

If you'd like more information, please [open a GitHub
issue](https://github.com/tom-seddon/ghouls-revenge/issues) and I'll
write up some proper documentation for this.

# Credits

Original game (much of which is retained): David J Hoskins

Additional programming (level editor and some game code): [Tom
Seddon](https://www.stardot.org.uk/forums/memberlist.php?mode=viewprofile&u=454)

Level design and testing:

- [Kieran Connell](https://www.stardot.org.uk/forums/memberlist.php?mode=viewprofile&u=10431)
- [Stew Badger](https://www.stardot.org.uk/forums/memberlist.php?mode=viewprofile&u=9784)
- [Dave Footitt](https://www.stardot.org.uk/forums/memberlist.php?mode=viewprofile&u=605)
- [VectorEyes](https://www.stardot.org.uk/forums/memberlist.php?mode=viewprofile&u=11399)
- [Tom Seddon](https://www.stardot.org.uk/forums/memberlist.php?mode=viewprofile&u=454)

Title screen: [Dethmunk](https://www.stardot.org.uk/forums/memberlist.php?mode=viewprofile&u=10689)

Thanks are also due to the developers of the following tools used by
Ghouls: Revenge:

- [64tass](https://tass64.sourceforge.net/) - assembler
- [basictool](https://github.com/ZornsLemma/basictool) - BBC BASIC utility
- [zx02](https://github.com/dmsc/zx02) - file compressor
