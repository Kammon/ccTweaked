inv = require("/repos/Kammon/ccTweaked/libraries/inventories")
turtle = require("/rom/apis/turtle/turtle")

while true do
	entity = turtle.inspect();
	while entity and entity.name ~= "minecraft:oak_log" do
		os.sleep(10);
		entity = turtle.inspect();
	end
	i, continue = 1, true;
	while continue do
		turtle.dig()
		turtle.forward()
		blockAbove = turtle.inspectUp()
		while blockAbove and blockAbove.name ~= "minecraft:glass_pane" do
			turtle.digUp()
			turtle.up()
			blockAbove = turtle.inspectUp()
		end
		while not turtle.detectDown() do turtle.down() end
		entity = turtle.inspect()
		if entity and entity.name ~= "minecraft:oak_log" then continue = false else i=i+1 end
	end
	for i=i,1,-1 do
		turtle.back()
		turtle.place() -- this is lazily assuming the current slot has saplings, sue me, it's test code
	end
end
