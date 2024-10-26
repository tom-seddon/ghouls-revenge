# Ghouls: Revenge

It's been 40 years since the deadly haunted mansion. What horrors has
the ghost been cooking up? Now, revisit the mansion - and 14 exciting
new 4-level situations.

But beware! Wherever your adventures take you, the ghost is never far
behind! And... don't expect it to be easy.

Once the ghost is defeated, or if you admit defeat yourself, use the
level editor to devise fresh torments.

# Running the game

The game comes as a zip file containing disk images suitable for use
with an emulator, Gotek, or for writing to floppy disk.

There are 2 DFS disk images, for BBC B/B+/Master/Compact, where `X.YY`
is the version number:

- `ghouls-revenge-vX.YY.ssd` - 80 track, single sided
- `ghouls-revenge-vX.YY.40.ssd` - 40 track, single sided

There are 3 ADFS disk images, similarly named, for BBC Master/Compact:
(apologies, but BBC B/B+ ADFS is not supported)

- `ghouls-revenge-vX.YY.ads` - ADFS S
- `ghouls-revenge-vX.YY.adm` - ADFS M
- `ghouls-revenge-vX.YY.adl` - ADFS L

All disk images are auto-booting. Just press SHIFT+BREAK. The title
screen will appear. Press any key for the menu, then select the option
of interest: (these are discussed below)

- `1` - play the game
- `2` - run the level editor
- `3` - run a debug version of the game with some additional cheats
  for testing your levels.
  
(If you know which entry you want, you can press it at the title
screen and save a keypress. Also: press `V` at the menu to report the
build version number.)

# Game

Select the level set you want from the menu. Jump to a specific set
quickly by pressing its shortcut key, shown in the bottom right as you
scroll through.

Select the game mode on startup:

- `1` - Classic: 4 lives, game ends if you run out
- `2` - Infinite Lives: as many deaths as you want, but the game
  ends if the bonus timer falls to 0. The bonus timer is reset on each
  new level
- `3` - Time Attack: get through each level as quickly as you can!
  The best score is recorded

There are in-game instructions giving a brief overview of how to play,
and the keys to use.

The game objects list may not be _quite_ complete...

# Level editor

The level editor has its own page: [level editor instructions](./ghouls-revenge-level-editor.md)

# Debug game

Mostly as the ordinary game, with a few differences:

- The `ON ERROR` routine prints the error encountered, and ESCAPE
  isn't trapped
- In Classic or Infinite Lives mode, when asking if you want to see
  game objects, you can press one of the following keys:
  
  - `1`, `2`, `3`, `4` - start on that level
  - `G` - change number of ghosts
  - `C` - see the completion sequence

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

