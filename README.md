## The Darkness 2 Decompiled

Decompiled Lua source code for the 2012 game, The Darkness II

### Extraction

This game (like other [Evolution engine](https://en.wikipedia.org/wiki/Digital_Extremes#Technology) games) stores its files in gigantic files of two types:
1. Gigantic `.cache` files storing all of the assets based off of that type like `Script`, `Texture`
	- These can be broken down further into `H`, `B`, `F` where:
		- 'H' caches contain file headers
		- 'B' caches contain the corresponding binary files (except for sounds, and maybe textures)
		- 'F' caches contain full sound files and textures
2. `.toc` which is used to denote the `offset`, `name`, and `size` (among other data) about the sub files in the respective `.cache` files.
Furthermore, these `.cache` sub-files are compressed using both `oodle` and `lzf` compression, of which [oodle](http://www.radgametools.com/oodlecompressors.htm) compression is proprietary.
To get around the compression, you can use a [QuickBMS script](https://aluigi.altervista.org/bms/darkness2.bms) meant for use with [QuickBMS](https://aluigi.altervista.org/quickbms.htm)

### Decompilation

Once you've gotten around the compression / extracted all of the `.lua` (technically `.luac` since its compiled lua) from the game, you now get to decompile all of the compiled source!
In this case, I used [Unluac](https://sourceforge.net/projects/unluac/), tbh I've got no idea on how it works other than some weird techno magic but y'know it works. Then I made a Powershell script in `Tools/DecompileLua.ps1` (it goes in a dir right above where your extracted assets are btw)

For the `Cache.DLC` updates, I imagine that it just overwrites the original file, and so I've extracted those and just thrown the modified decompiled code into `/src_DLC`

### ~~Modding~~
Quite honestly I very much doubt this could even recompile (and kinda don't care to mess with that right now because euuuugh)...
In theory if it could compile, you could make something to redo the compression (probably best to just pick `lzf` throughout the `.cache`, I bet D2 could handle it) and reconstruct the `.cache` file, and then make something to reconstruct the respective `.toc` files