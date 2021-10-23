inv = require("/repos/Kammon/ccTweaked/libraries/inventories")
--turtle = require("/rom/apis/turtle/turtle")

--[[
-- front to back version (keep cutting down from start until there isn't a grown tree)
while true do
	present, entity = turtle.inspect();
	while present and entity.name ~= "minecraft:oak_log" do
		os.sleep(10);
		present, entity = turtle.inspect();
	end
	i, continue = 1, true;
	while continue do
		turtle.dig()
		turtle.forward()
		present, blockAbove = turtle.inspectUp()
		while present and blockAbove.name ~= "minecraft:glass_pane" do
			turtle.digUp()
			turtle.up()
			present, blockAbove = turtle.inspectUp()
		end
		while not turtle.detectDown() do turtle.down() end
		present, entity = turtle.inspect()
		if present and entity.name ~= "minecraft:oak_log" then continue = false else i=i+1 end
	end
	for i=i,1,-1 do
		turtle.back()
		turtle.place() -- this is lazily assuming the current slot has saplings, sue me, it's test code
	end
end
--]]


-- Row checking version (go down length of farm and inspect each tree)
while true do
	i, continue, present, entity = 1, true, turtle.inspect();
	while present and entity.name == "minecraft:oak_log" or entity.name == "minecraft:oak_sapling" do
		i=i+1;
		if entity.name == "minecraft:oak_log" then
			turtle.dig();
			present, blockAbove = turtle.inspectUp()
			while present && blockAbove.name ~= "minecraft:glass_pane" do turtle.digUp(); turtle.up(); end
			while not turtle.detectDown() do turtle.down(); end
			turtle.back();
			turtle.place(); -- again assuming saplings in current slot
		end
		turtle.turnLeft();
		turtle.forward();
		turtle.turnRight();
		present, entity = turtle.inspect();
	end
	turtle.turnRight();
	for i=i,1,-1 do	turtle.forward() end
	turtle.turnLeft();
	os.sleep(300);
end
