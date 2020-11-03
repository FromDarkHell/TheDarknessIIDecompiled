from os import listdir, rename
from os.path import isdir, join
onlydirs = [join("./D2/Menus", f) for f in listdir("./D2/Menus") if isdir(join("./D2/Menus", f))] + [join("./EE/Menus", f) for f in listdir("./EE/Menus") if isdir(join("./EE/Menus", f))]

for d in onlydirs:
	if ".fla" not in d: continue
	rename(d, d[:-4])