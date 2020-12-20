--[[


-require needs absolute path to files being included, but not the extension of the file
-fs.find("/a/dir/*") gets absolute paths of all files/dirs within '/a/dir/'
	-fs.getName(path) gets the file portion of the path
	-fs.move(srcP,destP) moves a given file
		-ex: fs.move(path,"/startup/"..fs.getName(path))
-files that are run with require in startup will persist while the turtle is on
	-ex: startup contains 'require("/requires/core") could allow the use of custom utility functions
-it appears craftOS at least (maybe all lua?) loads the script into memory before interpretation and execution,
	as you can delete the currently running file (shell.run("rm "..shell.getRunningProgram())) and it will not only
	not crash, but finish executing code written after that statement
-craftOS can take a startup file at the / root, or a startup/ directory at the / root
	-everything in the startup/ directory is run as a startup program, making file compartmentalization easier


-Railcraft coke can fuel turtles for 160/item, 1600/block (thermal foundation, railcraft)
	-blocks of coal cooked in coke ove become blocks of coke (railcraft) {name="railcraft:generic", damage=6}
	-when turning coke items into blocks it becomes the thermal foundation variant {name="themralfoundation:storage_resource",damage=1}
-tiny torch (tiny coal/charcoal (8x/coal/charcoal) & stick = 2x tiny torch) light level 12 instead of 14, but much less resource intensive early on. Using just charcoal and sticks, it's 3 logs per 16 tiny torches. Comparatively it's 4.5 logs per 16.
--]]
