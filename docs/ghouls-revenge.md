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
all-new Ghouls Party! Race through any level of your choice to beat
the best time. Scores are saved to disk and best times are shareable.

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
cabinet type play at events or shows, or offline asynchronous
competition. The only game mode is Time Attack, all level sets are
permanently resident, scores are saved to disk so they are persistent
between runs, and there's a BASIC tool for handling merging best
scores from multiple sets of score files.

As well as the system requirements for Ghouls Revenge, and Ghouls
Party also requires 1 unoccupied 16 KB sideways RAM bank.

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

## Printing times

To print the current times to a text file, run the BASIC program
`TPRINT` from the Ghouls Party disk.

    CHAIN"TPRINT"
	
The output will be shown on screen, and also saved to a file called
`GPTIMET` on the disk.

## Score files

Scores are saved to a file called `GPTIMES`, which you can back up or
send to people. Score files are specific to a particular Ghouls Party
build, and can't be freely mixed - but you can use the BASIC program
`TMERGE` on the Ghouls Party disk to merge scores from another score
file into yours.

    CHAIN"TMERGE"

You'll be asked to specify the name of a file to load. If using DFS,
simply swap to another Ghouls Party disk and enter `GPTIMES` to load
its scores; otherwise, you can enter * commands by entering something
beginning with `*`. (For example, with ADFS, you'll need to do the
usual `*MOUNT` business.)

Once the file has loaded, you'll be prompted to reinsert the Ghouls
Party disk and enter `Y`. Again, you can enter * commands by entering
something beginning with `*`.

You'll then see each level set in turn, with each level's current
score, and the score found (if any) for it in the other scores file.
The other score will be merged across if it's quicker, or not if it's
slower or the same.

If you see the message `No record for this level found`, this level
has no match in the levels in the other score file, probably because
the level data has since changed (rendering the original time
invalid).

Press `SPACE` to accept the result - this is usually what you want -
or toggle the merge status of each score with keys `1` to `4`.

Once you've gone through all the level sets, the merged scores file
will be saved to `GPTIMES` on disk.

A backup of the old file can be found in `GPTIMEB`.

## Bitshifters' Best Times

Our own set of best times can be found in the file `BTIMES`, for
merging into your own score file if you fancy trying to beat them!

NOTE: these scores were obtained using a prerelease version of the
game, with older versions of some levels. You may see `No record for
this level found` messages when merging.

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
