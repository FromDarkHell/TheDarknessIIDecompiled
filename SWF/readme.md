## SWF Flash Decompiled

Flash is completely useless nowadays so its hard to find anything helpful (hell even Adobe Animate doesn't help for ActionScript 2 :/)
I ripped out all of the `*.swf` files that were extracted (See the README in the directory below this)
Then used [some random SWF decompiler](https://pdfrecover.herokuapp.com/swfdecompiler/) to decompile all of these files into whatever this mess of a folder is
Since the folders it gives out are occasionally `*.fla.zip`, you need to extract them, giving back `*.fla\foo.as` or whatever
So then you need to use a language that actually doesn't care about stuff like directories having extension (tsk tsk not **POWERSHELL**), or you can just use the `Convert.py` script in this same folder