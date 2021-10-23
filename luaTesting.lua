inv = require("/repos/Kammon/ccTweaked/libraries/inventories")
--turtle = require("/rom/apis/turtle/turtle")

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
